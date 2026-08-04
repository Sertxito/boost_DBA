# Patrón 7: Sin Pista de Auditoría ni Historial de Cambios

**Categoría**: Gobierno · Cumplimiento · Trazabilidad  
**Síntoma principal**: Nadie puede decir quién cambió qué, cuándo ni por qué. Las "versiones" son tablas backup con nombres creativos.

## El Problema

Los cambios de esquema y datos se realizan sin control de versiones, sin registro de modificaciones y sin auditoría. El historial vive en la cabeza de alguien o no existe.

```sql
-- El procedimiento fue modificado 6 veces. Nadie sabe por quién ni cuándo.
-- El "control de versiones" son tablas backup con nombres ad hoc:
CREATE TABLE OrdersBackup_v1    (...)  -- ¿qué cambió respecto al original?
CREATE TABLE OrdersBackup_v2    (...)  -- ¿cuándo? ¿por qué?
CREATE TABLE OrdersBackup_2024  (...)  -- ¿cuál es la diferente con v2?
CREATE TABLE OrdersBackup_Final (...)  -- ¿cuántos "Final" hay?

-- Tablas de datos sin columnas de auditoría:
CREATE TABLE Orders (
    OrderID   INT PRIMARY KEY,
    Total     DECIMAL(10,2),
    Status    VARCHAR(20)
    -- Sin CreatedBy, CreatedAt, ModifiedBy, ModifiedAt
    -- Si un registro cambia: imposible saber quién, cuándo, de qué valor a qué valor
)
```

## Impacto

- Imposible hacer rollback selectivo si algo se rompe
- No hay forma de entender por qué se tomó una decisión de diseño
- Riesgo de cumplimiento: sin auditoría, no puedes demostrar quién accedió o modificó datos sensibles
- Cuando la persona que hizo el cambio se va, el conocimiento desaparece con ella

## Señales de Detección

```sql
-- Tablas con patrón "backup" en el nombre (anti-patrón de versionado)
SELECT name, create_date, modify_date
FROM sys.tables
WHERE name LIKE '%backup%' OR name LIKE '%_v[0-9]%' OR name LIKE '%_old%' OR name LIKE '%_copy%'
ORDER BY create_date DESC

-- Tablas sin columnas de auditoría básicas
SELECT t.name
FROM sys.tables t
WHERE t.object_id NOT IN (
    SELECT object_id FROM sys.columns
    WHERE name IN ('CreatedAt','CreatedBy','ModifiedAt','ModifiedBy','UpdatedAt')
)
AND t.name NOT LIKE '%Backup%'
ORDER BY t.name
```

## Estrategia de Modernización

1. Mueve el esquema a control de versiones (Flyway, Liquibase, SSDT) con mensajes de commit descriptivos
2. Añade columnas de auditoría `CreatedBy, CreatedAt, ModifiedBy, ModifiedAt` a tablas de negocio
3. Para auditoría de datos críticos: implementa tabla de historial o usa **Temporal Tables** (SQL Server 2016+)
4. Elimina las tablas `*Backup*` tras confirmar que el historial real está en control de versiones
5. Define política de retención y acceso al histórico de auditoría

## Agentes Relacionados

- **DBA Reliability & Security Advisor** → Evalúa requisitos de cumplimiento y auditoría
- **DB Documentation Generator** → Documenta el estado actual antes de migrar a control de versiones
- **Migration Script Generator** → Genera scripts DDL con rollback para añadir columnas de auditoría
