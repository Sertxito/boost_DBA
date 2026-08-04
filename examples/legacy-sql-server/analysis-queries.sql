-- Query scripts for analyzing the ERP Case Study database
-- Use these with the various DB Boost agents to demonstrate capabilities

-- ============================================================================
-- DEPENDENCY ANALYSIS
-- ============================================================================

-- Find all stored procedures and their direct dependencies
SELECT 
    OBJECT_NAME(sed.referencing_id) AS [ProcedureA],
    OBJECT_NAME(sed.referenced_id) AS [DependsOn],
    CASE OBJECTPROPERTY(sed.referenced_id, 'IsTable') 
        WHEN 1 THEN 'Table'
        WHEN 0 CASE OBJECTPROPERTY(sed.referenced_id, 'IsProcedure')
            WHEN 1 THEN 'Procedure'
            ELSE 'View/Function'
        END
    END AS [ObjectType]
FROM sys.sql_expression_dependencies sed
WHERE database_id = DB_ID()
  AND OBJECTPROPERTY(sed.referencing_id, 'IsProcedure') = 1
ORDER BY OBJECT_NAME(sed.referencing_id);

-- Procedures with outbound dependencies (what do they call?)
SELECT 
    OBJECT_NAME(object_id) AS [ProcedureName],
    COUNT(DISTINCT referenced_id) AS [DependencyCount],
    STRING_AGG(OBJECT_NAME(referenced_id), ', ') AS [CallsThese]
FROM sys.sql_expression_dependencies
WHERE OBJECTPROPERTY(referencing_id, 'IsProcedure') = 1
  AND database_id = DB_ID()
GROUP BY object_id
ORDER BY DependencyCount DESC;

-- Procedures with inbound dependencies (who calls them?)
SELECT 
    OBJECT_NAME(object_id) AS [ProcedureName],
    COUNT(DISTINCT referencing_id) AS [CalledByCount],
    STRING_AGG(DISTINCT OBJECT_NAME(referencing_id), ', ') AS [CalledBy]
FROM sys.sql_expression_dependencies
WHERE OBJECTPROPERTY(referenced_id, 'IsProcedure') = 1
  AND database_id = DB_ID()
GROUP BY object_id
ORDER BY CalledByCount DESC;

-- ============================================================================
-- CRITICALITY ANALYSIS
-- ============================================================================

-- Calculate criticality score for each procedure
-- (High if widely used, Low if orphaned)
WITH ProcedureDependencies AS (
    SELECT 
        p.object_id,
        p.name AS ProcedureName,
        COUNT(DISTINCT sed.referencing_id) AS InboundReferences,
        (SELECT COUNT(DISTINCT referenced_id) 
         FROM sys.sql_expression_dependencies 
         WHERE referencing_id = p.object_id) AS OutboundReferences
    FROM sys.procedures p
    LEFT JOIN sys.sql_expression_dependencies sed ON sed.referenced_id = p.object_id
    WHERE p.name LIKE 'sp_%'
    GROUP BY p.object_id, p.name
)
SELECT 
    ProcedureName,
    InboundReferences,
    OutboundReferences,
    CASE 
        WHEN InboundReferences >= 3 THEN 'CRITICAL'
        WHEN InboundReferences >= 1 THEN 'IMPORTANT'
        ELSE 'ORPHANED'
    END AS CriticalityLevel,
    CASE 
        WHEN InboundReferences = 0 AND OutboundReferences = 0 THEN '🚨 DEAD CODE CANDIDATE'
        WHEN InboundReferences = 0 AND OutboundReferences > 0 THEN 'UTILITY'
        WHEN OutboundReferences > 2 THEN 'COMPLEX ORCHESTRATOR'
        ELSE ''
    END AS Classification
FROM ProcedureDependencies
ORDER BY InboundReferences DESC;

-- ============================================================================
-- EXECUTION PATTERN ANALYSIS
-- ============================================================================

-- Which procedures are actually executed in production?
-- (Requires stats from dm_exec_procedure_stats)
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    execution_count,
    last_execution_time,
    cached_time,
    DATEDIFF(DAY, last_execution_time, GETDATE()) AS [DaysNotExecuted]
FROM sys.dm_exec_procedure_stats
WHERE database_id = DB_ID()
ORDER BY execution_count DESC;

-- ============================================================================
-- BUSINESS LOGIC COMPLEXITY ANALYSIS
-- ============================================================================

-- Find complex procedures (multiple nested operations, long code)
SELECT 
    name AS ProcedureName,
    DATALENGTH(OBJECT_DEFINITION(object_id)) AS CodeSizeBytes,
    CASE 
        WHEN DATALENGTH(OBJECT_DEFINITION(object_id)) > 5000 THEN 'COMPLEX'
        WHEN DATALENGTH(OBJECT_DEFINITION(object_id)) > 2000 THEN 'MEDIUM'
        ELSE 'SIMPLE'
    END AS Complexity,
    (SELECT COUNT(DISTINCT referenced_id) FROM sys.sql_expression_dependencies WHERE referencing_id = object_id) AS [TableReferences],
    OBJECT_DEFINITION(object_id) AS [SourceCode]
