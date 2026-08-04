---
name: 'Optimizacion de Consultas y Planes'
description: 'Skill para tuning de consultas, planes e indices con pruebas de regresion'
---

# Optimizacion de Consultas y Planes

## Proposito
Reducir tiempo de respuesta y consumo de recursos de consultas criticas manteniendo resultados funcionales correctos.

## Entradas
- Consulta o stored procedure objetivo
- Plan de ejecucion (real o estimado)
- Metricas baseline (duracion, CPU, lecturas)

## Salidas
- Version optimizada de consulta
- Recomendaciones de indices
- Riesgos y pruebas de regresion
- Plan de despliegue incremental

## Pasos

### 1. Baseline
- Captura latencia P50/P95
- Captura CPU y logical reads

### 2. Analisis de plan
- Detecta table scans costosos
- Revisa key lookups repetitivos
- Identifica warnings (spills, memory grant)

### 3. Propuesta de optimizacion
- Reescritura SQL orientada a sargabilidad
- Ajuste de predicados y joins
- Indices sugeridos con columnas clave e incluidas

### 4. Pruebas de regresion
- Compara resultados funcionales
- Compara metricas antes/despues

### 5. Rollout
- Despliegue en staging
- Ventana controlada en produccion
- Monitoreo y rollback

## Checklist de Calidad
- [ ] Mejora de rendimiento cuantificada
- [ ] Sin cambios funcionales no deseados
- [ ] Estrategia de rollback definida

## Scripts de Implementacion

El framework completo está en `scripts/query-optimization/`:

| Script | Paso |
|--------|------|
| `01-capture-baseline.sql` | Captura métricas antes del cambio (CPU, reads, waits, spills, key lookups, stats obsoletas) |
| `02-index-recommendations.sql` | Genera DDL: missing indexes por impacto, FK sin índice, duplicados, fragmentación |
| `03-golden-file-regression.ps1` | `capture` → guarda resultado SP · `validate` → compara vs golden |
| `04-staged-rollout.ps1` | Orquesta Stage 0→4: baseline → DEV → STAGING → PROD → monitor 24h |

Usar siempre en este orden. No aplicar DDL de script 02 sin golden file de script 03.

## Patrones Prioritarios

- **FK sin índice** → causa principal de lock escalation en DELETE/UPDATE (Quick Win 30min)
- **Key Lookup → Covering Index** → -30-60% logical reads con INCLUDE
- **Parameter sniffing** → `OPTIMIZE FOR UNKNOWN` o forzar plan en Query Store
- **Non-sargable predicates** → `YEAR(col)`, `CONVERT(...)`, `LIKE '%x'` → reescribir
- **Estadísticas obsoletas** → `UPDATE STATISTICS WITH FULLSCAN` antes de cualquier análisis
- [ ] Evidencia antes/despues documentada

