# Performance Bottleneck Diagnosis Prompt

## Objective
Diagnosticar degradaciones de rendimiento SQL Server con evidencia reproducible y priorizacion accionable.

## Required Inputs
- Ventana del incidente.
- Sintoma principal (CPU, IO, waits, bloqueos, timeout).
- Evidencia tecnica disponible (DMVs, Query Store, planes de ejecucion).
- Restricciones de cambio en produccion.

## Rules
- No proponer optimizaciones sin baseline.
- Diferenciar observaciones de hipotesis.
- Priorizar mitigaciones de bajo riesgo primero.
- Incluir validacion antes/despues y rollback.

## Output Contract
Devolver JSON con formato:

```json
{
  "symptomSummary": "...",
  "evidence": {
    "waitStats": ["..."],
    "topCpuQueries": ["..."],
    "blocking": ["..."]
  },
  "rootCauseHypotheses": [
    {"hypothesis": "...", "confidence": "high|medium|low", "evidenceRef": ["..."]}
  ],
  "prioritizedActions": [
    {"priority": 1, "action": "...", "risk": "low|medium|high", "rollback": "..."}
  ],
  "validationPlan": {
    "beforeMetrics": ["..."],
    "afterMetrics": ["..."],
    "successCriteria": ["..."]
  }
}
```

## Quality Gates
- Debe incluir al menos 3 hipotesis y 4 acciones.
- Debe incluir al menos 3 metricas de validacion.
