# 🚀 Boost DBA 360: Tu Equipo DBA Aumentado con IA

> *En SQL Server la deuda técnica crece silenciosamente: miles de stored procedures sin documentación, dependencias ocultas, cambios que rompen cosas que no esperabas. Boost DBA 360 es un sistema de IA que actúa como equipo DBA: analiza, diagnostica, cuantifica riesgo y guía modernización de forma segura.*

## ¿Qué es Boost DBA 360?

Boost DBA 360 es un **sistema agentico de IA** para operar, diagnosticar, optimizar y modernizar bases de datos SQL Server sin exfiltrar información sensible. Combina 18 agentes especializados con 19 skills reutilizables y una capa de conocimiento anti-alucinación para responder las preguntas clave de rendimiento, riesgo y evolución.

## Modo de Operación Recomendado

Para el día a día no hace falta activar todos los agentes.

Primera ejecución de cada proyecto: obligatoriamente en Modo Full.
Ejecuciones posteriores: Modo Lean por defecto + activación por triggers.

### Modo Lean (recomendado)

Usar solo:

- Orquestador DBA 360
- Analizador de Dependencias de BD
- Exportador de Informes Ejecutivos

Los demás agentes se activan solo por necesidad real (trigger).

### Modo Full

Usar todos los agentes especializados en auditorías amplias, programas de modernización o evaluaciones multi-dominio.

### Regla práctica

Si no hay trigger claro, permanecer en Modo Lean.

## Flujo de Anonimización en Onboarding

Al inicializar un workspace con `run-dba360-wizard.ps1`, ahora se puede elegir modo de anonimización:

- `-Anonymize ask` (por defecto): pregunta interactiva al inicio del wizard.
- `-Anonymize yes`: anonimiza de extremo a extremo.
- `-Anonymize no`: mantiene nombres/identificadores reales.

### Compuerta obligatoria de decisión

- La decisión de anonimización es obligatoria al iniciar el proyecto.
- En modo interactivo, `ask` fuerza pregunta al usuario.
- En ejecuciones no interactivas, se debe pasar explícitamente `-Anonymize yes` o `-Anonymize no`.

### Comandos rápidos

```powershell
# 1) Modo recomendado (pregunta al iniciar)
pwsh -File scripts/run-dba360-wizard.ps1 -ProjectName "MiProyecto" -SchemaPath "input" -Anonymize ask

# 2) Forzar anonimización total (uso externo / compartición con terceros)
pwsh -File scripts/run-dba360-wizard.ps1 -ProjectName "MiProyecto" -SchemaPath "input" -Anonymize yes

# 3) Mantener identificadores reales (uso interno controlado)
pwsh -File scripts/run-dba360-wizard.ps1 -ProjectName "MiProyecto" -SchemaPath "input" -Anonymize no
```

### Recomendación operativa

- **Entorno externo o documentos que saldrán de la organización**: usar `yes`.
- **Entorno interno con controles de acceso y necesidad de trazabilidad real**: usar `no`.
- **Si hay duda**: usar `ask` para decidir caso a caso al iniciar.

### ¿Qué hace el modo anonimizado?

1. Durante bootstrap/refresh anonimiza SQL de `fuente-de-verdad/schema/*.sql` usando la skill `sql-anonymization`.
2. Guarda el estado en `manifest.json`:
    - `anonymizationEnabled: true`
    - `anonymizationMode: "full"`
    - `anonymizationMappings: <ruta al mapping consolidado>`
3. Antes de exportar Word (`export-report.ps1`) sanea automáticamente artefactos en root del workspace, `reports/`, `plans/` y `entrega/` si el manifest está en modo anonimizado.
4. Además, los scripts de generación de artefactos vuelven a aplicar saneado al terminar para mantener `reports/`, `plans/` y `entrega/` ya anonimizados durante todo el flujo (no solo en el export).

### Comportamiento esperado

- Si eliges anonimizar: BD + planes + reports + documentación de entrega salen en alias genéricos.
- Si eliges no anonimizar: el flujo sigue igual, con identificadores reales.

- **"Quiero arrancar y analizarlo todo desde cero"** → DBA 360 Orchestrator ← *empieza aquí*
- **"¿Qué se romperá si cambiamos esto?"** → Change Impact Assessor
- **"¿Cuáles procedimientos son realmente críticos?"** → DB Dependency Analyzer
- **"¿Cuál es la lógica de negocio real?"** → Legacy Logic Extractor
- **"¿Dónde está el cuello de botella?"** → Performance Bottleneck Analyzer
- **"¿Cómo optimizo esta consulta sin romper nada?"** → Query Optimizer
- **"¿Qué riesgos de seguridad/continuidad tenemos?"** → DBA Reliability & Security Advisor
- **"¿Por dónde empezamos a modernizar?"** → Modernization Orchestrator
- **"¿Quién documentará esto?"** → DB Documentation Generator

