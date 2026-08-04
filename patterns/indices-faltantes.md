# Patrón 6: Índices Faltantes o Desactualizados

**Categoría**: Rendimiento · Estabilidad  
**Síntoma principal**: Algunas tablas tienen índices perfectos; otras críticas no tienen ninguno. El rendimiento es impredecible.

## El Problema

El esquema crece sin una estrategia coherente de indexación. Tablas nuevas o menos visibles quedan sin índices mientras las principales están sobreindexadas.

```sql
-- Tabla principal: bien indexada
CREATE NONCLUSTERED INDEX IX_Orders_Status   ON Orders(Status)     INCLUDE (OrderDate, Total)
CREATE NONCLUSTERED INDEX IX_Orders_Date     ON Orders(OrderDate)  INCLUDE (Status, Total)
CREATE NONCLUSTERED INDEX IX_Orders_Customer ON Orders(CustomerID) INCLUDE (Status, Amount)

-- Tabla de detalle que se consulta constantemente: cero índices
CREATE TABLE OrderDetails (
    OrderID   INT,
    ProductID INT,
    Quantity  INT,
    Price     DECIMAL(10,2)
    -- Sin PK, sin índice clustered, sin nonclustered
    -- Cada JOIN con Orders → full table scan
    -- Con 10M filas: cada query tarda segundos innecesariamente
)
```

## Impacto

- Rendimiento de queries impredecible y que empeora con el crecimiento de datos
- El equipo DBA en modo bombero: apagando incendios en lugar de planificar
- Las estadísticas desactualizadas hacen que el optimizador elija planes subóptimos
- Los intentos de modernización fallan por regresiones de rendimiento no anticipadas

## Señales de Detección

```sql
-- Índices faltantes recomendados por el optimizador
SELECT TOP 20
    d.statement AS tabla,
    d.equality_columns, d.inequality_columns, d.included_columns,
    s.avg_total_user_cost * s.avg_user_impact * (s.user_seeks + s.user_scans) AS impacto_estimado
FROM sys.dm_db_missing_index_details d
JOIN sys.dm_db_missing_index_groups g ON d.index_handle = g.index_handle
JOIN sys.dm_db_missing_index_group_stats s ON g.index_group_handle = s.group_handle
ORDER BY impacto_estimado DESC

-- Tablas sin ningún índice (heaps)
SELECT t.name AS tabla, SUM(p.rows) AS filas
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
LEFT JOIN sys.indexes i ON t.object_id = i.object_id AND i.index_id > 0
WHERE i.object_id IS NULL
GROUP BY t.name
HAVING SUM(p.rows) > 10000
ORDER BY filas DESC
```

## Estrategia de Modernización

1. Usa `sys.dm_db_missing_index_details` como punto de partida, no como verdad absoluta
2. Valida sugerencias con planes de ejecución reales (no solo estimados)
3. Crea y prueba en staging antes de producción con SET STATISTICS TIME, IO ON
4. Monitoriza fragmentación mensualmente: `sys.dm_db_index_physical_stats`
5. Revisa índices duplicados o no usados que penalizan escrituras sin aportar lecturas

## Agentes Relacionados

- **Performance Bottleneck Analyzer** → Identifica queries con full scans problemáticos
- **Query Optimizer** → Propone índices específicos con análisis de coste/beneficio
- **Proactive Maintenance Advisor** → Incluye rebuild/reorganize en plan de mantenimiento