FROM sys.procedures
WHERE name LIKE 'sp_%'
ORDER BY DATALENGTH(OBJECT_DEFINITION(object_id)) DESC;

-- ============================================================================
-- DATA DEPENDENCY ANALYSIS
-- ============================================================================

-- Which tables are most referenced?
SELECT TOP 10
    OBJECT_NAME(referenced_id) AS [TableName],
    COUNT(DISTINCT referencing_id) AS [ReferencedByCount],
    STRING_AGG(DISTINCT OBJECT_NAME(referencing_id), ', ') AS [ReferencedBy]
FROM sys.sql_expression_dependencies
WHERE OBJECTPROPERTY(referenced_id, 'IsTable') = 1
GROUP BY referenced_id
ORDER BY ReferencedByCount DESC;

-- Which tables are modified?
SELECT TOP 10
    t.name AS [TableName],
    (SELECT COUNT(DISTINCT referencing_id) 
     FROM sys.sql_expression_dependencies sed 
     JOIN sys.procedures p ON sed.referencing_id = p.object_id
     WHERE sed.referenced_id = t.object_id) AS [ModifiedByProcedures],
    CAST(ISNULL((SELECT SUM(row_count) FROM sys.dm_db_partition_stats WHERE object_id = t.object_id AND index_id IN (0,1)), 0) AS BIGINT) AS [RowCount]
FROM sys.tables t
ORDER BY [RowCount] DESC;

-- ============================================================================
-- IMPACT ANALYSIS FOR PROPOSED CHANGES
-- ============================================================================

-- Show full impact chain if we modify Orders table
-- (This is what change-impact-assessor should do)

WITH ImpactChain AS (
    -- Level 0: The object being changed
    SELECT 0 AS ImpactLevel, 'Orders' AS ObjectName, NULL AS ParentObject
    
    UNION ALL
    
    -- Level 1: Procedures that directly reference Orders
    SELECT 1, OBJECT_NAME(referencing_id), 'Orders'
    FROM sys.sql_expression_dependencies
    WHERE referenced_id = OBJECT_ID('dbo.Orders')
      AND OBJECTPROPERTY(referencing_id, 'IsProcedure') = 1
    
    UNION ALL
    
    -- Level 2: Procedures that call procedures that reference Orders
    SELECT 2, OBJECT_NAME(sed2.referencing_id), OBJECT_NAME(sed1.referencing_id)
    FROM sys.sql_expression_dependencies sed1
    JOIN sys.sql_expression_dependencies sed2 ON sed1.referencing_id = sed2.referenced_id
    WHERE sed1.referenced_id = OBJECT_ID('dbo.Orders')
      AND OBJECTPROPERTY(sed1.referencing_id, 'IsProcedure') = 1
      AND OBJECTPROPERTY(sed2.referencing_id, 'IsProcedure') = 1
)
SELECT * FROM ImpactChain ORDER BY ImpactLevel, ObjectName;

-- ============================================================================
-- DOCUMENTATION EXTRACTION
-- ============================================================================

-- Extract procedure information for documentation
SELECT 
    p.name AS [ProcedureName],
    OBJECT_DEFINITION(p.object_id) AS [SourceCode],
    (SELECT STRING_AGG(name + ' ' + system_type_name(user_type_id), ', ')
     FROM sys.parameters 
     WHERE object_id = p.object_id) AS [Parameters],
    'INSERT DOCUMENTATION HERE' AS [BusinessPurpose],
    'UNKNOWN' AS [Owner],
    (SELECT COUNT(DISTINCT referencing_id) FROM sys.sql_expression_dependencies WHERE referenced_id = p.object_id) AS [UsedByCount]
FROM sys.procedures p
WHERE p.name LIKE 'sp_%'
ORDER BY p.name;

-- ============================================================================
-- MODERNIZATION ROADMAP
-- ============================================================================

-- Identify quick wins: unused procedures that can be safely removed
SELECT 
    p.name AS [ProcedureName],
    'SAFE TO REMOVE' AS [Action],
    'No dependencies detected' AS [Reason]
FROM sys.procedures p
LEFT JOIN sys.sql_expression_dependencies sed ON sed.referenced_id = p.object_id
WHERE p.name LIKE 'sp_%'
  AND sed.referencing_id IS NULL
ORDER BY p.name;

-- Identify procedures that should be extracted to application
SELECT 
    p.name AS [ProcedureName],
    (SELECT COUNT(DISTINCT referenced_id) FROM sys.sql_expression_dependencies WHERE referencing_id = p.object_id) AS [Dependencies],
    'CANDIDATE FOR EXTRACTION' AS [Action],
    'Consider moving to application layer' AS [Reason]
FROM sys.procedures p
WHERE p.name LIKE 'sp_%'
  AND DATALENGTH(OBJECT_DEFINITION(p.object_id)) < 2000  -- Small procedures are easier to extract
ORDER BY DATALENGTH(OBJECT_DEFINITION(p.object_id));

