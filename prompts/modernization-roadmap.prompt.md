# Modernization Roadmap Prompt

## Objective
Construir hoja de ruta de modernizacion de legado SQL por olas, con riesgo controlado y continuidad operativa.

## Required Inputs
- Estado actual (deuda tecnica, fragilidad, dependencias).
- Objetivos de negocio y SLO.
- Restricciones de presupuesto/equipo.
- Horizonte temporal (90 dias, 6 meses, 12 meses).

## Rules
- No proponer big-bang; usar fases incrementales.
- Incluir riesgos, mitigaciones y dependencias por ola.
- Definir KPIs medibles de avance y calidad.

## Output Contract
Entregar en JSON:

```json
{
  "executiveSummary": "...",
  "waves": [
    {
      "wave": "0|1|2|3",
      "goal": "...",
      "deliverables": ["..."],
      "dependencies": ["..."],
      "risks": ["..."],
      "mitigations": ["..."]
    }
  ],
  "kpis": [
    {"name": "...", "baseline": "...", "target": "...", "horizon": "..."}
  ],
  "governance": {
    "cadence": "...",
    "decisionGates": ["..."],
    "humanApprovalRequired": true
  }
}
```

## Quality Gates
- Minimo 3 olas.
- Minimo 5 KPIs.
- Debe incluir compuertas de decision y aprobacion humana.
