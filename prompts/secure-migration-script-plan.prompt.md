# Secure Migration Script Plan Prompt

## Objective
Diseñar un plan de migracion SQL seguro y reversible con prechecks, rollout, postchecks y rollback.

## Required Inputs
- Descripcion del cambio.
- Objetos y volumen aproximado de datos.
- Entornos objetivo y ventana de mantenimiento.
- Dependencias conocidas.

## Rules
- Toda accion de impacto debe marcar aprobacion humana requerida.
- No ejecutar ni sugerir borrado irreversible sin respaldo y rollback.
- Incluir controles de seguridad y anonimización en artefactos.

## Output Contract
Responder en Markdown con esta estructura:
1. Alcance del cambio
2. Prechecks (lista numerada)
3. Plan de rollout por pasos
4. Plan de postchecks
5. Plan de rollback por pasos
6. Matriz Go/No-Go
7. Riesgos residuales

## Quality Gates
- Minimo 5 prechecks y 5 postchecks.
- Rollback debe poder ejecutarse paso a paso.
- Incluir tiempo estimado y criterio de corte.