## Principio Clave: Análisis Completo Sin Exfiltrar Negocio

La propuesta de DB Boost es analizar una BBDD de extremo a extremo sin sacar fuera información sensible por defecto.

- Análisis local primero: el descubrimiento y la evaluación se hacen en el entorno origen.
- Mínimo dato necesario: se prioriza metadata, dependencias y métricas antes que SQL literal.
- Compartición controlada: cualquier salida externa debe pasar por saneado y validación.
- Seguridad por defecto: si algo no es necesario para el diagnóstico, no se comparte.

La seguridad va embebida en el [Orquestador DBA 360](agents/dba-360-orchestrator.agent.md) y en la skill [secure-onboarding](skills/secure-onboarding/SKILL.md): no es un paso manual, es parte del flujo de arranque.

## El Problema que Resolvemos

### La Realidad de las Bases de Datos Heredadas

```
15 años de capas acumuladas
    ↓
Miles de stored procedures
    ↓
Lógica de negocio dispersa por todas partes
    ↓
Dependencias implícitas que nadie comprende
    ↓
Miedo a hacer cualquier cambio
    ↓
La deuda técnica crece exponencialmente
```

**El Costo:**
- Semanas para implementar cambios simples
- Interrupciones frecuentes por modificaciones "inocentes"
- Sin documentación = conocimiento institucional en la cabeza de una persona
- Imposible modernizar: no sabes qué es crítico

**El Miedo:**
- "¿Si refactorizamos este procedimiento, qué se romperá?"
- "¿Podemos eliminar esto de forma segura? No ha sido modificado en 5 años"
- "¿Qué pasará si agregamos un índice nuevo?"
- "¿Quién es responsable de esta parte de la base de datos?"

## Nuestra Solución: Análisis Agentico

### Arquitectura DBA 360

```
┌──────────────────────────────────────────────────────────────────┐
│                   ORQUESTADOR DBA 360  🧭                        │
│     Onboarding · Preflight · Análisis · Derive · Informes        │
└──────────────────────────────────────────────────────────────────┘
       ↓            ↓            ↓            ↓            ↓
  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐
  │Dependen-│ │ Lógica  │ │Rendimien│ │Seguridad│ │Modernización│
  │cias e   │ │de Negoc.│ │to y     │ │y Gobier-│ │y Documenta- │
  │ Impacto │ │en SP    │ │Consultas│ │    no   │ │    ción     │
  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────────┘
       ↓            ↓            ↓            ↓            ↓
┌──────────────────────────────────────────────────────────────────┐
│                  SKILLS ESPECIALIZADAS                           │
│  secure-onboarding · database-analysis · dependency-impact       │
│  performance-diagnostics · query-optimization                    │
│  dba-governance · documentation-recovery                         │
└──────────────────────────────────────────────────────────────────┘
                    ↓            ↓            ↓
             ┌──────────┬────────────┬──────────────┐
             │  sys.*   │    DMVs    │ Query Store  │
             │ Catálogo │  Rendimien │  Planes y    │
             │ de objetos│  to vivo  │  estadísticas│
             └──────────┴────────────┴──────────────┘
```

## Agentes Especializados

### 0. **Orquestador DBA 360** 🧭 — *El Wizard de Entrada*
El punto de arranque. Inicializa el proyecto, crea la fuente de verdad local, ejecuta el preflight de seguridad y después orquesta el análisis completo o deriva al agente especializado que corresponda.

```
Usar cuando: "Inicializa mi proyecto" / "Haz una evaluación DBA completa desde cero"
Salida: fuente de verdad local + informe 360 + roadmap de acción
```

### 1. **Analizador de Dependencias de BD** 🔍
Descubre qué está realmente conectado a qué.

```
Entrada: Base de datos heredada de SQL Server
Salida: Mapas de dependencias, puntuaciones de criticidad, cadenas de impacto

Usar cuando: "¿Cuáles procedimientos son realmente críticos para la producción?"
Ejemplo: Mapea 47 procedimientos → identifica 3 núcleo, 12 utilidad, 32 candidatos para eliminar
```

### 2. **Extractor de Lógica Legacy** 📖
Extrae lógica de negocio enterrada de procedimientos.

```
Entrada: Stored procedures con lógica compleja
Salida: Documentación de reglas de negocio, especificaciones de algoritmos

Usar cuando: "¿Qué hace realmente este procedimiento de 500 líneas?"
Ejemplo: Descubre lógica de descuento duplicada en 3 procedimientos, sugiere consolidación
```

### 3. **Evaluador de Impacto de Cambios** ⚠️
Muestra qué se romperá antes de que lo rompas.

