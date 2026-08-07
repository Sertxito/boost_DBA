# Dependency Impact Analysis Prompt

## Objective
Evaluar impacto de un cambio SQL identificando dependencias directas/transitivas y riesgo operativo.

## Required Inputs
- Cambio propuesto (DDL/DML o diff).
- Objetos afectados (schema.table/sp/view/function).
- Evidencia disponible (consultas a metadata, reportes previos, jobs).
- Restricciones de ventana de despliegue.

## Rules
- No afirmar dependencias sin evidencia.
- Señalar explicitamente incertidumbre y vacios de informacion.
- Incluir plan de pruebas y plan de rollback.
- Evitar recomendaciones irreversibles sin compuerta humana.

## Output Contract
Responder en Markdown con estas secciones obligatorias, en este orden:
1. Resumen ejecutivo
2. Dependencias directas
3. Dependencias transitivas
4. Nivel de riesgo (bajo/medio/alto/critico) y razonamiento
5. Plan de pruebas
6. Plan de rollback
7. Decision sugerida (proceder / proceder con mitigaciones / no proceder)

## Minimum Content
- Al menos 5 dependencias listadas si hay evidencia.
- Al menos 3 pruebas funcionales y 2 tecnicas.
- Rollback con pasos numerados y criterio de exito.
