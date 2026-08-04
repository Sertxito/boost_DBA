---
name: 'Informe de Mantenimiento Proactivo'
---

# Informe de Mantenimiento Proactivo

**Base de Datos:** ___  **Fecha:** ___  **Responsable:** ___

## Resumen
- Índices analizados: ___ | Requieren acción: ___
- Estadísticas desactualizadas: ___
- Índices sin uso candidatos a eliminar: ___

## Hallazgos — Índices

| Tabla | Índice | Fragmentación % | Páginas | Acción | Prioridad |
|-------|--------|----------------|---------|--------|-----------|
| ___ | ___ | ___% | ___ | REBUILD / REORGANIZE | ALTA / MEDIA |

## Hallazgos — Estadísticas

| Tabla | Estadística | Días sin actualizar | Filas | Impacto estimado |
|-------|------------|-------------------|-------|-----------------|
| ___ | ___ | ___ | ___ | ___ |

## Hallazgos — Índices Sin Uso

| Tabla | Índice | Seeks | Scans | Updates | Decisión |
|-------|--------|-------|-------|---------|---------|
| ___ | ___ | 0 | 0 | ___ | Candidato a eliminar |

## Plan de Ejecución

| Acción | Objeto | Estimación | Ventana | Autonomía |
|--------|--------|-----------|---------|-----------|
| ___ | ___ | ___ min | ___ | 🟡 Confirmación |

## Criterios de Validación Post-Mantenimiento
- [ ] Fragmentación media reducida a menos de ___% 
- [ ] Planes de ejecución revisados sin regresión
- [ ] Sin errores en SQL Agent durante ventana
