# Clasificación de SPs — Esquema `bi` (Reporting)

**Fecha:** 2026-06-07  
**Esquema:** `bi` — Motor de reporting (1.195 SPs, 1 tabla física)  
**Clasificación:** Todo el esquema es 🟢 **CRUD puro de lectura** → candidato ideal para migración Q1

---

## Regla General del Esquema `bi`

> **100% del esquema `bi` es `SELECT` sin efectos secundarios.**  
> No contiene INSERT, UPDATE, DELETE, transacciones, cursores, ni lógica de escritura.  
> Es el esquema más seguro para empezar la migración a Dapper.

---

## Patrones de Naming → Clasificación Directa

| Sufijo | Patrón | Clasificación | Estrategia C# |
|---|---|---|---|
| `*_S` | `SELECT` puro | 🟢 CRUD puro | Dapper `QueryAsync<T>` |
| `*_S` (XML) | `SELECT ... FOR XML` | 🟢 CRUD puro | Dapper + `XDocument` parse |
| Sin sufijo (e.g. `AgrupacionAmbito`) | `SELECT` histórico sin nomenclatura | 🟢 CRUD puro | Dapper `QueryAsync<T>` |

---

## Inventario Clasificado (A-B, primeras ~55 detectadas)

| SP | Clasificación | Params | Complejidad Query | Target C# |
|---|---|---|---|---|
| `bi.AAFF_S` | 🟢 CRUD | Conv, Expte | Simple | Dapper |
| `bi.AAFFExperiencia_S` | 🟢 CRUD | Conv, Expte | Simple | Dapper |
| `bi.AccionesFormativas_S` | 🟢 CRUD | Conv, Expte | Media (joins) | Dapper |
| `bi.AccionesFormativasAmpliacionPlazo_S` | 🟢 CRUD | Conv | Simple | Dapper |
| `bi.AccionesFormativasCentrosReformulacion_S` | 🟢 CRUD | Conv, Expte | Alta (subquery) | Dapper |
| `bi.AccionesFormativasCentrosReformulados_S` | 🟢 CRUD | Conv, Expte | Alta (subquery) | Dapper |
| `bi.AccionesFormativasCentrosReformuladosErte_S` | 🟢 CRUD | Conv, Expte | Alta (ERTE logic) | Dapper |
| **`bi.AccionesFormativasPlanFormacion_S`** | **🟢 CRUD** | **Conv, Expte (9)** | **Alta (14 JOINs, subquery titulación)** | **Dapper ← PILOTO** |
| `bi.AccionesFormativasPlanFormacionInfo_S` | 🟢 CRUD | Conv, Expte | Media | Dapper |
| `bi.AccionesFormativasSubcontratadasConceptos_S` | 🟢 CRUD | Conv, Expte | Simple | Dapper |
| `bi.AccionesFormatvasCCT_S` | 🟢 CRUD | Conv | Media | Dapper |
| `bi.AccionFormativaTeleformacionVT_S` | 🟢 CRUD | Conv, Expte | Media | Dapper |
| `bi.ActividadCertificadaXML_S` | 🟢 CRUD | Conv, Expte | Alta (XML output) | Dapper + XDocument |
| `bi.Agrupacion_S` | 🟢 CRUD | Conv | Simple | Dapper |
| `bi.AgrupacionAmbito` | 🟢 CRUD | Conv | Media | Dapper |
| `bi.AgrupacionDatosPropuesta` | 🟢 CRUD | Conv | Alta (agregaciones) | Dapper |
| `bi.AgrupacionDatosPropuestaMCR_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AgrupacionDatosPropuestaMCRP_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.Agrupaciones_S` | 🟢 CRUD | Conv | Simple | Dapper |
| `bi.AgrupacionesDatosNotExp_S` | 🟢 CRUD | Conv | Media | Dapper |
| `bi.AgrupacionesRepresentatividad_S` | 🟢 CRUD | Conv | Media | Dapper |
| `bi.AgrupacionExpedientesAprobados` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AgrupacionExpedientesAprobadosMCR_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AgrupacionExpedientesAprobadosMCRP_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AgrupacionExpedientesDenegados` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AgrupacionExpedientesDesistidos` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AgrupacionInformeOrganoColegiadoVT` | 🟢 CRUD | Conv | Alta (VT calc) | Dapper |
| `bi.AgrupacionInformeOrganoInstructor` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AgrupacionInformeOrganoInstructorMCR_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AgrupacionInformeOrganoInstructorMCRP_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AgrupacionrSolicitantes_S` | 🟢 CRUD | Conv | Simple | Dapper |
| `bi.AlegacionesDesestimadas_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AlegacionesPresentadas_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.aleInformeTecnicoAlegacionesDetalle_S` | 🟢 CRUD | Conv | Media | Dapper |
| `bi.Ambito_S` | 🟢 CRUD | Conv | Simple | Dapper |
| `bi.AmbitoFinanciacion_S` | 🟢 CRUD | Conv | Media | Dapper |
| `bi.AmpliacionDocumentacionAdjunta_S` | 🟢 CRUD | Conv | Simple | Dapper |
| `bi.AnexoCertificacionGrupos_S` | 🟢 CRUD | Conv | Alta (certificación) | Dapper |
| `bi.AnexoColectivosPrioritarios_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AnexoParticipantesCertificadosExcesoSubsanacion_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AnexoPersonalInterno_S` | 🟢 CRUD | Conv | Alta (personal) | Dapper |
| `bi.AnexoResumenCostesCertificados_S` | 🟢 CRUD | Conv | Alta (costes) | Dapper |
| `bi.AnexoResumenCostesCertificadosOCS_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AnexoResumenMinoracionesParticipantes_S` | 🟢 CRUD | Conv | Alta | Dapper |
| `bi.AnexoVisitas_S` | 🟢 CRUD | Conv, Expte | Simple | Dapper |
| `bi.AñoConvocatoriaActual_S` | 🟢 CRUD | - | Simple (scalar) | Dapper scalar |
| `bi.Anulacion_S` | 🟢 CRUD | Conv | Simple | Dapper |
| `bi.AnulacionesEspecialesGrupo_S` | 🟢 CRUD | Conv, Expte | Media | Dapper |
| `bi.AnulacionesEspecialesParticipante_S` | 🟢 CRUD | Conv, Expte | Alta | Dapper |
| `bi.AreasPrioritarias` | 🟢 CRUD | Conv | Media | Dapper |
| `bi.AreasPrioritarias_S` | 🟢 CRUD | Conv | Media | Dapper |
| `bi.AsistentesVista_S` | 🟢 CRUD | Conv | Media | Dapper |
| `bi.AulasReformulacionCentrosModificados_S` | 🟢 CRUD | Conv, Expte | Alta | Dapper |
| `bi.Ayudas_S` | 🟢 CRUD | Conv, Expte | Alta (costes) | Dapper |
| `bi.BI_S_VT_POR_SECTOR` | 🟢 CRUD | Conv | Alta (VT) | Dapper |
| `bi.BI_S_VT_VALORACION_TECNICA` | 🟢 CRUD | Conv | Alta (VT calc) | Dapper |
| `bi.BI_S_VT_VALORACION_TECNICA_JOVENES` | 🟢 CRUD | Conv | Alta (VT calc) | Dapper |
| `bi.BI_S_VT_X_AAAFF` | 🟢 CRUD | Conv | Alta (VT) | Dapper |
| `bi.BloquesControlFondos_S` | 🟢 CRUD | Conv | Alta (fondos) | Dapper |
| `bi.BYAAnexoSPEEExpedientes_S` | 🟢 CRUD | Conv | Alta (SPEE) | Dapper |
| `bi.BYAAnexoSPEEInfo_S` | 🟢 CRUD | Conv | Alta (SPEE) | Dapper |

