# Patrón 10: Parameter Sniffing Oculto

**Categoría**: Rendimiento · Fiabilidad  
**Síntoma principal**: Queries que funcionan perfectamente en desarrollo y fallan en producción. El plan cacheado con parámetros atípicos destruye el rendimiento del caso general.

## El Problema

SQL Server cachea el plan de ejecución generado con los parámetros de la primera llamada. Si esa primera llamada tiene una distribución de datos atípica, el plan resultante puede ser catastrófico para el resto de llamadas.

```sql
CREATE PROCEDURE sp_GetOrders @CustomerID INT
AS
BEGIN
    SELECT OrderID, OrderDate, Total
    FROM Orders
    WHERE CustomerID = @CustomerID
END

-- Escenario real:
-- 1ª llamada: CustomerID = 9999 (cuenta de prueba, 3 pedidos en 5 años)
--   → SQL Server genera plan con Index Seek (estimación: ~3 filas)
--   → Plan se cachea
--
-- 2ª llamada: CustomerID = 1 (Amazon de tu sistema, 2.3 millones de pedidos)
--   → Usa el mismo plan: Index Seek sobre 2.3M filas
--   → Debería ser Table Scan o Index Scan, pero usa el plan de 3 filas
--   → Query que debería tardar 2s tarda 8 minutos
--
-- Síntoma: "Funciona perfecto en dev, en prod a veces va lento sin razón"
-- Causa: dev tiene pocos datos homogéneos; prod tiene distribución muy sesgada
```

## Impacto

- Regresiones de rendimiento aleatorias: el síntoma aparece y desaparece con `sp_recompile` o reinicios
- Queries con alta variación de duración (misma query: 200ms a veces, 8min otras)
- Waits de CPU o IO que no correlacionan con la query visible en ese momento
- Muy difícil de diagnosticar sin Query Store habilitado

## Señales de Detección

```sql
-- Query Store: SPs con alta variación de duración (posible parameter sniffing)
SELECT TOP 20
    OBJECT_NAME(q.object_id) AS sp_name,
    COUNT(DISTINCT p.plan_id) AS num_planes,
    MIN(rs.min_duration) / 1000 AS min_ms,
    MAX(rs.max_duration) / 1000 AS max_ms,
    MAX(rs.max_duration) / NULLIF(MIN(rs.min_duration), 0) AS ratio_variacion
FROM sys.query_store_query q
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
WHERE q.object_id IS NOT NULL
GROUP BY q.object_id
HAVING MAX(rs.max_duration) / NULLIF(MIN(rs.min_duration), 0) > 10
ORDER BY ratio_variacion DESC

-- Múltiples planes para el mismo SP (síntoma de inestabilidad)
SELECT OBJECT_NAME(q.object_id), COUNT(DISTINCT p.plan_id) AS planes
FROM sys.query_store_query q
JOIN sys.query_store_plan p ON q.query_id = p.query_id
WHERE q.object_id IS NOT NULL
GROUP BY q.object_id
HAVING COUNT(DISTINCT p.plan_id) > 3
ORDER BY planes DESC
```

## Estrategia de Modernización (por orden de invasividad)

| Opción | Cuándo usar | Impacto |
|--------|-------------|---------|
| `OPTION (OPTIMIZE FOR UNKNOWN)` | Distribución muy sesgada, plan genérico aceptable | Bajo |
| Variables locales en lugar de parámetros | Rompe el sniffing sin hints | Bajo-medio |
| `OPTION (RECOMPILE)` | Query rápida, parámetros muy variables, no en loop | Medio (CPU en compilación) |
| Múltiples SPs especializados | Distribuciones completamente distintas por caso | Alto |
| Plan forcing en Query Store | Regresión crítica ya identificada | Bajo (solo en SQL 2016+) |

## Prerequisito Importante

**Query Store debe estar habilitado** para diagnosticar este patrón con precisión. En Azure SQL está activo por defecto. En SQL Server on-premises: `ALTER DATABASE MiDB SET QUERY_STORE = ON`.

## Agentes Relacionados

- **Performance Bottleneck Analyzer** → Detecta variaciones de duración como síntoma
- **Query Optimizer** → Evalúa la mitigación óptima para cada SP afectado
- **Monitoring Baseline Advisor** → Establece umbrales de alerta sobre variación de duración
