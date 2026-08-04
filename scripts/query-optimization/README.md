# Marco de Optimizacion de Consultas â€” ProjectName

**Alcance:** 6.554 SPs | SQL Server 2017 | stack .NET 8 Dapper/EF  
**Objetivo:** Reducir tiempo de respuesta y consumo de recursos sin cambios funcionales

---

## Flujo de 4 Scripts

```
01-capture-baseline.sql        â†’ Extrae mÃ©tricas actuales (CPU, reads, waits)
        â†“
02-index-recommendations.sql   â†’ Genera DDL de Ã­ndices faltantes, redundantes, fragmentados
        â†“  [Aplicas el cambio aquÃ­: Ã­ndice, reescritura de SP o sugerencia QS]
      03-golden-file-regression.ps1  â†’ Captura antes y valida que la salida no cambiÃ³
        â†“
04-staged-rollout.ps1          â†’ Orquesta DEV â†’ STAGING â†’ PROD con confirmaciÃ³n manual
```

---

## Uso RÃ¡pido

### Optimizar un SP paso a paso

```powershell
cd c:\repo\BoostDBA

# 1. Captura archivo golden (resultado esperado) en PROD
.\scripts\query-optimization\03-golden-file-regression.ps1 `
  -Mode capture `
  -SpName 'bi.AccionesFormativasPlanFormacion_S' `
  -ServerInstance 'prod-db'

# 2. Revisa recomendaciones de Ã­ndices en SSMS
#    â†’ Abre 02-index-recommendations.sql y ejecuta en ProjectName

# 3. Aplica el cambio en DEV primero

# 4. Valida que la salida no cambiÃ³
.\scripts\query-optimization\03-golden-file-regression.ps1 `
  -Mode validate `
  -SpName 'bi.AccionesFormativasPlanFormacion_S' `
  -ServerInstance 'dev-db'

# 5. Rollout completo a PROD
.\scripts\query-optimization\04-staged-rollout.ps1 `
  -SpName 'bi.AccionesFormativasPlanFormacion_S' `
  -Stage all `
  -ProdServer 'prod-db'
```

---

## Scripts en Detalle

### `01-capture-baseline.sql`
Ejecutar en SSMS contra ProjectName. Captura:
- Top 30 SPs por CPU, tiempo transcurrido y frecuencia
- Planes con regresion (Query Store)
- Estadisticas de espera (PAGEIO_LATCH, LCK_M, etc.)
- Spills a TEMPDB
- Key lookups costosos
- EstadÃ­sticas obsoletas (>7 dÃ­as)

**CuÃ¡ndo:** Antes de CUALQUIER cambio. Guarda la salida como `baseline-YYYYMMDD.json`

---

### `02-index-recommendations.sql`
Genera DDL listo para revisar y aplicar:
- **Indices faltantes** ordenados por ImpactScore
- **FK sin Ã­ndice** (principal causa de lock escalation)
- **Ãndices duplicados/redundantes** (candidatos a DROP)
- **Ãndices no usados** (sobrecarga en escrituras)
- **FragmentaciÃ³n** (REBUILD vs REORGANIZE)

**âš ï¸ Regla:** Nunca aplicar en bloque. Revisar uno a uno, aplicar con `ONLINE=ON`.

---

### `03-golden-file-regression.ps1`
Compara salidas funcionales de un SP:

| Modo | AcciÃ³n |
|------|--------|
| `capture` | Ejecuta SP y guarda resultado en JSON (golden file) |
| `validate` | Ejecuta SP actual, compara vs golden. Exit 0=pass, 1=fail |
| `report` | Muestra info del golden file sin ejecutar |

**Salida golden:** `workspaces/ProjectName/tests/golden/{sp_name}.golden.json`

Detecta:
- Cambios de esquema (columnas aÃ±adidas/quitadas)
- Diferencias en nÃºmero de filas
- Diferencias de valores (con tolerancia numÃ©rica configurable)
- NULL vs no-NULL

---

### `04-staged-rollout.ps1`
Orquesta el despliegue seguro en 5 etapas:

| Etapa | AcciÃ³n | Entorno |
|-------|--------|---------|
| 0 | Captura baseline + mÃ©tricas DMV | PROD |
| 1 | RegresiÃ³n funcional | DEV |
| 2 | RegresiÃ³n + rendimiento | STAGING |
| 3 | Despliegue con confirmaciÃ³n manual (`CONFIRMO`) | PROD |
| 4 | Monitor 24h post-deploy (comparar vs baseline) | PROD |

**ReversiÃ³n:** Si la etapa 3 falla, el script muestra pasos de reversiÃ³n y sale con cÃ³digo 1.

---

## Patrones de OptimizaciÃ³n Prioritarios

### 1. Ãndice de clave forÃ¡nea faltante (mejora rÃ¡pida, 30 min)
```sql
-- Antes: escaneo completo en DELETE/UPDATE porque la clave forÃ¡nea no estÃ¡ indexada
-- DetecciÃ³n: script 02 secciÃ³n "FOREIGN KEYS SIN ÃNDICE"

-- SoluciÃ³n:
CREATE NONCLUSTERED INDEX [IX_T_PLANFORMACION_FK_ConvocatoriaId]
ON dbo.T_PLANFORMACION (ConvocatoriaId)
WITH (ONLINE=ON, FILLFACTOR=90);

-- Validar: Ejecutar script 03 validate despuÃ©s de crear el Ã­ndice
```

### 2. Key Lookup â†’ Ã­ndice de cobertura (2-4h)
```sql
-- Antes: bÃºsqueda en Ã­ndice no cluster + key lookup clusterizado (2 lecturas por fila)
-- DetecciÃ³n: script 01 secciÃ³n "KEY LOOKUPS"

