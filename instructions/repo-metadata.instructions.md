---
description: "Guia para metadatos raiz del paquete y documentos de gobierno del repo."
applyTo: "{README.md,CHANGELOG.md,CONTRIBUTING.md,package.json,mcpee.json,platform.json,.releaserc.json,.markdownlint.json}"
---

# Repository Metadata Guardrails

- Mantener consistencia entre README, package metadata y catalogos reales.
- Evitar breaking changes silenciosos en nombres, rutas o exportaciones.
- Versionar cambios relevantes en CHANGELOG cuando aplique.
- No introducir dependencias o scripts sin justificar impacto operativo.
- Preservar compatibilidad con Node 20+ y flujo de publicacion existente.
- Verificar que archivos publicados en npm reflejan la estructura necesaria.
