---
name: 'Alta Disponibilidad y Recuperación ante Desastres'
description: 'Skill para evaluar el estado de HA/DR en SQL Server: AlwaysOn, replicación, log shipping y failover'
---

# Alta Disponibilidad y Recuperación ante Desastres

## Propósito
Validar que la estrategia de HA/DR está operativa, sincronizada y alineada con los objetivos RTO/RPO del negocio.

## Entradas
- Instancia SQL Server con HA configurado
- Objetivos RTO/RPO declarados

## Salidas
- Estado actual de réplicas y sincronización
- RTO/RPO alcanzable vs objetivo
- Single points of failure identificados
- Runbook de failover
- Plan de mejora priorizado

## Pasos

### 1. Estado de AlwaysOn Availability Groups
```sql
SELECT
    ag.name AS grupo_disponibilidad,
    ar.replica_server_name AS replica,
    ar.availability_mode_desc AS modo,
    ar.failover_mode_desc AS failover,
    ars.role_desc AS rol,
    ars.synchronization_health_desc AS salud_sync,
    ars.connected_state_desc AS conexion
FROM sys.availability_groups ag
JOIN sys.availability_replicas ar ON ag.group_id = ar.group_id
JOIN sys.dm_hadr_availability_replica_states ars ON ar.replica_id = ars.replica_id;
```

### 2. Latencia de sincronización
```sql
SELECT
    db_name(drs.database_id) AS base_datos,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc,
    drs.log_send_queue_size,
    drs.log_send_rate,
    drs.redo_queue_size,
    drs.redo_rate,
    drs.last_commit_time
FROM sys.dm_hadr_database_replica_states drs
WHERE drs.is_local = 0;
```

### 3. Log shipping (si aplica)
```sql
SELECT
    primary_server, primary_database,
    secondary_server, secondary_database,
    last_backup_date, last_copied_date, last_restored_date,
    DATEDIFF(MINUTE, last_restored_date, GETDATE()) AS minutos_retraso
FROM msdb.dbo.log_shipping_monitor_secondary;
```

### 4. Validación de RTO/RPO
- Calcula RPO real basado en latencia de sincronización
- Estima RTO basado en historial de failover o tiempo de restore
- Contrasta con objetivos declarados
- Identifica gaps

## Checklist de Calidad
- [ ] Estado de réplicas verificado
- [ ] Latencia de sincronización medida
- [ ] RPO real calculado y comparado con objetivo
- [ ] Single points of failure documentados
- [ ] Runbook de failover actualizado