---

## Estimación de Migración — Esquema `bi`

| Complejidad Query | SPs Estimados | Horas/SP | Total |
|---|---|---|---|
| Simple (< 5 JOINs, sin subquery) | ~300 | 1-2h | 300-600h |
| Media (5-10 JOINs, subquery simple) | ~500 | 2-4h | 1.000-2.000h |
| Alta (10+ JOINs, subquery compleja, agregaciones) | ~395 | 4-6h | 1.580-2.370h |
| **TOTAL bi** | **1.195** | — | **2.880-4.970h** |

**Con 2 devs a 40h/semana → 36-62 semanas solo para `bi`.**  
**Acelerar con generación automática de boilerplate (template + codegen).**

---

## Grupos de Migración por Nombre (Quick Clusters)

Migrar en lotes por prefijo de nombre para reutilizar DTOs:

| Lote | Prefijo | Aprox. SPs | DTO compartido |
|---|---|---|---|
| 1 | `AccionesFormativas*` | ~12 | `AccionFormativaDto` |
| 2 | `Agrupacion*` | ~15 | `AgrupacionDto` |
| 3 | `Alegaciones*` | ~5 | `AlegacionDto` |
| 4 | `Anexo*` | ~10 | `AnexoDto` (varies) |
| 5 | `Anulacion*` | ~5 | `AnulacionDto` |
| 6 | `BI_S_VT_*` | ~4 | `ValoracionTecnicaDto` |
| ... | ... | ... | ... |

**SP piloto elegido:** `AccionesFormativasPlanFormacion_S` (representa la complejidad típica del cluster #1).

---

## Notas de Nomenclatura

Los SPs de `bi` siguen dos convenciones mezcladas:
- Mayoría: `PascalCase` sin prefijo (`AgrupacionAmbito`)  
- Algunos legacy: `MAYUSCULAS_SNAKE` (`BI_S_VT_POR_SECTOR`)  
- Todos terminarán en `_S` o no tienen sufijo (no hay `_I`, `_U`, `_D` en `bi`)

En C# todos se traducen a `PascalCase`: `BiVtPorSectorQuery`, `AgrupacionAmbitoQuery`.
