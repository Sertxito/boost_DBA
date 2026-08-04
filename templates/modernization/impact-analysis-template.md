---
name: 'Plantilla de Análisis de Impacto de Cambio'
description: 'Plantilla para analizar el impacto de cambios propuestos en base de datos'
---

# Análisis de Impacto de Cambio de Base de Datos

**ID de Solicitud de Cambio:** ___________________  
**Fecha:** ___________________  
**Solicitado Por:** ___________________  
**Descripción del Cambio:** ___________________

---

## Resumen Ejecutivo

### Resumen del Cambio
- **Título:** ___
- **Tipo:** (Renombrar/Modificar/Agregar/Remover/Reestructurar)
- **Scope:** ___
- **Fecha de Completación Solicitada:** ___

### Resumen de Impacto
- **Nivel de Riesgo:** 🟢 BAJO / 🟡 MEDIO / 🔴 ALTO / 🟣 CRÍTICO
- **Radio de Impacto:** ___ objetos afectados
- **Tiempo Estimado de Implementación:** ___ horas
- **Tiempo Estimado de Pruebas:** ___ horas
- **Enfoque Recomendado:** ___

### Recomendación
- ✅ **APROBADO** - Seguro implementar
- ⚠️ **APROBADO CON MITIGACIÓN** - Procede con precaución
- ❌ **NO RECOMENDADO** - Muy riesgoso sin cambios mayores

---

## Análisis de Impacto Detallado

### Parte 1: Definición del Cambio

#### Estado Actual
```sql
-- Definición actual del objeto
[Inserta definición SQL actual aquí]
```

#### Estado Propuesto
```sql
-- Definición del objeto propuesta
[Inserta definición SQL propuesta aquí]
```

#### Lógica
¿Por qué se necesita este cambio?
- Razón de Negocio: ___
- Razón Técnica: ___
- Mejora de Rendimiento: ___%
- Otra: ___

---

### Parte 2: Descubrimiento de Dependencias

#### Dependencias Directas
**Objetos que referencian directamente el objeto cambiado:**

| Nombre del Objeto | Tipo | Tipo de Dependencia | Uso | Criticidad |
|-------------|------|-----------------|-------|-------------|
| ___ | Procedimiento | Referencia | SELECT/UPDATE/DELETE | CRÍTICO |
| ___ | View | Referencia | SELECT | IMPORTANTE |
| ___ | Función | Referencia | CALL | IMPORTANTE |
| ___ | Trigger | Referencia | UPDATE | IMPORTANTE |

**Total de Dependencias Directas:** ___

#### Dependencias Transitivas
**Objetos que indirectamente dependen del objeto cambiado:**

| Nivel 1 | Nivel 2 | Nivel 3 | Camino |
|---------|---------|---------|------|
| sp_A | sp_B | sp_C | sp_C → sp_B → sp_A |
| ___ | ___ | ___ | ___ |

**Total de Dependencias Transitivas:** ___

#### Gráfico de Dependencias
```
[Inserta diagrama de dependencias Mermaid aquí]

Ejemplo:
graph TD
    A[Objeto Cambiado]
    B[Procedimiento 1]
    C[Procedimiento 2]
    D[Capa de Aplicación]
    
    A --> B
    A --> C
    B --> D
    C --> D
```

---

### Parte 3: Evaluación de Impacto

#### Impacto en Datos
- [ ] Sin cambios de datos
- [ ] Migración de datos requerida: ___
- [ ] Valores NULL existentes a manejar: ___
- [ ] Reglas de validación de datos: ___
- [ ] Backup requerido: SÍ / NO
- **Riesgo de Impacto en Datos:** 🟢 BAJO / 🟡 MEDIO / 🔴 ALTO

#### Impacto en Aplicación
- [ ] Sin cambios de código de aplicación necesarios
- [ ] Stored procedures afectados: ___ (listar abajo)
- [ ] Views afectadas: ___ (listar abajo)
- [ ] Funciones afectadas: ___ (listar abajo)
- [ ] Queries de aplicación afectadas: ___ (adjuntar código)

**Procedimientos Afectados:**
```sql
-- Lista procedimientos que necesitan actualizaciones
sp_NombreProcedimiento    -- Necesita actualizar manejo de parámetro
```

**Views Afectadas:**
```sql
-- Lista views que necesitan actualizaciones
v_NombreView          -- Columna removida, afecta queries downstream
```

**Código de Aplicación Afectado:**
```csharp
// Lista ubicaciones de código de aplicación
var orders = db.Orders.Where(o => o.UserId == userId); 
// ↓ Necesita cambiar a
var orders = db.Orders.Where(o => o.CustomerId == userId);
```

