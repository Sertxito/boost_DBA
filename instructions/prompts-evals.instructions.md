---
description: "Guia para prompts y evaluaciones del boost DBA 360."
applyTo: "{prompts,evals}/**/*.{md,json,yml,yaml,txt}"
---

# Prompts and Evals Guardrails

- Mantener prompts deterministas, con objetivo, entradas y criterio de salida explicitos.
- Evitar pedir o exponer datos productivos; usar datasets anonimizados o sinteticos.
- En evals, priorizar casos de regresion para riesgos DBA: rendimiento, seguridad y dependencia.
- Cada cambio de prompt debe incluir al menos un caso de evaluacion asociado.
- Reportar resultados en formato estructurado y comparable entre corridas.
- Evitar lenguaje ambiguo; definir severidad y umbrales de aceptacion.