```
Entrada: Cambio propuesto en la base de datos
Salida: Análisis de radio de impacto, estrategia de pruebas, plan de reversión

Usar cuando: "¿Es seguro renombrar esta columna?"
Ejemplo: "154 objetos dependientes serán afectados. Riesgo: ALTO. Estrategia de pruebas: ..."
```

### 4. **Generador de Documentación de BD** 📝
Crea documentación faltante a partir de la realidad del código.

```
Entrada: Schema de base de datos y procedimientos
Salida: Diccionario de datos, especificaciones de procedimientos, diagramas de flujo de datos, runbooks

Usar cuando: "Necesitamos documentación pero nadie la escribió"
Ejemplo: Genera especificación completa a partir de un escaneo de 2 horas de la base de datos
```

### 5. **Orquestador de Modernización** 🎯
Controlador maestro de todo el viaje de DB Boost.

```
Entrada: Base de datos heredada + objetivos de modernización
Salida: Roadmap de modernización por fases con quick wins

Usar cuando: "Ayúdanos a modernizar esto de forma segura sin romper cosas"
Ejemplo: Prioriza 15 iniciativas de modernización en 4 trimestres
```

### 6. **Analizador de Cuellos de Botella** ⚡
Diagnostica lentitud en SQL Server con evidencia de waits, bloqueos y top consultas.

```
Entrada: síntoma (timeouts, CPU alta, bloqueos) + ventana temporal
Salida: top offenders priorizados, causa raíz probable, plan de mitigación

Usar cuando: "La BBDD va lenta a ciertas horas" / "Tenemos timeouts en producción"
```

### 7. **Optimizador de Consultas SQL** 🧠
Optimiza consultas, planes e índices con validación antes/después y control de riesgo.

```
Entrada: consulta o SP + métricas baseline
Salida: versión optimizada, índices sugeridos, checklist de regresión

Usar cuando: "Este SP tarda 40s" / "Necesito reducir CPU de reportes"
```

### 8. **Asesor DBA de Fiabilidad y Seguridad** 🔐
Evalúa riesgos de continuidad, permisos excesivos, hardening y recuperación.

```
Entrada: instancia SQL Server objetivo
Salida: hallazgos de riesgo priorizados, plan de remediación, checklist de continuidad

Usar cuando: "Auditoria DBA" / "¿Podemos recuperar la BD en menos de 1 hora?"
```

### 9. **Asesor de Mantenimiento Proactivo** 🔧
Detecta índices fragmentados, estadísticas obsoletas e índices sin uso, y genera el plan de mantenimiento.

```
Entrada: base de datos objetivo + umbrales configurables
Salida: lista priorizada de acciones + scripts de mantenimiento + schedule recomendado

Usar cuando: "¿Qué índices necesitan mantenimiento?" / "Los planes de ejecución empeoraron"
```

### 10. **Asesor de Capacity Planning** 📈
Analiza crecimiento histórico y proyecta necesidades de almacenamiento y recursos a futuro.

```
Entrada: instancia + horizonte de proyección (3/6/12 meses)
Salida: proyección de almacenamiento, riesgos de capacidad, configuración de autogrowth

Usar cuando: "¿Cuándo nos quedamos sin espacio?" / "Planifica el almacenamiento del próximo año"
```

### 11. **Asesor de Monitorización y Baseline** 📊
Establece qué es "normal" en el sistema y detecta desviaciones antes de que impacten a usuarios.

```
Entrada: instancia + ventana de baseline
Salida: baseline por franja horaria, anomalías detectadas, umbrales de alerta recomendados

Usar cuando: "¿Esto es normal o una anomalía?" / "Define umbrales de alerta para nuestra BD"
```

### 12. **Analizador de Jobs y Automatización SQL** ⚙️
Audita SQL Agent jobs: fallos, schedules en conflicto, jobs obsoletos y dependencias implícitas.

```
Entrada: instancia + ventana temporal
Salida: inventario de jobs, fallos, solapamientos, recomendaciones de reorganización

Usar cuando: "¿Qué jobs fallaron?" / "¿Hay jobs que se solapan y compiten por recursos?"
```

### 13. **Asesor de Alta Disponibilidad** 🏗️
Evalúa AlwaysOn, replicación y log shipping, calcula RTO/RPO real y genera runbook de failover.

```
Entrada: instancia con HA configurado + objetivos RTO/RPO
Salida: estado de réplicas, RPO/RTO alcanzable, gaps y runbook de failover

Usar cuando: "¿Nuestro AlwaysOn está bien?" / "¿Podemos hacer failover en menos de X minutos?"
```

### 14. **Generador de Scripts de Migración** 📝
Produce scripts de cambio de schema/datos con rollback explícito, validaciones y plan de despliegue.

