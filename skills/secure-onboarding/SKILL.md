---
name: 'Onboarding Seguro y Fuente de Verdad'
description: 'Skill para arrancar un proyecto de BBDD desde cero con seguridad-first y fuente de verdad local'
---

# Onboarding Seguro y Fuente de Verdad

## Proposito
Preparar una sesion DBA completa sin exponer negocio, creando una fuente de verdad local reutilizable para no depender de conexiones continuas a la base de datos origen.

## Regla Operativa (OBLIGATORIA)

El onboarding es el flujo maestro de arranque: ejecuta todo el pipeline tecnico de forma autonoma y llega hasta dejar listos reportes y planes para revision.

Punto de parada obligatorio: antes de generar los `.docx`, el proceso se detiene para revision humana de `reports/` y `plans/`.

## Entradas
- Nombre del proyecto DBA
- Uno de estos origenes:
  - Connection string (solo para descubrimiento inicial)
  - Carpeta con esquemas/scripts SQL
  - Proyecto de base de datos (dacpac/sqlproj/scripts)

## Salidas
- Estructura local en `workspaces/<Proyecto>/` dentro del repo
- **Fuente de verdad completa** con todos los objetos de la BD
- Manifest de configuración y preflight PASS/FAIL
- Reportes tecnicos y planes en `workspaces/<Proyecto>/reports` y `workspaces/<Proyecto>/plans`
- Entregables Word en `workspaces/<Proyecto>/entrega/*.docx` (solo tras aprobacion humana)

## Fuente de Verdad — Estructura Completa (OBLIGATORIO)

La fuente de verdad no es solo el schema SQL. Es el inventario completo de todo lo que existe en la BD. Ningún agente analiza sin que esta estructura esté generada:

```
workspaces/<Proyecto>/
  fuente-de-verdad/
    manifest.json               ← configuración BD + preflight
    schema/db.sql               ← schema completo (DDL + SPs)
    tables-by-schema.json       ← inventario de tablas por schema
    procs-by-schema.json        ← inventario de SPs por schema
    views-by-schema.json        ← inventario de vistas por schema
    functions-by-schema.json    ← inventario de funciones por schema
  plans/
    full-db-sp-classification.json ← clasificación CRUD/Simple/Complex/Critical
    full-db-sp-classification.md
  reports/
    business-rules/
      critical-rules-catalog.md  ← patrones de reglas en SPs Critical
      complex-rules-catalog.md   ← patrones de reglas en SPs Complex
```

## Pasos de Bootstrap (Orden Obligatorio)

### Paso 0: Security Preflight (PRIMERO)
```powershell
pwsh -File scripts/security-preflight.ps1
if ($LASTEXITCODE -ne 0) { Write-Error 'Preflight de seguridad FAIL. Sanear antes de continuar.'; exit 1 }
```

Este gate siempre corre primero.

### Paso 1: Schema y objetos base
```powershell
# Si el schema ya existe en input/:
pwsh -File scripts/refresh-source-of-truth.ps1 -ProjectName "NombreProyecto"
```
Genera: `schema/db.sql`, `tables-by-schema.json`, `procs-by-schema.json`, `manifest.json`

### Paso 2: Inventario de vistas y funciones
```powershell
# Extraer vistas y funciones del schema ya generado
$lines = [IO.File]::ReadAllLines("workspaces/$proyecto/fuente-de-verdad/schema/db.sql")
$v=@{}; $f=@{}
foreach($l in $lines) {
    if ($l -match 'VIEW\s+\[?(\w+)\]?\.\[?(\w+)\]?') { $s=$matches[1];$n=$matches[2]; if(!$v[$s]){$v[$s]=@()};$v[$s]+=$n }
    if ($l -match 'FUNCTION\s+\[?(\w+)\]?\.\[?(\w+)\]?') { $s=$matches[1];$n=$matches[2]; if(!$f[$s]){$f[$s]=@()};$f[$s]+=$n }
}
@{total=($v.Values|%{$_.Count}|Measure-Object -Sum).Sum; bySchema=$v} | ConvertTo-Json -Depth 4 | Out-File "workspaces/$proyecto/fuente-de-verdad/views-by-schema.json" -Encoding UTF8
@{total=($f.Values|%{$_.Count}|Measure-Object -Sum).Sum; bySchema=$f} | ConvertTo-Json -Depth 4 | Out-File "workspaces/$proyecto/fuente-de-verdad/functions-by-schema.json" -Encoding UTF8
```

