---
name: 'Monitorización y Baseline de Rendimiento'
description: 'Skill para establecer baseline de comportamiento normal y detectar desviaciones en SQL Server'
---

# Monitorización y Baseline de Rendimiento

## Propósito
Definir qué es "normal" en el sistema y detectar cuándo el comportamiento actual se desvía, antes de que impacte a usuarios.

## Entradas
- Instancia SQL Server objetivo
- Ventana de tiempo de referencia (baseline)
- Métricas a monitorizar

## Salidas
- Baseline de métricas clave por franja horaria
- Desviaciones respecto al baseline actual
- Umbrales de alerta recomendados
- Informe de salud comparativo

## Pasos

### 1. Métricas de sesiones y conexiones
```sql
SELECT
    login_name,
    COUNT(*) AS conexiones,
    SUM(CASE WHEN status = 'running' THEN 1 ELSE 0 END) AS activas,
    SUM(CASE WHEN blocking_session_id > 0 THEN 1 ELSE 0 END) AS bloqueadas
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
GROUP BY login_name
ORDER BY conexiones DESC;
```

### 2. Baseline de waits por franja horaria
```sql
SELECT
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
    'SLEEP_TASK','BROKER_TO_FLUSH','BROKER_TASK_STOP',
    'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE',
    'FT_IFTS_SCHEDULER_IDLE_WAIT','HADR_FILESTREAM_IOMGR_IOCOMPLETION',
    'HADR_WORK_QUEUE','LAZYWRITER_SLEEP','LOGMGR_QUEUE',
    'ONDEMAND_TASK_QUEUE','REQUEST_FOR_DEADLOCK_SEARCH',
    'RESOURCE_QUEUE','SERVER_IDLE_CHECK','SLEEP_DBSTARTUP',
    'SLEEP_DCOMSTARTUP','SLEEP_MASTERDBREADY','SLEEP_MASTERMDREADY',
    'SLEEP_MASTERUPGRADED','SLEEP_MSDBSTARTUP','SLEEP_TEMPDBSTARTUP',
    'SNI_HTTP_ACCEPT','SP_SERVER_DIAGNOSTICS_SLEEP','SQLTRACE_BUFFER_FLUSH',
    'WAITFOR','XE_DISPATCHER_WAIT','XE_TIMER_EVENT'
)
ORDER BY wait_time_ms DESC;
```

### 3. Presión de memoria
```sql
SELECT
    physical_memory_in_use_kb / 1024 AS mem_uso_mb,
    page_fault_count,
    memory_utilization_percentage
FROM sys.dm_os_process_memory;
```

### 4. Definición de umbrales y alertas
- Compara métricas actuales con baseline capturado
- Propone umbrales basados en percentil 95 del baseline
- Lista las métricas que más se desvían

## Checklist de Calidad
- [ ] Baseline capturado en periodo representativo
- [ ] Umbrales definidos por métrica
- [ ] Anomalías documentadas con contexto
- [ ] Recomendaciones de herramienta de alerting
