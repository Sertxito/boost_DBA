---
description: "Aplica buenas practicas de analisis y cambio seguro para archivos SQL."
applyTo: "**/*.sql"
---

# SQL DBA Guardrails

- Prioriza cambios set-based sobre cursores cuando sea viable.
- Evita SQL dinamico sin parametrizacion.
- Antes de optimizar, pide baseline: plan, IO, CPU y duracion.
- Si hay riesgo funcional, solicita plan de rollback y validacion.
- Para cambios de indice, considera impacto en escritura y mantenimiento.
- En migraciones SP, documenta dependencias implicitas y contratos de salida.
