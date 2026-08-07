# DBA 360 Intake and Triage Prompt

## Objective
Clasificar solicitudes/incidentes DBA y producir un plan de accion de 24h alineado con modo Lean o Full.

## Required Inputs
- Contexto del incidente o cambio.
- Entorno afectado (dev/stage/prod).
- Sintoma principal y ventana temporal.
- Riesgo de negocio percibido.
- Restricciones de seguridad/compliance.

## Rules
- No pedir ni exponer secretos ni datos sensibles.
- Declarar supuestos cuando falte informacion.
- Priorizar decisiones verificables y reversibles.
- Aplicar principio: hallazgo sobre dato.

## Output Contract
Entregar en JSON con esta estructura exacta:

```json
{
  "triage": {
    "severity": "critical|high|medium|low",
    "mode": "lean|full",
    "incidentType": "performance|dependency|security|reliability|migration|governance"
  },
  "why": ["..."],
  "first24hPlan": [
    {"step": 1, "action": "...", "owner": "...", "evidence": "..."}
  ],
  "skillsToActivate": ["..."],
  "riskControls": ["..."],
  "humanApprovalRequired": true,
  "missingInfo": ["..."]
}
```

## Quality Gates
- Debe incluir `skillsToActivate` coherentes con el tipo de incidente.
- Debe incluir al menos 3 acciones en `first24hPlan`.
- Debe indicar explicitamente si requiere aprobacion humana.