```
Entrada: descripción del cambio + entornos objetivo
Salida: script de rollout + rollback + checklist go/no-go + estimación de ventana

Usar cuando: "Genera el script para este cambio con su rollback" / "Crea el plan de despliegue"
```

### 15. **Generador de Datos de Prueba** 🧪
Crea datos sintéticos realistas respetando constraints y relaciones, con anonimización de datos sensibles.

```
Entrada: schema objetivo + volumen + columnas sensibles
Salida: script de datos sintéticos + anonimización + validación de integridad

Usar cuando: "Genera datos de prueba para staging" / "Anonimiza este subconjunto de producción"
```

### 16. **Asesor Cross-Platform** 🌐
Contrasta recomendaciones con documentación oficial y evalúa viabilidad de migración entre plataformas.

```
Entrada: instancia SQL Server + plataforma destino (Azure SQL, PostgreSQL, AWS RDS...)
Salida: informe de compatibilidad, blockers, equivalencias y ruta de migración

Usar cuando: "¿Podemos migrar a Azure SQL?" / "¿Cómo se hace esto en PostgreSQL?"
Ejemplo: Detecta que hierarchyid, OPEN SYMMETRIC KEY y compat 140 son blockers para Azure SQL Hyperscale
```

### 17. **Exportador de Informes Ejecutivos** 📄
Compone documentos de entrega profesionales a partir de los artefactos DBA 360 y los exporta a Word (.docx).

```
Entrada: workspace con análisis DBA 360 completo + audiencia objetivo
Salida: 5 documentos .docx en workspaces/<Proyecto>/entrega/

Usar cuando: "Necesito un informe para el cliente" / "Quiero presentar esto a dirección"
Ejemplo: Genera INFORME-CLIENTE, INFORME-FUNCIONAL, ASSESSMENT, INFORME-TECHLEAD e INFORME-DBA en entrega/ con portada, TOC y diagramas
```

## Habilidades Reutilizables

### **database-analysis** 📊
Extrae schema, procedimientos, metadatos, estadísticas de ejecución. La base para todo análisis.

### **dependency-impact** 🔗
Mapea dependencias, analiza cadenas de impacto, identifica radio de impacto, calcula niveles de riesgo.

### **documentation-recovery** 📚
Genera diccionarios de datos, especificaciones de procedimientos, diagramas ER, documentación de linaje de datos.

### **performance-diagnostics** ⚡
Detecta cuellos de botella por CPU, IO, waits, bloqueos y regresiones de plan.

### **query-optimization** 🧠
Aplica tuning de SQL y estrategias de índices con validación de regresión.

### **dba-governance** 🔐
Audita seguridad, permisos, backup/restore y madurez operativa DBA.

### **human-in-the-loop** 👤
Compuerta de decisión humana: define qué puede hacer el agente solo (análisis, scripts), qué requiere confirmación y qué está bloqueado sin aprobación explícita (DROP, failover, cambios de seguridad en producción).

### **security-loop** 🔄
Compuerta de seguridad continua: se ejecuta en inicio, análisis y entrega. No es un paso único, es un loop embebido en cada fase.

### **cross-platform-validation** 🌐
Contrasta recomendaciones con documentación oficial (SQL Server, Azure SQL, PostgreSQL, AWS RDS, Cosmos DB) y mapea equivalencias entre plataformas.

### **secure-onboarding** 🛡️
Crea la fuente de verdad local, ejecuta preflight y bloquea exfiltración accidental de negocio.

### **proactive-maintenance** 🔧
Detecta fragmentación, estadísticas obsoletas e índices problemáticos con scripts de mantenimiento listos.

### **capacity-planning** 📈
Analiza tendencias de crecimiento y proyecta almacenamiento y recursos a 3/6/12 meses.

### **monitoring-baseline** 📊
Captura baseline de métricas, detecta anomalías y define umbrales de alerta ajustados a la realidad.

### **jobs-automation** ⚙️
Inventaría SQL Agent jobs, detecta fallos, solapamientos y jobs obsoletos con recomendaciones.

### **high-availability** 🏗️
Valida estado de AlwaysOn/replicación, calcula RTO/RPO real y genera runbooks de failover.

### **migration-scripting** 📝
Estructura estándar para scripts de migración seguros: transacción, rollback, pre/post checks.

### **test-data-generation** 🧪
Genera datos sintéticos respetando constraints y anonimiza subconjuntos de producción para testing.

## Estructura del Proyecto

