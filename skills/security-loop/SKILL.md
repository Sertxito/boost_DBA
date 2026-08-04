---
name: 'Security Loop Continuo'
description: 'Skill de validación de seguridad embebida en cada ciclo de análisis: no solo en onboarding sino en cada recomendación y salida'
---

# Security Loop Continuo

## Propósito
La seguridad no es un paso puntual de arranque. Es una compuerta que se ejecuta en cada ciclo de análisis, recomendación y entrega de resultados. Esta skill se invoca automáticamente antes de cualquier salida que pueda contener información sensible.

## Cuándo se Activa
El security loop se ejecuta en **tres momentos** de cada sesión:

```
INICIO          →  Preflight de seguridad sobre la fuente de verdad
     ↓
ANÁLISIS        →  Validación de que los hallazgos no exponen negocio innecesariamente
     ↓
ENTREGA         →  Sanitización de salidas antes de compartir fuera del entorno
     ↓
(vuelve a ANÁLISIS si hay más ciclos)
```

## Compuerta 1: Preflight de Inicio
- Verificar que la fuente de verdad no contiene secretos en claro
- Confirmar que no hay SQL de negocio productivo sin anonimizar
- Ejecutar: `pwsh -File scripts/security-preflight.ps1`
- Resultado esperado: PASS. Si FAIL → sanear antes de continuar.

## Compuerta 2: Validación en Análisis
Antes de incluir cualquier fragmento en un informe o recomendación, verificar:

```
¿Es necesario este dato para explicar el hallazgo?
  SÍ → ¿Puede expresarse como metadata (nombre de objeto, métrica, patrón)?
        SÍ → usar metadata, no SQL literal
        NO → anonimizar: reemplazar nombres reales por aliases descriptivos
  NO → omitir
```

Datos que **nunca** deben aparecer en salidas compartibles:
- Connection strings completas
- Nombres de servidores internos
- Usuarios o contraseñas
- Datos de filas reales (aunque sean de ejemplo)
- Nombres de tablas/columnas que revelen modelo de negocio propietario

## Compuerta 3: Sanitización de Entrega
Antes de cualquier salida externa (informe, compartición, colaboración):
- Ejecutar: `pwsh -File scripts/sanitize-and-validate.ps1 -Destination "C:\temp\output"`
- Verificar PASS en VALIDATION-REPORT.md de la salida
- Confirmar que el contenido compartido es solo el necesario

## Principio de Mínimo Dato
> Comparte el hallazgo, no el dato que lo originó.

| En lugar de | Usa |
|-------------|-----|
| `SELECT * FROM dbo.Clientes WHERE DNI = '12345678A'` | "Se detectaron consultas sin predicado selectivo en tabla de clientes" |
| `Server=PROD-SQL-01;Database=ERP_PROD;User=sa;Password=...` | "[conexión anonimizada al origen]" |
| `sp_CalcularComisionVendedor_v3` | "SP de cálculo de comisión (crítico, 47 dependencias)" |

## Checklist del Loop
- [ ] Preflight ejecutado y PASS al inicio
- [ ] Cada hallazgo expresado en términos de patrón/métrica, no dato literal
- [ ] Salidas externas sanitizadas y validadas
- [ ] Fuente de verdad local intacta (sin modificaciones de negocio)
- [ ] Trazabilidad: SANITIZATION-REPORT y VALIDATION-REPORT generados
