# boost_DBA

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub Repo](https://img.shields.io/badge/repo-boost_DBA-blue)](https://github.com/Sertxito/boost_DBA)

Boost DBA 360 es un paquete de conocimiento operativo para SQL Server: agentes, skills, patrones y plantillas para analizar, estabilizar y modernizar bases de datos heredadas sin exfiltrar datos sensibles.

> Esta README se usa tanto en GitHub como en npm.

## Historia del proyecto

Boost DBA 360 nace de un problema repetido en equipos de datos: bases SQL Server con 10-15 anos de deuda tecnica, sin documentacion confiable y con alto riesgo en cada cambio.

Evolucion resumida:

1. Inicio como playbook interno para auditorias DBA y analisis de riesgo en cambios.
2. Estandarizacion de patrones recurrentes (dependencias ocultas, parameter sniffing, cursores, transacciones sin cierre).
3. Conversion a sistema agentico con modos Lean y Full para reducir coste operativo diario.
4. Endurecimiento de seguridad con flujo de anonimización desde onboarding para evitar fuga de datos en artefactos.
5. Publicacion como paquete reusable (boost-dba) para facilitar adopcion en otros workspaces.

## Que incluye

- 18 agentes especializados para analisis de dependencias, rendimiento, seguridad, mantenimiento, HA y modernizacion.
- 19 skills reutilizables para tareas tecnicas concretas.
- Patrones y templates listos para reportes, planes y migracion.
- Scripts PowerShell para onboarding, preflight, diagnostico y export.
- Instrucciones auto-descubribles por Copilot (SQL, archivos DBA operativos y prompts/evals).

## Instalacion

Este boost es **autocontenido**: no necesita runtime, plugin ni servidor MCP. Un solo comando copia sus activos a las rutas donde GitHub Copilot / VS Code los descubren automaticamente.

```bash
# Desde la raiz de TU proyecto
npx github:Sertxito/boost_DBA
# o, una vez publicado en npm
npx boost-dba
```

| Activo | Se instala en |
|---|---|
| Agentes | `.github/agents/*.agent.md` |
| Skills | `.github/skills/<nombre>/SKILL.md` y `.agents/skills/<nombre>/SKILL.md` |
| Prompts | `.github/prompts/*.prompt.md` |
| Instrucciones | `.github/instructions/*.instructions.md` |
| Instrucciones globales | `.github/copilot-instructions.md` (solo si el proyecto no tiene) |

Opciones: `--target <dir>`, `--force` (sobrescribir), `--dry-run`, `--no-agents-dir` (omite `.agents/skills`), `--check` (verifica la instalacion), `--uninstall`.
Nunca se sobrescriben archivos existentes sin `--force`, asi que varios boosts conviven en el mismo proyecto.

**Verifica:** ejecuta `npx boost-dba --check`, recarga VS Code (`Developer: Reload Window`) y escribe `@` en Copilot Chat (agentes), `/` (prompts) y abre el selector de skills.

### Para contribuir

```bash
git clone https://github.com/Sertxito/boost_DBA.git
cd boost_DBA
npm install
npm run quality
```

Inicializa un workspace DBA 360 real:

```powershell
pwsh -File scripts/run-dba360-wizard.ps1 -ProjectName "MiProyecto" -SchemaPath "C:\ruta\schema" -Anonymize ask
```

Alternativa no interactiva para pipelines:

```powershell
pwsh -File scripts/run-dba360-wizard.ps1 -ProjectName "MiProyecto" -SchemaPath "C:\ruta\schema" -Anonymize yes
```

## Requisitos

- Node.js 20 o superior.
- PowerShell 7 o superior (para scripts en scripts/).
- SQL Server 2019 o superior si vas a ejecutar analisis contra workloads reales.

## Primer uso recomendado

1. Ejecuta el wizard de onboarding (crea workspaces/<Proyecto>/ y fuente de verdad).
2. Revisa el resultado del preflight de seguridad.
3. Comienza en modo Lean (orquestador + dependencias + reporte ejecutivo).
4. Activa agentes extra solo cuando haya trigger claro.

## Documentacion

- [Guia completa Boost DBA 360](docs/README.md)
- [Agent Behavioral Spec](specs/agent-behavioral-spec.md)
- [Session Framing Guide](specs/session-framing-guide.md)
- [Catalogo de agentes](agents/)
- [Catalogo de skills](skills/)
- [Catalogo de prompts](prompts/)
- [Catalogo de evaluaciones](evals/)
- [Patrones de deuda tecnica](patterns/README.md)

## Licencia

MIT. Ver [LICENSE](LICENSE).

## Naming and collisions

Installed assets are prefixed with `dba-` (e.g. `.github/agents/dba-<name>.agent.md`, `.github/skills/dba-<name>/`) so several boosts can live in the same project, and internal references are rewritten to match.

- Nothing that already exists in the target is overwritten: each ignored file is reported with a `[WARN] ... already existed ... IGNORED` message. Use `--force` to overwrite.
- An existing `.github/copilot-instructions.md` is kept; the boost's global guidance is installed as `dba-global.instructions.md` instead.
- Re-running the installer is safe; `--check` and `--uninstall` work from the manifest.