```
BoostDBA/
├── workspaces/                          # ← En .gitignore: datos de cliente nunca a git
│   └── <ProjectName>/                   # Un directorio por proyecto analizado
│       ├── fuente-de-verdad/            # Schema SQL + manifest.json (no versionado)
│       ├── reports/                     # Reportes MD generados (sí versionados)
│       ├── plans/                       # Roadmaps de acción
│       └── logs/                        # Trazabilidad de sesiones
│
├── agents/                              # Agentes especializados
│   ├── dba-360-orchestrator.agent.md
│   ├── db-dependency-analyzer.agent.md
│   ├── legacy-logic-extractor.agent.md
│   ├── change-impact-assessor.agent.md
│   ├── db-documentation-generator.agent.md
│   ├── performance-bottleneck-analyzer.agent.md
│   ├── query-optimizer.agent.md
│   ├── dba-reliability-security-advisor.agent.md
│   ├── modernization-orchestrator.agent.md
│   ├── proactive-maintenance-advisor.agent.md
│   ├── capacity-planning-advisor.agent.md
│   ├── monitoring-baseline-advisor.agent.md
│   ├── sql-agent-jobs-analyzer.agent.md
│   ├── high-availability-advisor.agent.md
│   ├── migration-script-generator.agent.md
│   ├── test-data-generator.agent.md
│   └── cross-platform-advisor.agent.md
│
├── skills/                              # Capacidades reutilizables
│   ├── secure-onboarding/               # onboarding + fuente de verdad + preflight
│   ├── database-analysis/               # extracción de schema y metadatos
│   ├── dependency-impact/               # dependencias y análisis de impacto
│   ├── documentation-recovery/          # generación de documentación
│   ├── performance-diagnostics/         # waits, bloqueos, top consultas
│   ├── query-optimization/              # tuning de SQL e índices
│   ├── dba-governance/                  # seguridad, backups y continuidad
│   ├── proactive-maintenance/           # índices, estadísticas, fragmentación
│   ├── capacity-planning/               # crecimiento y proyecciones de almacenamiento
│   ├── monitoring-baseline/             # baseline, anomalías y umbrales de alerta
│   ├── jobs-automation/                 # SQL Agent jobs, fallos y schedules
│   ├── high-availability/               # AlwaysOn, replicación, RTO/RPO
│   ├── migration-scripting/             # scripts de migración con rollback
│   ├── test-data-generation/            # datos sintéticos y anonimización
│   ├── security-loop/                   # compuerta de seguridad continua por fase
│   ├── human-in-the-loop/               # compuerta de decisión humana en acciones de impacto
│   └── cross-platform-validation/       # validación contra docs oficiales multi-plataforma
│
├── examples/                            # Casos de estudio con SQL real ejecutable
│   └── legacy-sql-server/
│       ├── erp-database.sql            # BD ERP heredada: 47 SPs, deuda técnica real
│       ├── analysis-queries.sql         # Queries de análisis listas para ejecutar
│       └── README.md                    # Guía del caso de estudio
│
├── templates/                           # Plantillas reutilizables para cada entregable
│   ├── modernization/
│   │   ├── migration-plan.md           # Plan de modernización por fases (Quick Wins → Cutover)
│   │   ├── impact-analysis-template.md # Análisis de impacto de cambio propuesto
│   │   └── documentation-template.md   # Documentación de BD: tablas, SPs, relaciones
│   └── reports/
│       ├── dba-360-assessment-template.md
│       ├── performance-bottleneck-report-template.md
│       ├── security-reliability-audit-template.md
│       ├── proactive-maintenance-report-template.md
│       ├── capacity-planning-report-template.md
│       ├── monitoring-baseline-report-template.md
│       ├── jobs-automation-report-template.md
│       ├── high-availability-report-template.md
│       ├── modernization-report-template.md
│       └── dependency-impact-report-template.md
│
├── specs/                               # Reglas conductuales y encuadre de sesion
│   ├── agent-behavioral-spec.md         # Reglas anti-alucinacion: evidencia, confianza, limites
│   └── session-framing-guide.md         # Como encuadrar sesiones DBA para maxima precision
│
├── references/                          # Fuentes oficiales por plataforma
│   └── official-docs.md                 # SQL Server, Azure SQL, PostgreSQL, AWS RDS, Cosmos DB
│
├── patterns/                            # 13 anti-patrones individuales (uno por archivo)
│   ├── README.md                        # Índice por categoría: mantenibilidad, rendimiento, seguridad...
│   ├── logica-negocio-dispersa.md
│   ├── dependencias-implicitas.md
│   ├── cursores-vs-set-based.md
│   ├── dynamic-sql-sin-parametrizar.md
│   └── ...                              # y 9 más
│
├── scripts/                             # Scripts de automatización
│   ├── run-dba360-wizard.ps1           # ★ Punto de entrada: crea workspaces/<Proyecto>/
│   ├── bootstrap-source-of-truth.ps1   # Crea estructura fuente-de-verdad/ y manifest.json
│   ├── refresh-source-of-truth.ps1     # Actualiza schema existente + diff de objetos + historial
│   └── security-preflight.ps1          # Preflight: detecta credenciales, secretos, rutas sensibles
│
├── .gitignore                           # Protege workspaces/ e input/ — data de cliente nunca a git
└── README.md                            # Este archivo
```