-- SoluciÃ³n: aÃ±adir columnas usadas en JOIN a INCLUDE
CREATE NONCLUSTERED INDEX [IX_T_FORMACION_PlanId_Covering]
ON dbo.T_FORMACION (PlanId)
INCLUDE (Nombre, FechaInicio, Estado, CentroId)  -- columnas del SELECT
WITH (ONLINE=ON, FILLFACTOR=85);
```

### 3. EstadÃ­sticas obsoletas (15 min)
```sql
-- DetecciÃ³n: script 01 secciÃ³n "ESTADÃSTICAS OBSOLETAS"
-- Fix:
UPDATE STATISTICS dbo.T_PLANFORMACION WITH FULLSCAN;
-- O para toda la BD:
EXEC sp_updatestats;
```

### 4. Parameter Sniffing (variable en PROD)
```sql
-- SÃ­ntoma: SP rÃ¡pido en DEV, lento en PROD con mismos datos
-- SoluciÃ³n opciÃ³n A: OPTIMIZE FOR UNKNOWN
CREATE OR ALTER PROCEDURE bi.ReportePlan @planId INT
AS
    SELECT ... FROM dbo.T_PLANFORMACION WHERE PlanId = @planId
    OPTION (OPTIMIZE FOR (@planId UNKNOWN));

-- SoluciÃ³n opciÃ³n B: Query Store â†’ forzar plan Ã³ptimo
-- 1. Identifica plan_id del plan bueno en QS
-- 2. Fuerza ese plan:
EXEC sys.sp_query_store_force_plan @query_id = 1234, @plan_id = 5678;
```

### 5. Sargabilidad â€” predicados no sargables (1-2h por consulta)
```sql
-- âŒ No sargable (escaneo completo aunque exista Ã­ndice)
WHERE YEAR(FechaCreacion) = 2025
WHERE CONVERT(VARCHAR, PlanId) = '1001'
WHERE Nombre LIKE '%Plan%'
WHERE LEN(Descripcion) > 100

-- âœ… Sargable (usa el Ã­ndice)
WHERE FechaCreacion >= '2025-01-01' AND FechaCreacion < '2026-01-01'
WHERE PlanId = 1001
WHERE Nombre LIKE 'Plan%'  -- solo prefix
WHERE Descripcion > REPLICATE('a', 100)
```

---

## Checklist de Calidad (por SP optimizado)

- [ ] Baseline capturado antes del cambio (script 01)
- [ ] Golden file creado (script 03 capture)
- [ ] Ãndice/reescritura aplicado en DEV
- [ ] ValidaciÃ³n funcional pass (script 03 validate, Stage 1)
- [ ] ValidaciÃ³n en staging pass (Stage 2)
- [ ] DDL de cambio revisado por DBA
- [ ] Ventana de mantenimiento acordada con OPS
- [ ] Deploy en PROD con confirmaciÃ³n manual (Stage 3)
- [ ] Monitor 24h post-deploy (Stage 4)
- [ ] MÃ©tricas antes/despuÃ©s documentadas en reporte

---

## MÃ©tricas de Ã‰xito

| Indicador | Objetivo | CÃ³mo medir |
|-----------|--------|------------|
| AvgElapsed_ms | -20% mÃ­nimo | script 04 Stage 4 |
| AvgLogicalReads | -30% mÃ­nimo | sys.dm_exec_procedure_stats |
| Timeouts de lock/dÃ­a | < 5 | alerta de sys.dm_os_waiting_tasks |
| Esperas PAGEIO_LATCH | < 100ms promedio | script 01 secciÃ³n de esperas |
| Regresiones detectadas | 0 | cÃ³digo de salida de script 03 validate |

---

## ReversiÃ³n Manual

Si un cambio causa regresiÃ³n en PROD:

```sql
-- ReversiÃ³n de Ã­ndice
DROP INDEX [IX_nombre] ON schema.Tabla;

-- ReversiÃ³n de reescritura de SP
-- Restaurar desde fuente de verdad:
-- workspaces/ProjectName/fuente-de-verdad/schema/db.sql

-- ReversiÃ³n de plan forzado en Query Store
EXEC sys.sp_query_store_unforce_plan @query_id = 1234, @plan_id = 5678;

-- ReversiÃ³n de UPDATE STATISTICS (no hay reversiÃ³n directa)
-- â†’ Usar sp_updatestats para regenerar con datos actuales
```

---

## Estructura de Archivos

```
scripts/query-optimization/
â”œâ”€â”€ 01-capture-baseline.sql          â† Ejecutar en SSMS
â”œâ”€â”€ 02-index-recommendations.sql     â† Revisar y aplicar DDL
â”œâ”€â”€ 03-golden-file-regression.ps1    â† capture | validate | report
â”œâ”€â”€ 04-staged-rollout.ps1            â† Orquestador completo
â””â”€â”€ README.md                        â† Este archivo

workspaces/ProjectName/tests/golden/
â””â”€â”€ {schema}_{sp_name}.golden.json   â† Archivos golden (no comitear sin revisiÃ³n)

workspaces/ProjectName/plans/optimization-reports/
â””â”€â”€ {sp_name}-rollout-{date}.md      â† Reporte de cada optimizaciÃ³n
```

---

**PrÃ³ximos SPs priorizados (Wave-1, mayor frecuencia):**  
Obtener de `workspaces/ProjectName/plans/full-db-sp-classification.json`  
Filtrar: `Category = CRUD AND Wave = Wave-1`  
Ordenar por: frecuencia real (Fase 2 DMV â†’ `phase2-top-sps-frequency.json`)



