---
name: 'Mantenimiento Proactivo de Índices y Estadísticas'
description: 'Skill para detectar fragmentación, estadísticas obsoletas e índices problemáticos en SQL Server'
---

# Mantenimiento Proactivo de Índices y Estadísticas

## Propósito
Identificar objetos degradados que impactan el rendimiento de planes de ejecución y generar comandos de mantenimiento priorizados.

## Entradas
- Base de datos objetivo
- Umbral de fragmentación configurable (default: rebuild >30%, reorganize >10%)
- Lista de tablas críticas (opcional, para priorizar)

## Salidas
- Lista de índices a rebuild/reorganize con prioridad
- Estadísticas desactualizadas ordenadas por impacto
- Índices duplicados, solapados o sin uso
- Script de mantenimiento listo para ejecutar
- Schedule recomendado

## Pasos

### 1. Fragmentación de índices
```sql
SELECT
    OBJECT_NAME(ips.object_id) AS tabla,
    i.name AS indice,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    CASE
        WHEN ips.avg_fragmentation_in_percent > 30 THEN 'REBUILD'
        WHEN ips.avg_fragmentation_in_percent > 10 THEN 'REORGANIZE'
        ELSE 'OK'
    END AS accion
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

### 2. Estadísticas desactualizadas
```sql
SELECT
    OBJECT_NAME(s.object_id) AS tabla,
    s.name AS estadistica,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled,
    DATEDIFF(DAY, sp.last_updated, GETDATE()) AS dias_sin_actualizar
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE DATEDIFF(DAY, sp.last_updated, GETDATE()) > 7
ORDER BY dias_sin_actualizar DESC;
```

### 3. Índices sin uso
```sql
SELECT
    OBJECT_NAME(i.object_id) AS tabla,
    i.name AS indice,
    ius.user_seeks, ius.user_scans, ius.user_lookups, ius.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id AND i.index_id = ius.index_id
    AND ius.database_id = DB_ID()
WHERE i.type > 0
  AND ISNULL(ius.user_seeks,0) + ISNULL(ius.user_scans,0) + ISNULL(ius.user_lookups,0) = 0
ORDER BY ISNULL(ius.user_updates,0) DESC;
```

### 4. Priorización y script de mantenimiento
- Ordena por tablas críticas primero
- Genera ALTER INDEX ... REBUILD / REORGANIZE
- Estima duración y ventana necesaria

## Checklist de Calidad
- [ ] Fragmentación revisada en todos los índices con más de 1000 páginas
- [ ] Estadísticas con más de 7 días identificadas
- [ ] Índices sin uso documentados antes de proponer eliminación
- [ ] Script con transacción y estimación de tiempo
