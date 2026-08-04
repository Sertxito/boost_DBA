# Patrón 13: Dynamic SQL Sin Parametrizar

**Categoría**: Seguridad · Rendimiento  
**Síntoma principal**: SQL construido por concatenación de strings con valores de entrada. Riesgo crítico de SQL Injection + contaminación del plan cache.

## El Problema

Construir sentencias SQL concatenando valores de usuario o parámetros directamente en la cadena. Un usuario malicioso puede inyectar SQL arbitrario. Además, cada valor distinto genera un plan diferente en caché, desperdiciando memoria.

```sql
-- PELIGROSO: SQL Injection + plan cache pollution
CREATE PROCEDURE sp_SearchProducts @SearchTerm NVARCHAR(100)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX)
    
    -- Concatenación directa: cualquier valor se ejecuta como SQL
    SET @SQL = 'SELECT * FROM Products WHERE Name LIKE ''%' + @SearchTerm + '%'''
    
    -- Ataque: @SearchTerm = "'; DROP TABLE Products; --"
    -- SQL resultante: SELECT * FROM Products WHERE Name LIKE '%'; DROP TABLE Products; --%'
    -- Resultado: tabla eliminada, datos perdidos
    
    -- Ataque más sutil: @SearchTerm = "' UNION SELECT username, password FROM Users; --"
    -- Resultado: credenciales expuestas en el resultado de la query
    
    EXEC (@SQL)
    -- Además: 10.000 búsquedas distintas = 10.000 planes en sys.dm_exec_cached_plans
END

-- CORRECTO: sp_executesql con parámetros tipados
CREATE PROCEDURE sp_SearchProducts_Safe @SearchTerm NVARCHAR(100)
AS
BEGIN
    DECLARE @SQL    NVARCHAR(MAX)
    DECLARE @Params NVARCHAR(200)
    
    SET @SQL    = N'SELECT * FROM Products WHERE Name LIKE @Term'
    SET @Params = N'@Term NVARCHAR(102)'
    
    -- El valor se pasa como dato, nunca como código SQL
    -- Imposible inyectar: el motor trata @Term como string literal, no como SQL
    -- Un solo plan reutilizable para cualquier valor de búsqueda
    EXEC sp_executesql @SQL, @Params, @Term = N'%' + @SearchTerm + N'%'
END
```

## Impacto

- **Seguridad crítica**: SQL Injection permite leer, modificar, eliminar datos o ejecutar comandos del sistema
- **OWASP A03:2021 – Injection**: vulnerabilidad más prevalente en aplicaciones de datos
- **Plan cache pollution**: miles de planes ad-hoc consumen memoria del buffer pool que debería estar en datos
- **Difícil auditar**: el SQL real solo se conoce en runtime, no en el código estático
- **Privilegio mínimo imposible**: si el SP puede ejecutar SQL arbitrario, no puedes restringir permisos

## Señales de Detección

```sql
-- SPs con SQL dinámico (candidatos a revisar)
SELECT o.name, m.definition
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.type = 'P'
  AND (m.definition LIKE '%EXEC (%'          -- EXEC con concatenación
    OR m.definition LIKE '%EXEC(@%'          -- EXEC con variable
    OR m.definition LIKE '%sp_executesql%')  -- puede ser correcto o no
ORDER BY o.name

-- Plan cache contaminado: muchos planes similares de uso único
SELECT TOP 20
    LEFT(text, 100) AS sql_snippet,
    COUNT(*) AS num_planes,
    SUM(usecounts) AS total_ejecuciones
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) t
WHERE cp.objtype = 'Adhoc'
  AND cp.usecounts = 1  -- plan de un solo uso: señal de concatenación
GROUP BY LEFT(text, 100)
HAVING COUNT(*) > 5
ORDER BY num_planes DESC
```

## Qué Revisar en Cada SP con SQL Dinámico

1. ¿El SQL se construye por concatenación de strings? → **Riesgo de inyección**
2. ¿Los valores externos se pasan como parámetros a `sp_executesql`? → **Correcto**
3. ¿El SQL dinámico es necesario (columnas o tablas variables) o podría ser estático? → Si puede ser estático, eliminar el dinamismo

## Estrategia de Modernización

1. Inventaría todos los SPs con `EXEC(` o `EXEC(@` → revisar si concatenan parámetros de entrada
2. Migra a `sp_executesql` con parámetros tipados en todos los casos donde el valor varía
3. Para construcción dinámica de filtros opcionales: usa patrón `WHERE (@Param IS NULL OR Column = @Param)` para evitar dinamismo
4. Habilita `optimize for ad hoc workloads` mientras migras: `sp_configure 'optimize for ad hoc workloads', 1`
5. Aplica principio de mínimo privilegio: los SPs no deben tener permisos que el SQL dinámico no necesite

## Agentes Relacionados

- **DBA Reliability & Security Advisor** → Audita vulnerabilidades de inyección y gestión de permisos
- **Query Optimizer** → Identifica contaminación del plan cache y propone mitigación
- **Migration Script Generator** → Genera versiones parametrizadas de los SPs afectados