## Cómo Empezar: 3 Pasos

### 1️⃣ Arranca el Wizard de Onboarding

Ejecutar desde PowerShell:

```powershell
# Desde la raíz del repositorio BoostDBA
pwsh -File scripts\run-dba360-wizard.ps1 -ProjectName "MiProyecto" -SchemaPath "C:\tus-esquemas"
```

O con connection string directa al servidor SQL:

```powershell
pwsh -File scripts\run-dba360-wizard.ps1 -ProjectName "MiProyecto" -ConnectionString "Server=.;Database=MiDB;Integrated Security=true"
```

**Qué hace el wizard:**
1. Crea `workspaces/MiProyecto/` dentro del repo (protegido por `.gitignore`)
2. Copia el schema SQL y genera la fuente de verdad local
3. Ejecuta preflight de seguridad (detecta credenciales, datos sensibles, rutas prohibidas)
4. Genera `manifest.json` con inventario completo (tablas, SPs, funciones, índices, FKs)
5. Listo para análisis sin conexión continua al servidor

> **¿Por qué dentro del repo?**  
> La carpeta `workspaces/` vive dentro del repo pero está en `.gitignore`: el dato de cliente nunca entra a git. Tienes trazabilidad de los reportes generados (sí versionados) sin filtrar el schema o la fuente de verdad.

**Estructura creada:**
```
BoostDBA/
└── workspaces/
    └── MiProyecto/                  # ← gitignored (fuente de verdad)
        ├── fuente-de-verdad/
        │   ├── schema/db.sql        # Schema original (nunca a git)
        │   ├── manifest.json        # Inventario de objetos
        │   └── tables-by-schema.json
        ├── reports/                 # Reportes MD generados por agentes
        ├── plans/                   # Roadmaps y planes de acción
        └── logs/                    # Trazabilidad de sesiones
```

---

### 1b. Actualizar un workspace existente (cuando cambia el schema)

Cuando el equipo despliega cambios a la base de datos, actualiza la fuente de verdad sin perder reportes ni planes:

```powershell
# Reingesta el nuevo schema y recalcula el inventario
pwsh -File scripts\refresh-source-of-truth.ps1 -ProjectName "MiProyecto" -SchemaPath "C:\nuevo-dump"

# Solo regenerar manifest (sin schema nuevo)
pwsh -File scripts\refresh-source-of-truth.ps1 -ProjectName "MiProyecto"
```

**Qué hace el refresh:**
- Reemplaza los archivos en `fuente-de-verdad/schema/` con el nuevo dump
- Recalcula el inventario (tablas, SPs, funciones, índices, FKs)
- Muestra un **diff** vs. la ingesta anterior: cuántos objetos se añadieron o eliminaron
- Actualiza `manifest.json` con `updatedAt` y `refreshCount`
- Append a `ingestion-log.json` (historial completo de ingestas)
- Re-ejecuta el preflight de seguridad sobre el nuevo schema
- **No borra** reportes, planes ni logs existentes

```
Ejemplo de diff:
  tables    :     +3  (antes: 1787, ahora: 1790)
  procs     :    +12  (antes: 6357, ahora: 6369)
  functions :      0  (sin cambios)
  indexes   :     -1  (antes: 1301, ahora: 1300)
```

> **Cuándo actualizar:** tras cada despliegue de schema a producción, o cuando el equipo de DBA pide que los reportes reflejen el estado actual.

---

### 2️⃣ Abre el Orquestador DBA 360 en tu IDE

En VS Code con Copilot, selecciona el agente **[DBA 360 Orchestrator](agents/dba-360-orchestrator.agent.md)** y pregunta:

> *"Haz una evaluación DBA 360 sobre workspaces/MiProyecto"*

El orquestador:
- Lee la fuente de verdad local
- Analiza dependencias, lógica de negocio, rendimiento, seguridad
- Genera informe ejecutivo con top 5 acciones priorizadas
- Propone roadmap de modernización por fases

---

### 3️⃣ Usa los agentes especializados según necesites

A partir de ahora, la fuente de verdad local es tu verdad: sin conexión continua, sin riesgo de exfiltración. Elige el agente por pregunta concreta:

