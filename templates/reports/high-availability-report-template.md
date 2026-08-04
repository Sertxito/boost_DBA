---
name: 'Informe de Alta Disponibilidad y DR'
---

# Informe de Alta Disponibilidad y DR

**Instancia:** ___  **Solución HA:** AlwaysOn / Replicación / Log Shipping  **Fecha:** ___

## Resumen
- Estado general HA: SALUDABLE / DEGRADADO / CRÍTICO
- RPO objetivo: ___ | RPO real: ___
- RTO objetivo: ___ | RTO estimado: ___
- Single points of failure identificados: ___

## Estado de Réplicas

| Réplica | Rol | Modo sync | Estado conexión | Latencia redo | Salud |
|---------|-----|-----------|----------------|--------------|-------|
| ___ | PRIMARIO | — | — | — | ✅ |
| ___ | SECUNDARIO | SYNC / ASYNC | CONNECTED | ___ ms | ✅ / ⚠️ |

## Gaps de RPO/RTO

| Objetivo | Declarado | Real/Estimado | Gap | Riesgo |
|----------|----------|--------------|-----|--------|
| RPO | ___ min | ___ min | ___ min | BAJO / MEDIO / ALTO |
| RTO | ___ min | ___ min | ___ min | BAJO / MEDIO / ALTO |

## Single Points of Failure

| Componente | Riesgo | Mitigación propuesta | Autonomía |
|-----------|--------|---------------------|-----------|
| ___ | ALTO | ___ | 🟡 Confirmación |

## Runbook de Failover — Resumen
1. Verificar estado de réplica secundaria: `SELECT * FROM sys.dm_hadr_availability_replica_states`
2. Confirmar lag de redo aceptable
3. **[🔴 ACCIÓN HUMANA]** Ejecutar failover manual: `ALTER AVAILABILITY GROUP [...] FAILOVER`
4. Verificar redirección de aplicaciones
5. Validar estado post-failover

## Próxima Revisión
- Fecha prueba de failover programada: ___
- Fecha siguiente revisión HA: ___
