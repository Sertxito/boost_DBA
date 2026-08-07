# SQL Risk Assessment Prompt

## Objective
Evaluar un cambio SQL antes de despliegue para estimar riesgo tecnico, operativo y de seguridad, con mitigaciones accionables.

## Required Inputs
- Contexto funcional del cambio.
- Script SQL o diff propuesto.
- Dependencias conocidas (tablas, SPs, jobs, apps consumidoras).
- Ventana de despliegue y requisitos de disponibilidad.

## Rules
- No solicitar ni exponer datos sensibles o secretos.
- Declarar supuestos y vacios de informacion explicitamente.
- Separar hechos observables de inferencias.
- Incluir siempre mitigacion, validacion y rollback.

## Output Contract
Responder en JSON:

```json
{
	"executiveSummary": "...",
	"riskBySeverity": {
		"critical": ["..."],
		"high": ["..."],
		"medium": ["..."],
		"low": ["..."]
	},
	"impactAssessment": {
		"performance": "...",
		"availability": "...",
		"integrity": "...",
		"security": "..."
	},
	"mitigationPlan": ["..."],
	"rollbackPlan": ["..."],
	"validationPlan": {
		"preDeployment": ["..."],
		"postDeployment": ["..."]
	},
	"humanApprovalRequired": true,
	"missingInfo": ["..."]
}
```

## Quality Gates
- Incluir al menos 2 riesgos por severidad alta/critica cuando aplique.
- Incluir minimo 4 validaciones pre y 4 post despliegue.
- Indicar explicitamente si el cambio debe bloquearse o continuar con mitigaciones.
