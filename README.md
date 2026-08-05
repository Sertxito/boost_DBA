# boostDBA

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub Repo](https://img.shields.io/badge/repo-boostDBA-blue)](https://github.com/Sertxito/boostDBA)

Boost DBA 360 es un paquete de conocimiento operativo para SQL Server: agentes, skills, patrones y plantillas para analizar, estabilizar y modernizar bases de datos heredadas sin exfiltrar datos sensibles.

> Esta README se usa tanto en GitHub como en npm.

## Historia del proyecto

Boost DBA 360 nace de un problema repetido en equipos de datos: bases SQL Server con 10-15 anos de deuda tecnica, sin documentacion confiable y con alto riesgo en cada cambio.

Evolucion resumida:

1. Inicio como playbook interno para auditorias DBA y analisis de riesgo en cambios.
2. Estandarizacion de patrones recurrentes (dependencias ocultas, parameter sniffing, cursores, transacciones sin cierre).
3. Conversion a sistema agentico con modos Lean y Full para reducir coste operativo diario.
4. Endurecimiento de seguridad con flujo de anonimización desde onboarding para evitar fuga de datos en artefactos.
5. Publicacion como paquete reusable (mcpee-dba) para facilitar adopcion en otros workspaces.

## Que incluye

- 18 agentes especializados para analisis de dependencias, rendimiento, seguridad, mantenimiento, HA y modernizacion.
- 19 skills reutilizables para tareas tecnicas concretas.
- Patrones y templates listos para reportes, planes y migracion.
- Scripts PowerShell para onboarding, preflight, diagnostico y export.

## Instalacion real

Hay dos formas de usarlo, segun tu caso.

### Opcion A: consumo desde npm (reutilizar el paquete)

Recomendado cuando ya tienes tu entorno y solo quieres incorporar el catalogo DBA.

```bash
npm install --save-dev mcpee-dba
```

Verificacion minima:

```bash
node -e "const fs=require('fs'); const p='node_modules/mcpee-dba/mcpee.json'; console.log(fs.existsSync(p)?'OK: mcpee.json encontrado':'ERROR: paquete no instalado');"
```

### Opcion B: uso desde GitHub (operar y contribuir)

Recomendado si vas a ejecutar scripts del repo, personalizar agentes/skills o contribuir.

```bash
git clone https://github.com/Sertxito/boostDBA.git
cd boostDBA
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
- [Patrones de deuda tecnica](patterns/README.md)

## Licencia

MIT. Ver [LICENSE](LICENSE).
