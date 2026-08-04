# Caso de Estudio de Base de Datos ERP Heredada

## El Escenario

Esta es una base de datos SQL Server realista potenciando un sistema ERP que ha estado en producción desde 2005. Como muchas bases de datos heredadas, ha acumulado años de parches improvisados, documentación faltante, y dependencias ocultas.

## Características Clave (Los Problemas)

### 1. **Lógica de Negocio Dispersa**
- Procedimientos críticos como `sp_MonthlyClosing` se llaman desde múltiples lugares con lógica ligeramente diferente cada vez
- Cálculo de descuento enterrado en `sp_CalculateOrderTotal` con un 5% hardcoded para clientes grandes
- Cálculo de impuesto hardcoded (21%) en el mismo procedimiento - ¿cómo lo actualizarán para un nuevo país?

### 2. **Dependencias Ocultas**
- `sp_MonthlyClosing` llama `sp_UpdateCompanyMetrics` y `sp_SendMonthlyReports` - nadie documenta esta cadena
- `sp_ProcessShipment` llama dos otros procedimientos que tienen sus propias dependencias
- Si intentas modificar un procedimiento, no sabes qué se rompe downstream

### 3. **Código Muerto & Incertidumbre**
- `sp_NightlyReconciliation` se ejecuta cada noche pero no hace nada (código comentado)
- `sp_LegacyReportExtract` soporta un sistema que fue retirado hace 3 años pero aún está en el código
- Tabla `OrderArchive_2018` almacena datos en blob XML en lugar de schema propio
- ¿Quién sabe si remover estos romperá algo?

### 4. **Patrones Inconsistentes**
- Algunos procedimientos tienen parámetro `@RecalculateOnly` que nunca está documentado
- Views como `v_CustomerCreditStatus` son caras de consultar pero la gente no lo sabe
- Índices existen en algunos lugares pero no en otros, causando rendimiento impredecible

### 5. **Vacío de Documentación**
- Nadie puede explicar por qué existe el parámetro `@RecalculateOnly`
- La lógica de descuento (5% para clientes > límite de crédito 50K) podría ser una regla de negocio o un hack - nadie recuerda
- Valores HARDCODED (impuesto 21%, descuento 5%, umbral de archivo 5 años) embebidos en procedimientos

## Usando Este Caso de Estudio

### Paso 1: Ejecuta el Script de Schema
```powershell
# Conecta a tu instancia de SQL Server
sqlcmd -S localhost -E -i erp-database.sql
```

### Paso 2: Usa el Agente Analizador de Dependencias de BD
Pregunta: *"Analiza esta base de datos ERP y muéstrame qué es realmente crítico vs qué podría ser código muerto"*

El agente debería descubrir:
- `sp_MonthlyClosing` es crítico (llamado por procesos de fin de mes)
- `sp_ProcessShipment` es crítico (procedimiento operacional)
- `sp_GetCustomerOrders` es usado por reportes
- `sp_NightlyReconciliation` tiene cero dependencias → seguro de remover
- `sp_LegacyReportExtract` has zero active dependencies → investigate before removal

### Step 3: Use the Legacy Logic Extractor Agent
Ask: *"Extract the business logic from sp_CalculateOrderTotal - what are all the business rules?"*

The agent should discover:
- Base calculation: SUM of line totals
- Discount rule: 5% off for customers with credit limit > 50K
- Tax: Always 21% (hardcoded)
- Rule is fragile: discount logic only applies to specific customers, not all orders

### Step 4: Use the Change Impact Assessor Agent
Ask: *"If we need to support multiple tax rates by country, what's the impact of modifying sp_CalculateOrderTotal?"*

The agent should identify:
- All procedures that depend on sp_CalculateOrderTotal
- All applications that call sp_CalculateOrderTotal directly
- All views that depend on calculated data
- Risk: MEDIUM - requires coordinated update across multiple procedures

### Step 5: Use the DB Documentation Generator Agent
Ask: *"Create comprehensive documentation for this database - what tables, procedures, and business logic exist?"*

The agent should generate:
- Data dictionary for all tables
- Procedure documentation with business purpose
- Dependency matrix
- Risk assessment for modifications
- Data flow diagrams

## Expected Analysis Results

### Procedures Breakdown
| Procedure | Criticality | Dependencies | Status | Action |
|-----------|-------------|--------------|--------|--------|
| sp_MonthlyClosing | CRITICAL | 2 outbound | Active | Document & Stabilize |
| sp_ProcessShipment | CRITICAL | 2 outbound | Active | Document & Test |
| sp_GetCustomerOrders | HIGH | None | Active | Document |
| sp_CalculateOrderTotal | MEDIUM | Used by 2 procedures | Active | Refactor for flexibility |
| sp_NightlyReconciliation | NONE | None | Inactive | **Safe to Remove** |
| sp_LegacyReportExtract | NONE | None | Inactive | **Investigate & Remove** |

### Business Logic Findings
- Discount rules embedded in procedure, should be table-driven
- Tax rate hardcoded, should be configurable
- Month-end close process has implicit assumptions about order status
- No audit trail for order modifications

### Recommendations
1. **Immediate**: Document the 3 critical procedures with SME interviews
2. **Quick Win**: Remove `sp_NightlyReconciliation` and `sp_LegacyReportExtract`
3. **Short-term**: Refactor `sp_CalculateOrderTotal` to use configuration tables for rules
4. **Medium-term**: Implement proper archive strategy instead of XML blob storage
5. **Long-term**: Migrate order processing to application layer with feature parity

## Presentation Demo Script

### Demo 1: Dependency Discovery (5 minutes)
```
User: "We need to understand this database. Where do we start?"
Agent: "Let me scan the database and show you what's connected to what..."
[Shows dependency graph of procedures and tables]
Agent: "Here's what I found: 6 procedures, 5 of which are interconnected. 
        But 2 procedures have zero dependencies - they might be dead code."
```

### Demo 2: Impact Analysis (5 minutes)
```
User: "Can we safely modify the OrderStatus logic?"
Agent: "Let me analyze the impact..."
[Shows 15 procedures that depend on OrderStatus]
Agent: "High risk - this is referenced in 15 places across 3 procedure call chains.
        Test strategy: Run all dependent procedures in staging, validate reports"
```

### Demo 3: Documentation Recovery (5 minutes)
```
User: "We need to document this before we modify it"
Agent: "I'll extract the documentation from the code..."
[Generates data dictionary, procedure specs, business rule documentation]
Agent: "Complete documentation ready - here's what the database actually does vs what was documented"
```

## Files in This Example

- `erp-database.sql` - Create the test database with realistic legacy patterns
- `erp-case-study.md` - This file, explaining the scenario
- `analysis-queries.sql` - Pre-made SQL queries to analyze the database
- `demo-scripts.md` - Copy/paste scenarios for live presentation demos