#### Impacto de Rendimiento
- [ ] Sin impacto de rendimiento esperado
- [ ] Mejora de rendimiento esperada: __% (basado en ___)
- [ ] Riesgo de rendimiento: Ralentización potencial con ___ queries
- [ ] Cambios en plan de query
- [ ] Impacto de índice
  - [ ] Índices pueden reusarse
  - [ ] Nuevos índices necesitados: ___
  - [ ] Índices se vuelven obsoletos: ___
  - [ ] Index fragmentation risk: ___

**Performance Testing Plan:**
- [ ] Baseline metrics captured (current state)
- [ ] Test queries identified: ___ queries
- [ ] Performance thresholds: Query must complete in < ___ ms
- [ ] Load test scenarios: ___ concurrent users

#### Operational Impact
- [ ] No operational changes
- [ ] Runbooks need updates: ___
- [ ] Monitoring/alerting needs changes: ___
- [ ] Deployment procedures affected: ___
- [ ] Backup/recovery affected: ___
- [ ] Scheduled jobs affected: ___
  - Job: ___ (needs parameter updates)
  - Job: ___ (needs logic update)

---

### Part 4: Affected Systems

#### External Systems
| System | Impact | Mitigation |
|--------|--------|-----------|
| ___ | Linked server calls affected | Re-point to new table |
| ___ | ETL feeds from this object | Update transformation logic |
| ___ | Report generation | Update report queries |
| ___ | Third-party integration | Notify vendor, test integration |

#### Reports Affected
- [ ] Report A: References affected column → Update SQL
- [ ] Report B: Depends on procedure → Re-test output
- [ ] Report C: Uses deprecated function → Switch to new function

#### ETL/Scheduled Jobs
- [ ] SQL Agent Job: ___ (runs at ___)
  - Impact: ___
  - Fix: ___
  - Testing: ___

---

### Part 5: Risk Assessment

#### Likelihood & Severity Matrix

| Risk | Likelihood | Severity | Impact | Mitigation |
|------|-----------|----------|--------|-----------|
| Breaking dependent procedure | MEDIUM | HIGH | Service outage | Comprehensive testing of all dependents |
| Data corruption | LOW | CRITICAL | Data loss | Backup before change, validation queries |
| Performance regression | MEDIUM | MEDIUM | Slow queries | Baseline metrics, query plan analysis |
| Rollback failure | LOW | HIGH | Unable to revert | Test rollback procedure first |
| User confusion | MEDIUM | LOW | Support tickets | User communication, runbooks |
| Incomplete migration | MEDIUM | HIGH | Inconsistent data | Data validation checklist |

#### Risk Level Calculation
- **Risk Score:** (Likelihood + Severity) / 2 = ___
- **Overall Risk:** 🟢 LOW / 🟡 MEDIUM / 🔴 HIGH / 🟣 CRITICAL

#### Mitigation Strategies
1. **Risk:** Breaking dependent procedures
   - **Mitigation:** Execute all dependent procedures in staging with test data
   - **Owner:** ___
   - **Verification:** All procedures execute successfully

2. **Risk:** Data corruption
   - **Mitigation:** Full backup before production change
   - **Owner:** ___
   - **Verification:** Backup verified and restorable

3. **Risk:** Performance regression
   - **Mitigation:** Baseline current performance, test new implementation, compare metrics
   - **Owner:** ___
   - **Verification:** New performance within 5% of baseline

---

### Part 6: Testing Strategy

#### Test Scenarios

**Scenario 1: Basic Functionality**
- [ ] Execute procedure/query with typical data
- [ ] Verify output matches expected results
- [ ] Check data types are correct
- [ ] Validate row counts

**Test Data:**
```sql
-- Insert test data here
INSERT INTO TestTable VALUES (...)
```

**Expected Results:**
```
- Column A: Expected value
- Column B: Expected value
```

**Scenario 2: Edge Cases**
- [ ] NULL value handling
- [ ] Boundary value testing
- [ ] Empty result sets
- [ ] Maximum data volumes

**Test Cases:**
- [ ] NULL in customer field → procedure handles gracefully
- [ ] Order value = 0 → discount calculation correct
- [ ] Date = min/max SQL date → no overflow errors
- [ ] 1M row table → performance acceptable

**Scenario 3: Dependent Objects**
- [ ] All dependent procedures execute
- [ ] All views produce expected results
- [ ] All dependent jobs complete
- [ ] No cascading failures

**Scenario 4: Data Integrity**
- [ ] Foreign key constraints still valid
- [ ] Check constraints enforced
- [ ] Unique constraints respected
- [ ] Data consistency maintained

**Scenario 5: Performance**
- [ ] Query execution time < ___ ms
- [ ] Parallelism working as expected
- [ ] Index usage optimal
- [ ] No table scans on large tables

**Scenario 6: Rollback**
- [ ] Rollback procedure executes successfully
- [ ] Data returns to previous state
- [ ] Dependencies continue to work
- [ ] No orphaned data

