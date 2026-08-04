---
name: 'Plantilla de Documentación de Base de Datos'
description: 'Plantilla para crear documentación comprensiva de base de datos'
---

# Plantilla de Documentación de Base de Datos

**Nombre de la Base de Datos:** ___________________  
**Versión:** ___________________  
**Última Actualización:** ___________________  
**Propietario/Equipo:** ___________________

---

## Tabla de Contenidos
1. [Descripción General de la Base de Datos](#descripción-general)
2. [Arquitectura & Diseño](#arquitectura)
3. [Diccionario de Datos](#diccionario-de-datos)
4. [Referencia de Procedimientos](#referencia-de-procedimientos)
5. [Referencia de Views](#referencia-de-views)
6. [Referencia de Funciones](#referencia-de-funciones)
7. [Flujos de Datos & Procesos](#flujos-de-datos)
8. [Reglas de Negocio](#reglas-de-negocio)
9. [Características de Rendimiento](#rendimiento)
10. [Problemas Conocidos & Workarounds](#problemas-conocidos)
11. [Runbooks & Operaciones](#runbooks)
12. [FAQ & Troubleshooting](#faq)

---

## Descripción General

### Propósito de Negocio
¿Qué hace esta base de datos desde perspectiva de negocio?
- ___

### Scope
¿Cuáles sistemas/procesos soporta?
- Proceso 1: ___
- Proceso 2: ___
- Proceso 3: ___

### Criticidad
- **Dependencia de Producción:** SÍ / NO
- **Impacto de Negocio si No Funciona:** ___
- **Objetivo de Tiempo de Recuperación (RTO):** ___ horas
- **Objetivo de Punto de Recuperación (RPO):** ___ horas
- **Frecuencia de Backup:** ___

### Métricas Clave
- **Tamaño:** ___ GB
- **Conteo de Filas (tabla más grande):** ___
- **Volumen de Transacciones:** ___ transacciones/día
- **Hora de Uso Pico:** ___
- **Tiempo de Respuesta de Query Típico:** ___ ms

### Propietario & Contactos
- **Propietario de Base de Datos:** ___ (email@example.com)
- **DBA Principal:** ___ (email@example.com)
- **DBA Secundario:** ___ (email@example.com)
- **Líder de Desarrollo:** ___ (email@example.com)
- **Contacto On-Call:** ___ (teléfono)

---

## Arquitectura & Diseño

### Descripción General de Schema
```
[Inserta diagrama de schema mostrando relaciones de tabla principales]

Ejemplo:
graph TD
    Companies["Empresas"]
    Customers["Clientes"]
    Orders["Órdenes"]
    OrderDetails["DetallesOrden"]
    Products["Productos"]
    
    Companies -->|1:N| Customers
    Companies -->|1:N| Products
    Customers -->|1:N| Orders
    Orders -->|1:N| OrderDetails
    Products -->|1:N| OrderDetails
```

### Decisiones Clave de Diseño
- **Nivel de Normalización:** 3NF / Denormalizado
- **Estrategia de Particionamiento:** ___
- **Estrategia de Archivo:** ___
- **Enfoque de Datos Históricos:** ___

### Principios de Diseño de Base de Datos
- [ ] Cumplimiento ACID requerido para transacciones
- [ ] Réplicas de lectura para reportes
- [ ] Estrategia de archivo implementada
- [ ] Sharding/particionamiento en lugar: ___

### Proyecciones de Crecimiento
- **Tamaño Actual:** ___ GB
- **Tamaño Proyectado (1 año):** ___ GB
- **Tasa de Crecimiento:** ___% por año
- **Planificación de Capacidad Hecha:** SÍ / NO

---

## Diccionario de Datos

### Tabla: ___________________

**Propósito de Negocio:**  
¿Qué representa esta tabla desde perspectiva de negocio?
- ___

**Propiedad:**  
Equipo/Persona responsable: ___

**Frecuencia de Uso:**  
¿Con qué frecuencia se accede/modifica este datos?
- Lectura: ___ veces/día
- Escritura: ___ veces/día

**Política de Retención:**  
¿Cuánto tiempo se guardan los datos?
- ___

**Estrategia de Backup:**  
¿Cómo se respalda esta tabla?
- ___

**Estadísticas de Tabla:**
- Conteo de Filas Actual: ___
- Tasa de Crecimiento: ___% por mes
- Conteo de Filas Proyectado (1 año): ___

#### Columnas

| Nombre Columna | Tipo de Datos | Nullable | Clave Primaria | Default | Descripción | Significado de Negocio |
|-------------|-----------|----------|-------------|---------|-------------|------------------|
| ID | INT | NO | SÍ | IDENTITY(1,1) | Identificador único | ___ |
| Nombre | NVARCHAR(100) | NO | NO | NULL | Nombre de cliente | ___ |
| Estado | CHAR(1) | NO | NO | 'A' | Estado del registro | A=Activo, I=Inactivo |
| FechaCreacion | DATETIME | NO | NO | GETDATE() | Timestamp de creación de registro | ___ |
| ___ | ___ | ___ | ___ | ___ | ___ | ___ |

#### Relaciones

| Relación | Tipo | Clave Foránea | Tabla Referenciada | Nombre de Restricción | Eliminar en Cascada |
|-------------|------|-------------|------------------|-----------------|-----------------|
| Empresa | N:1 | EmpresaID | Empresas | FK_Clientes_Empresas | NO |
| Orders | 1:N | CustomerID | Orders | FK_Orders_Customers | NO |

#### Indexes

| Index Name | Type | Columns | Unique | Included Columns | Purpose |
|------------|------|---------|--------|------------------|---------|
| PK_Customers | Clustered | ID | YES | N/A | Primary key |
| IX_Customers_CompanyID | Non-clustered | CompanyID | NO | Name, Status | Find customers by company |
| IX_Customers_Status | Non-clustered | Status | NO | ID, Name | Find active/inactive customers |

#### Triggers
- Trigger: TR_Customers_UpdateModifiedDate
  - Event: UPDATE
  - Action: Update ModifiedDate column
  - Purpose: Audit trail

#### Known Issues
- [ ] Issue 1: ___
  - Cause: ___
  - Workaround: ___
  - Status: Open / Planned Fix

---

### Table: ___________________
[Repeat template above for each major table]

---

## Procedures Reference

### Procedure: sp_MonthlyClosing

**Business Purpose:**  
Executes month-end close process, finalizes orders, generates reports

**Owner:** ___

**Criticality:** CRITICAL / IMPORTANT / UTILITY / DEPRECATED

**Last Modified:** ___ (by ___)

**Execution Frequency:**  
When is this procedure called?
- Scheduled: Yes, ___ (monthly at 11 PM on last working day)
- On-demand: Yes, ___ (for missed runs)
- Real-time: No

**Parameters:**

| Parameter | Type | Input/Output | Required | Default | Description |
|-----------|------|--------------|----------|---------|-------------|
| @CompanyID | INT | IN | YES | N/A | Which company to close |
| @ClosingMonth | INT | IN | YES | N/A | Month to close (1-12) |
| @ClosingYear | INT | IN | YES | N/A | Year to close |
| @SendNotifications | BIT | IN | NO | 1 | Send email notifications |
| @Result | NVARCHAR(MAX) | OUT | NO | N/A | Result message |

**Return Value:**
- 0: Success
- 1: Warning (partial success)
- 2: Error

**Result Sets:**
If procedure returns rows, describe them:
```
Result Set 1: Closed Orders Summary
  - CompanyID INT
  - ClosedOrderCount INT
  - TotalAmount DECIMAL
```

#### Processing Logic

Step-by-step what the procedure does:

1. **Validation**
   - Verify CompanyID exists
   - Verify ClosingMonth is 1-12
   - Check if month already closed (prevent double-close)

2. **Lock Data**
   - Lock all orders for the closing month
   - Set status to LOCKED

3. **Generate Reports**
   - Calculate monthly revenue
   - Generate GL reconciliation
   - Create audit reports

4. **Notifications**
   - Email Finance team
   - Email GL team
   - Email Operations team

5. **Archive**
   - Archive closed orders to archive table
   - Compress old data

#### Dependencies

**What does this procedure call?**
- Calls: sp_CalculateMonthlyRevenue
- Calls: sp_GenerateGLReport
- Calls: sp_SendEmailNotification
- Calls: sp_ArchiveClosedOrders

**Who calls this procedure?**
- sp_FinancialMonthEnd (calls this)
- SQL Agent Job: "Monthly_Close_Job"
- On-demand: Finance team via application

#### Performance Characteristics

| Metric | Value | Notes |
|--------|-------|-------|
| Typical Duration | 45 minutes | High month: 60+ minutes |
| Resource Usage | High CPU (20%), High Memory (4GB) | Runs at 11 PM to avoid peak hours |
| I/O Operations | Heavy disk I/O | Archive operation uses sequential scan |
| Blocking | Blocks on Orders table (moderate locks) | Locking strategy: IX locks on orders |
| Scalability | Linear with order count | +10 min per 100K orders |

#### Error Handling

What can go wrong and what happens:

| Error Condition | Error Message | Cause | Recovery |
|-----------------|---------------|-------|----------|
| Month already closed | 'Month XX/YYYY already closed' | Running twice | Check status, skip if already closed |
| Insufficient permissions | 'User does not have permission' | Access denied | Contact DBA |
| Archive table full | 'Archive table out of space' | Archive drive full | Expand archive storage |
| External system timeout | 'Report generation timeout' | Slow network | Retry or manual intervention |

#### Known Issues

- [ ] Issue: Takes 60+ minutes in months with 500K+ orders
  - Cause: Archive operation inefficient
  - Workaround: Run at 10 PM instead of 11 PM
  - Status: Planned for optimization in Q2

- [ ] Issue: Notifications sometimes fail silently
  - Cause: Email server intermittent
  - Workaround: Check log tables for delivery status
  - Status: Open, investigate email infrastructure

#### Recent Changes

| Date | Change | By | Reason |
|------|--------|-----|--------|
| 2024-01-15 | Added archive logic | John Smith | Reduce main table size |
| 2024-02-01 | Fixed timezone issue | Jane Doe | Reports showed wrong month |

#### Testing Instructions

How to test this procedure:

```sql
-- Test Case 1: Normal execution
EXEC sp_MonthlyClosing 
    @CompanyID = 1, 
    @ClosingMonth = 1, 
    @ClosingYear = 2024

-- Expected: Success, 0 rows affected

-- Test Case 2: With notifications disabled
EXEC sp_MonthlyClosing 
    @CompanyID = 1, 
    @ClosingMonth = 1, 
    @ClosingYear = 2024,
    @SendNotifications = 0

-- Expected: Success, no emails sent

-- Test Case 3: Error case (invalid month)
EXEC sp_MonthlyClosing 
    @CompanyID = 1, 
    @ClosingMonth = 13,  -- Invalid
    @ClosingYear = 2024

-- Expected: Error, month must be 1-12
```

#### Related Documentation
- [Runbook: Monthly Close Process](#runbook-monthly-close)
- [Data Flow: Month-End Close](#dataflow-monthend)
- [FAQ: Why is close taking so long?](#faq-close-time)

---

### Procedure: ___________________
[Repeat template above for each major procedure]

---

## Views Reference

### View: v_OpenOrders

**Business Purpose:**  
Shows all open orders that haven't been shipped yet

**Owner:** ___

**Query:** 
```sql
SELECT 
    OrderID, OrderNumber, CustomerName, OrderDate, OrderTotal
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE OrderStatus IN ('OPEN', 'PENDING')
```

**Used By:**
- Report: Customer Open Orders Report
- Dashboard: Sales Dashboard (open order count)
- Procedure: sp_ProcessShipments

**Performance:**
- Typical query time: 2 seconds
- Row count: 5000-10000
- Indexes used: IX_Orders_Status

**Maintenance:**
- Last checked: ___
- View definition change date: ___

---

## Functions Reference

### Function: fn_CalculateDiscount

**Purpose:**  
Calculate discount amount based on customer tier and order value

**Parameters:**
```sql
@CustomerID INT, 
@OrderAmount DECIMAL(18,2)
```

**Return Type:**  
DECIMAL(18,2) (discount amount)

**Logic:**
```sql
IF (SELECT Tier FROM Customers WHERE ID = @CustomerID) = 'GOLD'
    RETURN @OrderAmount * 0.10  -- 10% discount
ELSE IF ... = 'SILVER'
    RETURN @OrderAmount * 0.05  -- 5% discount
ELSE
    RETURN @OrderAmount * 0.02  -- 2% discount
```

**Used By:**
- sp_CalculateOrderTotal
- sp_ApplyDiscount

---

## Data Flows & Processes

### Process: Monthly Close

```
┌─────────────────────────────────────────────────────────┐
│ 1. Month-End Close Trigger (Last working day, 11 PM)    │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ 2. sp_MonthlyClosing Executes                           │
│    - Lock all orders for the month                      │
│    - Calculate revenue                                  │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ 3. Finance Reconciliation                               │
│    - GL reconciliation                                  │
│    - Bank reconciliation                                │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ 4. Reports Generated                                    │
│    - Revenue report                                     │
│    - Commission report                                  │
│    - Variance analysis                                  │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ 5. Notifications Sent                                   │
│    - Finance team email                                 │
│    - Leadership dashboard updated                       │
└─────────────────────────────────────────────────────────┘
```

**Tables Involved:**
- Orders (locked, status updated)
- OrderDetails (read for calculations)
- Products (read for revenue calculations)
- GLAccounts (updated with close entries)

**Duration:** 45-60 minutes

**Windows/Constraints:**
- Must complete before 6 AM (when reports accessed)
- Cannot run if previous month not closed
- Blocks interactive access to Orders table

---

## Business Rules

### Rule 1: Discount Calculation
**Description:** Customers with credit limit > $50,000 receive 5% discount

**Implementation Locations:**
- sp_CalculateOrderTotal (line 45)
- sp_ApplyDiscount (line 23)
- v_OrderSummary (view definition)

**Who Defines This Rule:** Sales team

**Last Changed:** 2024-01-10

**Test Scenarios:**
- Customer with $60K credit → 5% applied ✓
- Customer with $40K credit → No discount ✓
- New customer (no credit limit) → No discount ✓

### Rule 2: Order Status Flow
**Description:** Orders flow through: OPEN → SHIPPED → INVOICED → CLOSED

**Valid Transitions:**
- OPEN → SHIPPED (can ship)
- OPEN → CANCELLED (can cancel open order)
- SHIPPED → INVOICED (after shipment confirmed)
- INVOICED → CLOSED (after payment received)

**Enforcement:** Implemented in sp_UpdateOrderStatus

**Exception Handling:** Manager override available

---

## Performance Characteristics

### Query Performance Baseline

| Query/Procedure | Avg Duration | Max Duration | Frequency | Issues |
|-----------------|--------------|--------------|-----------|--------|
| sp_MonthlyClosing | 45 min | 90 min | 1/month | Slow in high-volume months |
| sp_GetCustomerOrders | 100 ms | 500 ms | 1000/day | N+1 query problem possible |
| v_OpenOrders | 2 sec | 5 sec | 100/day | No indexes, query plan inefficient |

### Index Usage

**Well-Indexed:**
- Orders table (5 indexes, 3 actively used)
- Customers table (3 indexes, 2 actively used)

**Under-Indexed:**
- OrderDetails table (0 indexes, query scans full table)
- Products table (1 index, should have 2 more)

### Optimization Opportunities

1. **Add Index on OrderDetails(ProductID)**
   - Impact: 50% faster product lookup
   - Estimated Time: 30 minutes to create
   - Risk: Slight write performance decrease

2. **Partition Orders Table by Year**
   - Impact: Faster historical queries
   - Estimated Time: 4 hours to implement
   - Risk: Complex maintenance procedures needed

3. **Archive Orders > 5 Years**
   - Impact: 30% smaller main table
   - Estimated Time: 2 hours to implement
   - Risk: Must maintain archive access

---

## Known Issues & Workarounds

### Issue 1: Monthly Close Sometimes Takes 2+ Hours

**Severity:** HIGH (blocks operations)

**Frequency:** Once per quarter

**Root Cause:** Archive operation sequential scan

**Current Workaround:**
1. Run close at 10 PM instead of 11 PM (extra buffer time)
2. Disable notifications on high-volume months
3. Archive data manually before month-end

**Permanent Fix:** Planned for Q2 optimization project

**Reported By:** Finance team (2024-01-15)

**Status:** In backlog for optimization

---

### Issue 2: View v_CustomerCreditStatus Expensive to Query

**Severity:** MEDIUM (slow reports)

**Frequency:** Every day

**Root Cause:** View has GROUP BY on large result set

**Current Workaround:**
1. Pre-calculate and cache in reporting table
2. Refresh daily at 2 AM
3. Use cached table for dashboard instead of view

**Permanent Fix:** Denormalize to materialized view

**Reported By:** BI team (2023-12-01)

**Status:** Planned for Q1 optimization

---

## Runbooks & Operations

### Runbook: Monthly Close Process

**Objective:** Successfully complete month-end close without errors

**When:** Last working day of month at 11 PM

**Duration:** 45-60 minutes (typically)

**Owner:** Finance Operations

**Escalation:** Finance Manager (if fails)

#### Pre-Close Checklist (Day before)
- [ ] Verify no critical jobs running
- [ ] Confirm all daily processes complete
- [ ] Backup database taken
- [ ] Backup verified restorable
- [ ] Communications sent to stakeholders

#### Execution Procedure
1. **Verify System State** (5 min)
   ```sql
   -- Check if previous month already closed
   SELECT COUNT(*) FROM Orders 
   WHERE YEAR(OrderDate) = YEAR(GETDATE())-1
   AND MONTH(OrderDate) = 12
   AND OrderStatus = 'CLOSED'
   ```
   Expected: > 0 rows (previous month closed)

2. **Execute Close Procedure** (45 min)
   ```sql
   EXEC sp_MonthlyClosing 
       @CompanyID = 1,
       @ClosingMonth = 1,
       @ClosingYear = 2024,
       @SendNotifications = 1
   ```

3. **Monitor Execution** (ongoing)
   - Watch error logs
   - Monitor CPU/Memory
   - Watch for long locks

4. **Verify Completion** (5 min)
   ```sql
   -- Verify close was successful
   SELECT COUNT(*) AS ClosedOrderCount,
          SUM(OrderTotal) AS MonthlyRevenue
   FROM Orders
   WHERE MONTH(OrderDate) = 1
   AND YEAR(OrderDate) = 2024
   AND OrderStatus = 'CLOSED'
   ```

#### Post-Close Validation
- [ ] All orders for month are CLOSED status
- [ ] Revenue calculated correctly
- [ ] No error messages in log
- [ ] Reports generated successfully
- [ ] Notifications sent successfully
- [ ] Finance team can access reports

#### Rollback (If Fails)
1. Stop procedure (CTRL+C)
2. Restore backup from before close
3. Investigate error
4. Retry with fix or manual workaround

---

### Runbook: Emergency Rollback

**When:** Critical issue discovered, must revert changes

**Duration:** 20-30 minutes

**Risk:** Data loss of 1-5 minutes of transactions

#### Procedure
1. **Decision** (1 min)
   - Determine if rollback necessary
   - Get approval from Finance Manager

2. **Notify Stakeholders** (2 min)
   - Alert Finance team
   - Update status page

3. **Stop Application** (2 min)
   - Set application to read-only mode
   - Prevent new transactions

4. **Restore Backup** (5-10 min)
   ```sql
   RESTORE DATABASE ERP FROM DISK='backup_before_close.bak'
   ```

5. **Verify Data Integrity** (3 min)
   - Row counts match
   - No corruption
   - Foreign keys intact

6. **Restart Application** (1 min)
   - Resume normal operation

---

## FAQ & Troubleshooting

### Q: Why is the monthly close taking 2 hours?

**A:** Several possible causes:

1. **Large order volume** (most common)
   - Check: `SELECT COUNT(*) FROM Orders WHERE MONTH(OrderDate) = CURRENT_MONTH`
   - If > 1M orders: Expected to take 60+ minutes
   - Solution: Start close earlier if volume expected

2. **Archive table running low on space**
   - Check: `SELECT * FROM sys.sysfiles` (check free space)
   - Solution: Expand archive drive or clean old archived data

3. **Slow external system** (email notification)
   - Check: Application logs for email service timeouts
   - Solution: Run with `@SendNotifications = 0`, send emails manually

4. **Missing index on OrderDetails**
   - Check: Query execution plan for table scans
   - Solution: Add index on OrderDetails(ProductID)

---

### Q: Can we run the close procedure twice in one month?

**A:** No, not without clearing previous results.

**Why:** Procedures designed to prevent double-counting

**If you need to:** Contact Finance team and DBA, must reset order statuses manually

---

### Q: Reports show different numbers than application

**A:** Possible causes:

1. **Reports running against stale cache**
   - Solution: Refresh cache manually or wait for scheduled 2 AM refresh

2. **Application and reports querying different tables**
   - Check: sp_GetCustomerOrders vs report query differences
   - Solution: Verify both use same source data

3. **Time zone issues**
   - Check: Ensure all queries use UTC or consistent time zone
   - Solution: Convert all queries to UTC

---

## Change Log

| Date | Change | Type | Owner | Impact |
|------|--------|------|-------|--------|
| 2024-02-15 | Added archive logic | Enhancement | John Smith | Performance improvement 20% |
| 2024-02-01 | Fixed timezone bug | Bug Fix | Jane Doe | Report accuracy |
| 2024-01-10 | Updated discount rule | Enhancement | Sales Team | New rule: 5% for >50K credit |

---

## Document Metadata

- **Document Version:** 1.0
- **Last Updated:** ___
- **Next Review Date:** ___
- **Reviewers:** ___, ___
- **Approval:** ___

---

## Appendices

### A. Complete Database Diagram
[Insert full ER diagram]

### B. SQL Server Configuration
[Insert configuration details]

### C. Monitoring Dashboard
[Insert screenshot or link to monitoring]

### D. Sample Data
[Insert sample queries and expected output]

### E. Additional Resources
- [Database Backup Procedures](#)
- [Performance Tuning Guide](#)
- [Disaster Recovery Plan](#)

