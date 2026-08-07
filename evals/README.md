# Evals Boost DBA 360

Este directorio contiene evaluaciones para validar prompts y flujos del boost.

## Convenciones

- Casos deterministas y reproducibles.
- Entradas anonimizadas o sinteticas.
- Criterios de aceptacion explicitos.

## Suite

- `sql-risk-assessment.eval.json`: riesgo de cambio SQL con trade-offs.
- `dba360-intake-triage.eval.json`: triage inicial y activacion de skills.
- `dependency-impact-analysis.eval.json`: impacto por dependencias y rollback.
- `performance-bottleneck-diagnosis.eval.json`: hipotesis y priorizacion con evidencia.
- `secure-migration-script-plan.eval.json`: plan de despliegue reversible.
- `modernization-roadmap.eval.json`: roadmap por olas con riesgos y KPIs.
- `security-negative-redaction.eval.json`: caso negativo para evitar fuga de secretos.

Metadatos JSON: `suite.json`.

## Regla de calidad

Cada cambio de prompt debe tener al menos 1 eval asociado actualizado.
