---
description: "Guia para activos de optimizacion de consultas SQL y rollout controlado."
applyTo: "scripts/query-optimization/**/*.{sql,ps1,md,json,yml,yaml}"
---

# Query Optimization Guardrails

- No proponer cambios sin baseline previo de latencia, IO y CPU.
- Validar regresion con golden files o comparativa equivalente.
- Aplicar cambios de forma gradual y reversible (staged rollout).
- Documentar supuestos de cardinalidad, estadisticas e indices.
- Evitar hints forzados salvo justificacion tecnica y caducidad definida.
- Adjuntar criterio de rollback y umbral de aceptacion.
