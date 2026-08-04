---
name: 'Análisis de Jobs y Automatización SQL Agent'
description: 'Skill para auditar SQL Agent jobs, detectar fallos y optimizar schedules'
---

# Análisis de Jobs y Automatización SQL Agent

## Propósito
Dar visibilidad completa sobre los jobs de SQL Agent: inventario, tasa de éxito, conflictos de schedule y jobs obsoletos.

## Entradas
- Instancia SQL Server objetivo
- Ventana temporal de análisis (default: últimos 30 días)

## Salidas
- Inventario completo de jobs con estado y métricas
- Jobs fallidos o con alta tasa de error
- Conflictos de schedule detectados
- Jobs obsoletos o sin ejecución reciente
- Recomendaciones de reorganización

## Pasos

### 1. Inventario de jobs
```sql
SELECT
    j.name AS job,
    j.enabled,
    c.name AS categoria,
    l.name AS propietario,
    j.date_created,
    j.date_modified
FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.syscategories c ON j.category_id = c.category_id
LEFT JOIN sys.syslogins l ON j.owner_sid = l.sid
ORDER BY j.name;
```

### 2. Historial de ejecuciones recientes
```sql
SELECT TOP 100
    j.name AS job,
    h.step_name,
    CASE h.run_status
        WHEN 0 THEN 'FALLO' WHEN 1 THEN 'OK'
        WHEN 2 THEN 'REINTENTO' WHEN 3 THEN 'CANCELADO'
    END AS estado,
    msdb.dbo.agent_datetime(h.run_date, h.run_time) AS fecha_inicio,
    h.run_duration AS duracion_hhmmss,
    h.message
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id
WHERE h.step_id = 0
ORDER BY h.run_date DESC, h.run_time DESC;
```

### 3. Jobs sin ejecución reciente
```sql
SELECT
    j.name AS job,
    j.enabled,
    MAX(msdb.dbo.agent_datetime(h.run_date, h.run_time)) AS ultima_ejecucion,
    DATEDIFF(DAY, MAX(msdb.dbo.agent_datetime(h.run_date, h.run_time)), GETDATE()) AS dias_inactivo
FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id AND h.step_id = 0
GROUP BY j.job_id, j.name, j.enabled
HAVING MAX(msdb.dbo.agent_datetime(h.run_date, h.run_time)) < DATEADD(DAY, -30, GETDATE())
    OR MAX(h.run_date) IS NULL
ORDER BY dias_inactivo DESC;
```

### 4. Detección de solapamientos de schedule
- Identifica jobs con schedule que coinciden en ventana horaria
- Estima duración media por job
- Detecta posibles conflictos de recursos

## Checklist de Calidad
- [ ] Todos los jobs inventariados con propietario
- [ ] Jobs fallidos en últimos 30 días identificados
- [ ] Jobs inactivos >30 días documentados
- [ ] Solapamientos de schedule revisados
- [ ] Recomendaciones con justificación