| Necesito... | Agente |
|-------------|--------|
| Entender dependencias y qué es crítico | [db-dependency-analyzer](agents/db-dependency-analyzer.agent.md) |
| Saber qué hace un SP por dentro | [legacy-logic-extractor](agents/legacy-logic-extractor.agent.md) |
| Saber el impacto de un cambio antes de hacerlo | [change-impact-assessor](agents/change-impact-assessor.agent.md) |
| Encontrar por qué va lento / hay timeouts | [performance-bottleneck-analyzer](agents/performance-bottleneck-analyzer.agent.md) |
| Optimizar una consulta sin romper nada | [query-optimizer](agents/query-optimizer.agent.md) |
| Auditoría de seguridad, backups y continuidad | [dba-reliability-security-advisor](agents/dba-reliability-security-advisor.agent.md) |
| Documentar la BBDD automáticamente | [db-documentation-generator](agents/db-documentation-generator.agent.md) |
| Plan completo de modernización | [modernization-orchestrator](agents/modernization-orchestrator.agent.md) |
| Comparar con otra plataforma / validar contra docs oficiales | [cross-platform-advisor](agents/cross-platform-advisor.agent.md) |
| Evaluación integral desde cero | [dba-360-orchestrator](agents/dba-360-orchestrator.agent.md) |
| Índices fragmentados / estadísticas obsoletas | [proactive-maintenance-advisor](agents/proactive-maintenance-advisor.agent.md) |
| ¿Cuándo nos quedamos sin espacio? | [capacity-planning-advisor](agents/capacity-planning-advisor.agent.md) |
| ¿Esto es normal o una anomalía? | [monitoring-baseline-advisor](agents/monitoring-baseline-advisor.agent.md) |
| Jobs fallidos / schedules en conflicto | [sql-agent-jobs-analyzer](agents/sql-agent-jobs-analyzer.agent.md) |
| Estado de AlwaysOn / RTO-RPO real | [high-availability-advisor](agents/high-availability-advisor.agent.md) |
| Generar script de cambio con rollback | [migration-script-generator](agents/migration-script-generator.agent.md) |
| Datos de prueba para staging/dev | [test-data-generator](agents/test-data-generator.agent.md) |
| Comparar con otra plataforma / validar contra docs oficiales | [cross-platform-advisor](agents/cross-platform-advisor.agent.md) |

## Modelo de Seguridad

Boost DBA 360 aplica **seguridad por defecto** en cada capa:

| Capa | Protección | Cómo |
|---|---|---|
| **Datos de cliente** | Nunca a git | `workspaces/` e `input/` en `.gitignore` |
| **Connection strings** | Redactadas antes de persistir | `bootstrap-source-of-truth.ps1` enmascara host, DB, user, password |
| **Schema SQL** | Local solamente | Nunca sale de `workspaces/<Proyecto>/fuente-de-verdad/` |
| **Secretos en schema** | Detectados y reportados | `security-preflight.ps1` escanea passwords, tokens, API keys |
| **Reportes** | Solo metadata y hallazgos | Sin SQL literal ni datos de negocio en salidas externas |
| **Exfiltración** | Bloqueada por diseño | El análisis se hace local; el agente trabaja sobre manifests, no datos raw |

**Preflight de Seguridad** — se ejecuta automáticamente tras bootstrap:
```
Patrones detectados: passwords, API keys, client secrets, tokens, connection strings
Extensiones analizadas: .sql, .json, .yml, .config, .xml, .cs, .md
Resultado: PASS / FAIL con ubicación exacta del hallazgo
```

---

## Stack Técnico

- **Plataforma objetivo**: SQL Server 2016+, Azure SQL
- **Análisis estático**: Regex sobre schema SQL (sin conexión necesaria)
- **Análisis en vivo**: Vistas de catálogo (`sys.*`), DMVs, Query Store
- **IA**: 18 agentes LLM especializados por dominio DBA + 19 skills reutilizables
- **Automatización**: PowerShell (bootstrap, preflight, wizard)
- **Salidas**: Markdown, JSON, diagramas Mermaid, plantillas de informe
- **IDE**: VS Code + GitHub Copilot (modo Agent)

## Ejemplos Incluidos

### BD ERP Legacy — Caso de Estudio Completo
Ubicación: [examples/legacy-sql-server/](examples/legacy-sql-server/)

Una base de datos SQL Server realista en producción desde 2005 que acumula todos los problemas típicos: código muerto, lógica duplicada, dependencias ocultas, valores hardcoded y documentación inexistente. Perfecta para probar Boost DBA desde cero sin tocar tu BD real.

| Fichero | Qué contiene |
|---------|-------------|
| [erp-database.sql](examples/legacy-sql-server/erp-database.sql) | 47 SPs, 5 tablas, dependencias ocultas y deuda técnica intencional |
| [analysis-queries.sql](examples/legacy-sql-server/analysis-queries.sql) | Queries de análisis `sys.*` y DMVs listas para ejecutar |
| [README.md](examples/legacy-sql-server/README.md) | Guía del caso: qué encontrarás y qué debería detectar cada agente |

