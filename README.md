# boostDBA

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub Repo](https://img.shields.io/badge/repo-boostDBA-blue)](https://github.com/Sertxito/boostDBA)

> Boost DBA 360 — Sistema Agentico para SQL Server: Análisis, Diagnóstico, Optimización & Modernización

## Overview

Sistema agentico completo para operar, auditar y modernizar SQL Server **sin exfiltración de datos sensibles**. 18 agentes especializados + 19 skills para DBA operations, performance troubleshooting, security audits, y planificación de modernización.

### Key Features

- ✅ **18 Agentes Especializados** — Index Expert, Query Analyzer, Security Auditor, Modernization Planner
- ✅ **19 Skills Alineados** — Cada skill mapea a un dominio específico de SQL
- ✅ **Modes Lean & Full** — Lean (orquestador + analizador + reportes); Full (auditorías amplias)
- ✅ **Anonimización Obligatoria** — Wizard con ask/yes/no para proteger datos sensibles
- ✅ **Detección de Deuda Técnica** — Dependencias ocultas, índices no usados, queries lentas
- ✅ **Análisis de Riesgo** — Predice riesgos antes de cambios
- ✅ **Base de Conocimiento** — Respuestas fundamentadas contra almacén alineado

## Quick Start

### Prerequisites

- SQL Server 2019+
- .NET 8 runtime
- GitHub Copilot customizations enabled

### Installation

```bash
git clone https://github.com/Sertxito/boostDBA.git
cd boostDBA
# See INSTALL.md for full setup
```

### Usage (Lean Mode — Recommended)

```bash
# 1. Load orquestador agent
# 2. Connect to SQL Server
# 3. Run audit
# 4. Review reports
```

## Documentation

- [Boost DBA 360 Guide](docs/README.md)
- [Agent Behavioral Spec](specs/agent-behavioral-spec.md)
- [Session Framing Guide](specs/session-framing-guide.md)
- [Skills Catalog](skills/)
- [Agents Catalog](agents/)

## License

MIT — See [LICENSE](LICENSE)

