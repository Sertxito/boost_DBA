# Anti-Patrones de Base de Datos Heredada

Índice de patrones detectados con frecuencia en bases de datos SQL Server heredadas. Cada patrón tiene su propio archivo con problema, impacto, queries de detección y estrategia de modernización.

## Mantenibilidad y Deuda Técnica

| Patrón | Síntoma clave |
|--------|--------------|
| [Lógica de negocio dispersa](logica-negocio-dispersa.md) | La misma regla implementada en 3 SPs, ligeramente diferente cada vez |
| [Código muerto que asusta a todos](codigo-muerto.md) | SPs sin ejecución en años que nadie se atreve a eliminar |
| [Valores hardcoded en procedimientos](valores-hardcoded.md) | Tasas, umbrales y fechas de corte embebidos en el cuerpo del SP |
| [Procedimientos que hacen demasiado](procedimientos-complejos.md) | Un SP de 500 líneas que valida, transforma, notifica y reporta |

## Trazabilidad y Dependencias

| Patrón | Síntoma clave |
|--------|--------------|
| [Dependencias implícitas entre SPs](dependencias-implicitas.md) | Cadenas de llamadas ocultas; un cambio rompe algo inesperado |
| [Sin pista de auditoría](sin-auditoria.md) | Nadie sabe quién cambió qué; el historial son tablas `*Backup_v2*` |
| [Triggers en cascada sin documentar](triggers-cascada.md) | Un UPDATE dispara emails, escrituras cross-BD y rollbacks invisibles |

## Rendimiento y Escalabilidad

| Patrón | Síntoma clave |
|--------|--------------|
| [Índices faltantes o desactualizados](indices-faltantes.md) | Full scans en tablas críticas; rendimiento empeora con el crecimiento |
| [Cursores en lugar de set-based](cursores-vs-set-based.md) | Procesamiento fila a fila donde un UPDATE/DELETE bastaría |
| [Parameter sniffing oculto](parameter-sniffing.md) | Funciona en dev, falla en prod; mismo SP: 200ms y 8min según el día |

## Estabilidad y Fiabilidad

| Patrón | Síntoma clave |
|--------|--------------|
| [Transacciones abiertas sin cierre](transacciones-sin-cierre.md) | Bloqueos acumulativos hasta parada; incidente P1 sin causa aparente |
| [Tablas sin clave primaria](tablas-sin-pk.md) | Heaps con full scan; AlwaysOn degradado; duplicados silenciosos |

## Seguridad

| Patrón | Síntoma clave |
|--------|--------------|
| [Dynamic SQL sin parametrizar](dynamic-sql-sin-parametrizar.md) | SQL Injection posible + plan cache contaminado (OWASP A03:2021) |

## Modernización y Migración a Aplicación

| Patrón | Síntoma clave |
|--------|--------------|
| [Strangler Fig — Migración SP a C#](strangler-fig-sp-migration.md) | Cómo extraer SPs a .NET de forma incremental sin big-bang ni parar producción |

---

## Cómo Usar Este Conocimiento

Los agentes de Boost DBA referencian estos patrones automáticamente al analizar una base de datos:

- **DB Dependency Analyzer** → detecta patrones 02, 12
- **Legacy Logic Extractor** → detecta patrones 01, 04, 05
- **Performance Bottleneck Analyzer** → detecta patrones 06, 08, 09, 10
- **DBA Reliability & Security Advisor** → detecta patrones 07, 11, 13
- **Proactive Maintenance Advisor** → detecta patrones 06, 08
- **Change Impact Assessor** → evalúa riesgo de corrección de cualquier patrón
- **Modernization Orchestrator** → aplica Strangler Fig para migración a C#/.NET
