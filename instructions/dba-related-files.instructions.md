---
description: "Guia para archivos operativos DBA: scripts, agentes, skills, patrones y reportes."
applyTo: "{agents,skills,patterns,specs,templates,docs,references}/**/*.{md,ps1,json,yml,yaml}"
---

# DBA Operational Files Guardrails

- Mantener trazabilidad: problema, riesgo, accion, evidencia, rollback.
- No exfiltrar datos sensibles; usar anonimización en ejemplos y artefactos.
- En scripts PowerShell, incluir validaciones previas y fallar rapido.
- En reportes, priorizar hallazgos accionables con severidad y siguientes pasos.
- Reutilizar templates y patrones del repositorio antes de crear variantes nuevas.
- Evitar cambios no compatibles con flujo Lean/Full del orquestador DBA 360.
