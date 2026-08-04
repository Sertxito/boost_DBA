---
name: 'Informe de Dependencias e Impacto de Cambio'
---

# Informe de Dependencias e Impacto de Cambio

**Objeto analizado:** ___  **Cambio propuesto:** ___  **Fecha:** ___

## Resumen
- Dependencias directas: ___
- Dependencias transitivas: ___
- Nivel de riesgo: BAJO / MEDIO / ALTO / CRÍTICO
- Recomendación: PROCEDER / PROCEDER CON MITIGACIÓN / NO PROCEDER

## Grafo de Dependencias

```
[Objeto cambiado]
  ├── [Depende directamente: SP / View / Function]
  │     └── [Depende transitivamente: SP / App]
  └── [Depende directamente: ...]
```

## Dependencias Directas

| Objeto | Tipo | Uso | Criticidad | Acción requerida |
|--------|------|-----|-----------|-----------------|
| ___ | SP / View | SELECT / EXEC | CRÍTICO | Actualizar / Validar / Sin cambio |

## Dependencias Transitivas

| Nivel | Objeto | Ruta de impacto | Riesgo |
|-------|--------|----------------|--------|
| 2 | ___ | ___ → ___ → objeto | MEDIO |

## Plan de Pruebas

| Objeto afectado | Caso de prueba | Entorno | Responsable |
|----------------|---------------|---------|------------|
| ___ | ___ | Staging | ___ |

## Decisión

- Autonomía: 🟡 Requiere confirmación humana
- Script preparado: SÍ / NO
- Rollback disponible: SÍ / NO
- Ventana estimada: ___ minutos
