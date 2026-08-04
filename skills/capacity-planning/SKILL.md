---
name: 'Capacity Planning y Proyecciones de Crecimiento'
description: 'Skill para analizar tendencias de crecimiento y proyectar necesidades de almacenamiento y recursos'
---

# Capacity Planning y Proyecciones de Crecimiento

## Propósito
Anticipar problemas de capacidad antes de que ocurran mediante análisis de tendencias y proyecciones basadas en datos históricos.

## Entradas
- Base de datos o instancia objetivo
- Horizonte de proyección (3, 6, 12 meses)
- Datos históricos de tamaño (si están disponibles)

## Salidas
- Tamaño actual por base de datos y tabla top 20
- Tasa de crecimiento mensual estimada
- Proyección de almacenamiento a horizonte solicitado
- Riesgos de capacidad identificados
- Recomendaciones de configuración

## Pasos

### 1. Inventario de almacenamiento actual
```sql
SELECT
    DB_NAME() AS base_datos,
    name AS fichero,
    physical_name,
    size * 8 / 1024 AS size_mb,
    max_size,
    growth,
    is_percent_growth
FROM sys.database_files;
```

### 2. Tablas más grandes
```sql
SELECT TOP 20
    OBJECT_NAME(i.object_id) AS tabla,
    SUM(a.total_pages) * 8 / 1024 AS total_mb,
    SUM(a.used_pages) * 8 / 1024 AS used_mb,
    SUM(p.rows) AS filas
FROM sys.indexes i
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
GROUP BY i.object_id
ORDER BY total_mb DESC;
```

### 3. Configuración de autogrowth
```sql
SELECT
    name, physical_name,
    size * 8 / 1024 AS size_mb,
    CASE is_percent_growth
        WHEN 1 THEN CAST(growth AS VARCHAR) + '%'
        ELSE CAST(growth * 8 / 1024 AS VARCHAR) + ' MB'
    END AS autogrowth,
    CASE WHEN growth = 0 THEN 'RIESGO: sin autogrowth'
         WHEN is_percent_growth = 1 AND growth >= 10 THEN 'RIESGO: % puede ser excesivo'
         ELSE 'OK'
    END AS evaluacion
FROM sys.database_files;
```

### 4. Proyección y recomendaciones
- Calcula tasa de crecimiento con datos disponibles
- Proyecta a horizonte solicitado
- Identifica cuándo se alcanza el 80% de capacidad

## Checklist de Calidad
- [ ] Autogrowth revisado en todos los ficheros
- [ ] Top 20 tablas por tamaño identificadas
- [ ] Proyección documentada con supuestos explícitos
- [ ] Riesgos de capacidad priorizados
