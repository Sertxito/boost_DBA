---
name: 'Referencias Oficiales de Bases de Datos'
description: 'Fuentes de verdad oficiales por plataforma para validar recomendaciones antes de tomar decisiones'
---

# Referencias Oficiales — Fuentes de Verdad por Plataforma

Toda recomendación de Boost DBA debe contrastarse con la documentación oficial de la plataforma objetivo antes de presentarse como acción definitiva. Este documento centraliza los enlaces canónicos por área técnica.

---

## SQL Server (On-Premises)

### Rendimiento y Diagnóstico
- [sys.dm_exec_query_stats](https://learn.microsoft.com/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql)
- [sys.dm_os_wait_stats](https://learn.microsoft.com/sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql)
- [sys.dm_db_index_physical_stats](https://learn.microsoft.com/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql)
- [Query Store](https://learn.microsoft.com/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store)
- [Guía de índices](https://learn.microsoft.com/sql/relational-databases/indexes/indexes)

### Seguridad y Permisos
- [Principio de mínimo privilegio](https://learn.microsoft.com/sql/relational-databases/security/authentication-access/database-level-roles)
- [Auditoría SQL Server](https://learn.microsoft.com/sql/relational-databases/security/auditing/sql-server-audit-database-engine)
- [Cifrado de datos en reposo (TDE)](https://learn.microsoft.com/sql/relational-databases/security/encryption/transparent-data-encryption)
- [Always Encrypted](https://learn.microsoft.com/sql/relational-databases/security/encryption/always-encrypted-database-engine)

### Alta Disponibilidad
- [AlwaysOn Availability Groups](https://learn.microsoft.com/sql/database-engine/availability-groups/windows/always-on-availability-groups-sql-server)
- [Log Shipping](https://learn.microsoft.com/sql/database-engine/log-shipping/about-log-shipping-sql-server)
- [Database Mirroring (deprecado)](https://learn.microsoft.com/sql/database-engine/database-mirroring/database-mirroring-sql-server)

### Mantenimiento
- [Guía de mantenimiento de índices](https://learn.microsoft.com/sql/relational-databases/indexes/reorganize-and-rebuild-indexes)
- [UPDATE STATISTICS](https://learn.microsoft.com/sql/t-sql/statements/update-statistics-transact-sql)
- [SQL Server Agent](https://learn.microsoft.com/sql/ssms/agent/sql-server-agent)

---

## Azure SQL Database / Managed Instance

### Rendimiento y Monitorización
- [Intelligent Query Processing](https://learn.microsoft.com/azure/azure-sql/database/intelligent-query-processing-intelligent-plan-feedback)
- [Automatic tuning](https://learn.microsoft.com/azure/azure-sql/database/automatic-tuning-overview)
- [Query Performance Insight](https://learn.microsoft.com/azure/azure-sql/database/query-performance-insight-use)
- [Database Advisor](https://learn.microsoft.com/azure/azure-sql/database/database-advisor-implement-performance-recommendations)
- [Métricas y alertas](https://learn.microsoft.com/azure/azure-sql/database/monitor-tune-overview)

### Seguridad
- [Microsoft Defender for SQL](https://learn.microsoft.com/azure/azure-sql/database/azure-defender-for-sql)
- [Advanced Threat Protection](https://learn.microsoft.com/azure/azure-sql/database/threat-detection-configure)
- [Azure AD Authentication](https://learn.microsoft.com/azure/azure-sql/database/authentication-aad-overview)
- [Managed Identity](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-user-assigned-managed-identity)

### Alta Disponibilidad y DR
- [Grupos de conmutación por error](https://learn.microsoft.com/azure/azure-sql/database/auto-failover-group-overview)
- [Geo-replication](https://learn.microsoft.com/azure/azure-sql/database/active-geo-replication-overview)
- [SLA de Azure SQL](https://azure.microsoft.com/support/legal/sla/azure-sql-database/)

### Elastic y Escalado
- [Elastic pools](https://learn.microsoft.com/azure/azure-sql/database/elastic-pool-overview)
- [Serverless compute tier](https://learn.microsoft.com/azure/azure-sql/database/serverless-tier-overview)
- [Hyperscale](https://learn.microsoft.com/azure/azure-sql/database/service-tier-hyperscale)

---

## AWS RDS / Aurora (SQL Server, MySQL, PostgreSQL)

### Rendimiento
- [Performance Insights](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html)
- [Enhanced Monitoring](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html)
- [Query tuning Aurora MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Managing.Tuning.html)
- [Aurora PostgreSQL best practices](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.BestPractices.html)

### Seguridad
- [RDS security best practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.Security.html)
- [IAM database authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html)
- [Encryption at rest](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html)

### Alta Disponibilidad
- [Multi-AZ deployments](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)
- [Aurora Global Database](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database.html)
- [Automated backups y PITR](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html)

---

## PostgreSQL

### Rendimiento y Diagnóstico
- [EXPLAIN / EXPLAIN ANALYZE](https://www.postgresql.org/docs/current/using-explain.html)
- [pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html)
- [Autovacuum](https://www.postgresql.org/docs/current/routine-vacuuming.html)
- [Índices en PostgreSQL](https://www.postgresql.org/docs/current/indexes.html)
- [Query planner](https://www.postgresql.org/docs/current/planner-optimizer.html)

### Seguridad
- [Roles y privilegios](https://www.postgresql.org/docs/current/user-manag.html)
- [Row Security Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [SSL/TLS](https://www.postgresql.org/docs/current/ssl-tcp.html)
- [pg_audit](https://github.com/pgaudit/pgaudit)

### Alta Disponibilidad
- [Streaming Replication](https://www.postgresql.org/docs/current/warm-standby.html)
- [Logical Replication](https://www.postgresql.org/docs/current/logical-replication.html)
- [Patroni (HA framework)](https://patroni.readthedocs.io/)

---

## Azure Cosmos DB

### Rendimiento y Modelado
- [Partitioning best practices](https://learn.microsoft.com/azure/cosmos-db/partitioning-overview)
- [Request Units (RU)](https://learn.microsoft.com/azure/cosmos-db/request-units)
- [Indexing policies](https://learn.microsoft.com/azure/cosmos-db/index-policy)
- [Query optimization](https://learn.microsoft.com/azure/cosmos-db/nosql/query/getting-started)

### Seguridad
- [RBAC para Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/role-based-access-control)
- [Cifrado y cumplimiento](https://learn.microsoft.com/azure/cosmos-db/database-encryption-at-rest)
- [Private Endpoints](https://learn.microsoft.com/azure/cosmos-db/how-to-configure-private-endpoints)

### Alta Disponibilidad y DR
- [Multi-region writes](https://learn.microsoft.com/azure/cosmos-db/high-availability)
- [Consistency levels](https://learn.microsoft.com/azure/cosmos-db/consistency-levels)
- [Backup y restore](https://learn.microsoft.com/azure/cosmos-db/continuous-backup-restore-introduction)

---

## Regla de Uso en Boost DBA

Antes de emitir cualquier recomendación que implique un cambio de configuración, índice, query o arquitectura, el agente debe:

1. Contrastar con la referencia oficial de la plataforma objetivo.
2. Citar la fuente en la recomendación.
3. Indicar si la recomendación aplica a la versión específica del motor.
4. Señalar si existe comportamiento diferente entre versiones o tiers.
