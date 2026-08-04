---
name: 'Generación de Scripts de Migración Seguros'
description: 'Skill para producir scripts DDL/DML con rollback, validaciones y plan de despliegue por entornos'
---

# Generación de Scripts de Migración Seguros

## Propósito
Producir scripts de cambio de schema o datos que incluyan rollback explícito, validaciones pre/post y plan de despliegue seguro.

## Entradas
- Descripción del cambio deseado
- Schema/tablas afectadas
- Entornos objetivo (dev / staging / prod)

## Salidas
- Script de rollout con transacción y validación
- Script de rollback
- Checklist pre-migración y post-migración
- Estimación de tiempo y ventana de mantenimiento
- Criterios de go/no-go

## Estructura Estándar de Script

```sql
-- ============================================================
-- MIGRATION: [descripción del cambio]
-- Autor: [nombre]  Fecha: [fecha]
-- Entorno: [dev/staging/prod]
-- Estimación: [X minutos]
-- ============================================================

-- PRE-CHECK: validar estado antes de aplicar
-- [queries de validación]

BEGIN TRANSACTION;
BEGIN TRY

    -- CAMBIO PRINCIPAL
    -- [DDL/DML aquí]

    -- POST-CHECK: validar que el cambio se aplicó correctamente
    -- [queries de verificación]

    COMMIT TRANSACTION;
    PRINT 'Migración aplicada correctamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;
END CATCH;

-- ============================================================
-- ROLLBACK (ejecutar solo si es necesario revertir)
-- ============================================================
-- BEGIN TRANSACTION;
-- [DDL/DML de reversión]
-- COMMIT TRANSACTION;
```

## Checklist Pre-Migración
- [ ] Backup reciente verificado
- [ ] Script probado en entorno inferior
- [ ] Ventana de mantenimiento comunicada
- [ ] Rollback listo y probado
- [ ] Impacto de dependencias revisado

## Checklist Post-Migración
- [ ] Validaciones de datos completadas
- [ ] Rendimiento verificado
- [ ] Dependencias probadas
- [ ] Documentación actualizada

## Checklist de Calidad
- [ ] Toda migración dentro de transacción con rollback
- [ ] Pre-checks y post-checks incluidos
- [ ] Datos masivos procesados en lotes
- [ ] Script idempotente cuando sea posible