#### Testing Checklist
- [ ] Unit tests written: ___ test cases
- [ ] Integration tests passed: ___ scenarios
- [ ] Performance tests completed: ___ queries
- [ ] UAT executed: ___ scenarios
- [ ] Data validation passed
- [ ] Dependent procedures tested
- [ ] Reports validated
- [ ] Rollback tested
- [ ] Monitoring configured
- [ ] Team walkthrough completed

#### Test Results
| Test | Status | Notes |
|------|--------|-------|
| Scenario 1: Basic Functionality | ✅ PASS / ❌ FAIL | ___ |
| Scenario 2: Edge Cases | ✅ PASS / ❌ FAIL | ___ |
| Scenario 3: Dependent Objects | ✅ PASS / ❌ FAIL | ___ |
| Scenario 4: Data Integrity | ✅ PASS / ❌ FAIL | ___ |
| Scenario 5: Performance | ✅ PASS / ❌ FAIL | ___ |
| Scenario 6: Rollback | ✅ PASS / ❌ FAIL | ___ |

---

### Part 7: Implementation Plan

#### Pre-Implementation
- [ ] Backup current production database
- [ ] Verify backup integrity
- [ ] Notify stakeholders
- [ ] Prepare rollback procedures
- [ ] Create implementation runbook
- [ ] Brief team on change details
- [ ] Verify monitoring is active

#### Implementation Steps
1. [ ] Step 1: ___
   - Time: ___ minutes
   - Rollback: ___

2. [ ] Step 2: ___
   - Time: ___ minutes
   - Rollback: ___

3. [ ] Step 3: ___
   - Time: ___ minutes
   - Rollback: ___

**Total Estimated Time:** ___ minutes

#### Post-Implementation
- [ ] Verify change was applied correctly
- [ ] Run validation queries
- [ ] Test dependent procedures
- [ ] Check monitoring/alerts
- [ ] Notify stakeholders of completion
- [ ] Monitor for issues (24 hours)
- [ ] Document lessons learned

---

### Part 8: Rollback Plan

#### Rollback Strategy
**Approach:** ___

```sql
-- Rollback procedures
[Insert exact SQL to rollback change]
```

**Rollback Time Estimate:** ___ minutes

#### Rollback Validation
```sql
-- Validation queries to verify rollback
[Insert queries to confirm rollback successful]
```

#### When to Rollback
- [ ] Any application error within 5 minutes of deployment
- [ ] Any data integrity issue detected
- [ ] Any critical alert triggered
- [ ] Performance degradation > 10%
- [ ] Manual decision: ___

#### Rollback Decision Owners
- Primary: ___
- Secondary: ___
- Executive: ___

---

### Part 9: Monitoring & Alerts

#### Monitoring During Change
- [ ] Database error log: Check for errors related to change
- [ ] Application logs: Monitor for exceptions
- [ ] Performance metrics: CPU, disk I/O, wait times
- [ ] Query performance: Response times for affected queries
- [ ] Business metrics: Order processing time, report generation time

#### Alerts to Configure
| Alert | Threshold | Action |
|-------|-----------|--------|
| Procedure execution error | 1 error in 5 min | Page on-call DBA |
| Query slow-down | > 10% vs baseline | Investigate query plan |
| Deadlock detected | 1 deadlock | Investigate table locks |
| Data validation failure | Any | Initiate rollback |
| Application error rate | > 0.1% | Investigate error logs |

#### Monitoring Duration
- [ ] Continuous monitoring: ___ hours
- [ ] Then: 1 week additional monitoring at normal frequency

---

### Part 10: Communication & Sign-Off

#### Stakeholder Notifications
- **24 hours before:** Email to stakeholders
- **1 hour before:** Slack notification
- **During:** Real-time updates
- **After:** Completion notification

#### Documentation
- [ ] Change details documented in wiki
- [ ] Runbooks updated
- [ ] Procedure specs updated
- [ ] Data dictionary updated
- [ ] Release notes prepared

#### Sign-Off
| Role | Name | Signature | Date | Notes |
|------|------|-----------|------|-------|
| Change Manager | ___ | ___ | ___ | ___ |
| Technical Lead | ___ | ___ | ___ | ___ |
| DBA | ___ | ___ | ___ | ___ |
| Product Owner | ___ | ___ | ___ | ___ |
| Executive (if HIGH risk) | ___ | ___ | ___ | ___ |

---

## Appendices

### A. Detailed Dependency Analysis
[Insert detailed dependency graphs and matrices]

### B. Complete Test Plan
[Insert comprehensive test scenarios and test cases]

### C. Performance Baseline
[Insert baseline metrics and performance analysis]

### D. Code Changes
[Insert full SQL/application code changes]

### E. Runbooks
[Insert step-by-step execution and rollback runbooks]