### Paso 3: Clasificación de SPs
```powershell
pwsh -File scripts/analyze-sp-migration.ps1 -ProjectName "NombreProyecto"
```
Genera: `plans/full-db-sp-classification.json`

### Paso 4: Catálogos de reglas de negocio (REQUERIDO antes de cualquier análisis)
```powershell
pwsh -File scripts/extract-critical-business-rules.ps1 -Category Critical
pwsh -File scripts/extract-critical-business-rules.ps1 -Category Complex
```
Genera: `reports/business-rules/critical-rules-catalog.md` y `complex-rules-catalog.md`

### Verificación final
```powershell
$p = "workspaces/NombreProyecto"
@(
    "$p/fuente-de-verdad/schema/db.sql",
    "$p/fuente-de-verdad/tables-by-schema.json",
    "$p/fuente-de-verdad/procs-by-schema.json",
    "$p/fuente-de-verdad/views-by-schema.json",
    "$p/fuente-de-verdad/functions-by-schema.json",
    "$p/plans/full-db-sp-classification.json",
    "$p/reports/business-rules/critical-rules-catalog.md",
    "$p/reports/business-rules/complex-rules-catalog.md"
) | ForEach-Object { "$_ → $(if(Test-Path $_){'✅'}else{'❌ FALTA'})" }
```

**Si algún fichero falta, ejecutar el paso correspondiente antes de continuar.**

### Paso 5: Orquestacion de analisis tecnicos

Con la fuente de verdad y catálogos completos, el onboarding dispara la orquestación de análisis DBA (dependencias, impacto, rendimiento, seguridad/fiabilidad, modernización) y genera los artefactos en `reports/` y `plans/` del proyecto.

Regla: cualquier hallazgo debe estar sustentado por lectura del SQL real en `schema/db.sql`.

### Paso 6: STOP de control humano (HITL obligatorio)

Antes de crear los `.docx`, el onboarding debe parar y solicitar revisión explícita del usuario antes de cualquier acción adicional.

Checklist de revision:
- `workspaces/<Proyecto>/fuente-de-verdad/manifest.json`
- `workspaces/<Proyecto>/fuente-de-verdad/schema/db.sql`
- `workspaces/<Proyecto>/fuente-de-verdad/tables-by-schema.json`
- `workspaces/<Proyecto>/fuente-de-verdad/procs-by-schema.json`
- `workspaces/<Proyecto>/fuente-de-verdad/views-by-schema.json`
- `workspaces/<Proyecto>/fuente-de-verdad/functions-by-schema.json`
- `workspaces/<Proyecto>/reports/`
- `workspaces/<Proyecto>/plans/`

Con aprobación explícita, se ejecuta el Paso 7 para generar Word.

Sin esta aprobación, no se continúa a fases posteriores.

### Paso 7: Generacion de entregables Word

Precondicion obligatoria:
- Fuente de verdad completa validada
- Reportes y planes generados
- Aprobacion HITL del Paso 6

El onboarding invoca el flujo de entrega para generar documentos `.docx` en `workspaces/<Proyecto>/entrega/`.

Salidas minimas esperadas:
- `<Proyecto>-INFORME-CLIENTE.docx`
- `<Proyecto>-INFORME-FUNCIONAL.docx`
- `<Proyecto>-ASSESSMENT.docx`
- `<Proyecto>-INFORME-TECHLEAD.docx`
- `<Proyecto>-INFORME-DBA.docx`

