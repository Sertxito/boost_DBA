# Prompts Boost DBA 360

Este directorio contiene prompts reutilizables para flujos DBA.

## Convenciones

- Usar nombres descriptivos por caso de uso.
- Mantener objetivo, entradas, restricciones y salida esperada.
- Evitar datos sensibles o productivos.

## Catalogo

- `sql-risk-assessment.prompt.md`: analisis de riesgo de cambio SQL pre-despliegue.
- `dba360-intake-triage.prompt.md`: triage inicial para ruta Lean/Full y plan 24h.
- `dependency-impact-analysis.prompt.md`: impacto por dependencias directas y transitivas.
- `performance-bottleneck-diagnosis.prompt.md`: diagnostico reproducible de rendimiento.
- `secure-migration-script-plan.prompt.md`: plan de migracion segura con rollback.
- `modernization-roadmap.prompt.md`: hoja de ruta de modernizacion por olas.

Metadatos JSON: `catalog.json`.

## Uso recomendado

1. Selecciona prompt por tipo de incidente/cambio.
2. Inyecta evidencia real (nunca secretos ni datos sensibles).
3. Ejecuta eval asociado para validar estructura y calidad de salida.
