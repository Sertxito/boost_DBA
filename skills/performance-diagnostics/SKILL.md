---
name: 'Diagnostico de Rendimiento SQL Server'
description: 'Skill para detectar cuellos de botella con DMVs y Query Store'
---

# Diagnostico de Rendimiento SQL Server

## Proposito
Identificar causas raiz de degradacion de rendimiento en SQL Server usando evidencia tecnica reproducible.

## Entradas
- Base de datos objetivo
- Ventana de tiempo del problema
- Sintoma principal (CPU alta, timeout, bloqueos, lentitud)

## Salidas
- Top consultas por impacto
- Cuellos de botella priorizados
- Hipotesis de causa raiz
- Plan de mitigacion y validacion

## Pasos

### 1. Wait Stats principales
```sql
SELECT TOP 20 wait_type, waiting_tasks_count, wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE 'SLEEP%'
ORDER BY wait_time_ms DESC;
```

### 2. Top consultas por CPU
```sql
SELECT TOP 20
    qs.total_worker_time AS total_cpu,
    qs.execution_count,
    qs.total_elapsed_time,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
      ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
      ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) + 1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.total_worker_time DESC;
```

### 3. Bloqueos activos
```sql
SELECT
    r.session_id,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0;
```

### 4. Hipotesis y priorizacion
- Clasifica hallazgos en alto, medio, bajo impacto
- Asigna accion y riesgo por cada hallazgo

### 5. Plan de validacion
- Define metricas antes/despues
- Define rollback por accion

## Checklist de Calidad
- [ ] Hallazgos con evidencia SQL
- [ ] Priorizacion por impacto/esfuerzo
- [ ] Mitigaciones con riesgo estimado
- [ ] Criterio de exito medible