## Plantillas de Entregables

Úsalas directamente como output de cada sesión de análisis.

### Modernización
| Plantilla | Cuándo usarla |
|-----------|--------------|
| [migration-plan.md](templates/modernization/migration-plan.md) | Planificar modernización por fases con Quick Wins, hitos y criterios de éxito |
| [impact-analysis-template.md](templates/modernization/impact-analysis-template.md) | Documentar el impacto de un cambio propuesto antes de ejecutarlo |
| [documentation-template.md](templates/modernization/documentation-template.md) | Generar documentación completa de tablas, SPs y relaciones |

### Informes Ejecutivos DBA
| Plantilla | Agente que la genera |
|-----------|---------------------|
| [dba-360-assessment-template.md](templates/reports/dba-360-assessment-template.md) | dba-360-orchestrator |
| [performance-bottleneck-report-template.md](templates/reports/performance-bottleneck-report-template.md) | performance-bottleneck-analyzer |
| [security-reliability-audit-template.md](templates/reports/security-reliability-audit-template.md) | dba-reliability-security-advisor |
| [proactive-maintenance-report-template.md](templates/reports/proactive-maintenance-report-template.md) | proactive-maintenance-advisor |
| [capacity-planning-report-template.md](templates/reports/capacity-planning-report-template.md) | capacity-planning-advisor |
| [monitoring-baseline-report-template.md](templates/reports/monitoring-baseline-report-template.md) | monitoring-baseline-advisor |
| [jobs-automation-report-template.md](templates/reports/jobs-automation-report-template.md) | sql-agent-jobs-analyzer |
| [high-availability-report-template.md](templates/reports/high-availability-report-template.md) | high-availability-advisor |
| [modernization-report-template.md](templates/reports/modernization-report-template.md) | modernization-orchestrator |
| [dependency-impact-report-template.md](templates/reports/dependency-impact-report-template.md) | change-impact-assessor |

## Base de Conocimiento

### [Especificaciones de Comportamiento](specs/)

Dos documentos que evitan alucinaciones y mantienen el foco en cada sesion:

**[README.md](specs/README.md)** — Guía de encaje: cómo se combinan `specs`, `patterns` y `references` en el flujo operativo.

**[agent-behavioral-spec.md](specs/agent-behavioral-spec.md)** — Reglas obligatorias para todos los agentes:
- Sin evidencia, sin afirmacion: cada hallazgo cita la query/DMV que lo produjo
- Niveles de confianza explícitos: ALTA / MEDIA / BAJA / SIN DATOS
- Limites declarados: SQL dinamico, dependencias runtime, historia previa
- Separacion estricta de hecho vs interpretacion vs recomendacion
- Escalado HITL obligatorio cuando la confianza es baja y el impacto es alto

**[session-framing-guide.md](specs/session-framing-guide.md)** — Como encuadrar cada sesion DBA:
- Plantilla de contexto inicial (plataforma, entorno, objetivo, restricciones)
- Modos de sesion: Diagnostico / Recomendacion / Planificacion / Revision
- Senales de que la sesion esta perdiendo el foco y como reencuadrar
- Como cerrar correctamente para no perder contexto entre sesiones

### [Anti-Patrones Comunes](patterns/README.md)
13 patrones de deuda técnica organizados por categoría, cada uno con ejemplos SQL reales, queries de detección y estrategia de modernización:
- **Mantenibilidad**: lógica dispersa, valores hardcoded, procedimientos monolíticos
- **Rendimiento**: cursores, índices faltantes, parameter sniffing
- **Estabilidad**: transacciones sin cierre, tablas sin PK
- **Trazabilidad**: dependencias implícitas, triggers en cascada, sin auditoría
- **Seguridad**: dynamic SQL sin parametrizar (OWASP A03)

### [Referencias Oficiales](references/official-docs.md)
Fuentes de verdad oficiales por plataforma para validar recomendaciones antes de emitirlas:
- **SQL Server**: DMVs, Query Store, índices, seguridad, AlwaysOn, SQL Agent
- **Azure SQL**: Intelligent QP, auto-tuning, Defender, geo-replication, Hyperscale
- **AWS RDS / Aurora**: Performance Insights, Multi-AZ, IAM auth, Aurora Global
- **PostgreSQL**: EXPLAIN, pg_stat_statements, autovacuum, Patroni, Row Security
- **Cosmos DB**: Partitioning, Request Units, indexing policies, consistency levels

## Recursos

- [Agentes](agents/)
- [Habilidades](skills/)
- [Plantillas de Informe DBA](templates/reports/)
- [Caso de Estudio ERP](examples/legacy-sql-server/README.md)
- [Patrones de Modernización](patterns/)

---

*Trae tu BBDD. Abre el orquestador. El resto lo hace él.*





