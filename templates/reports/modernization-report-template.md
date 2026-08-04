---
name: 'Informe de Modernización de Base de Datos'
---

# Informe de Modernización de Base de Datos

**Sistema:** ___  **Módulo/Scope:** ___  **Fecha:** ___

## Resumen Ejecutivo
- SPs analizados: ___ | Candidatos a modernizar: ___
- Reglas de negocio extraídas: ___
- Quick wins identificados (código muerto / duplicados): ___
- Estimación de esfuerzo total: ___ sprints

## Inventario de Objetos

| Objeto | Tipo | Criticidad | Dependencias | Estado |
|--------|------|-----------|-------------|--------|
| ___ | SP / View / Function | CRÍTICO / IMPORTANTE / HUÉRFANO | ___ | Modernizar / Conservar / Eliminar |

## Reglas de Negocio Extraídas

| SP origen | Regla | Tipo | Candidato a extraer a |
|-----------|-------|------|----------------------|
| ___ | ___ | Cálculo / Validación / Flujo | Servicio / API / Dominio |

## Plan de Modernización

### Fase 1 — Quick Wins (semanas 1-2)
- [ ] Eliminar código muerto: ___ SPs identificados
- [ ] Consolidar lógica duplicada en: ___ SPs

### Fase 2 — Extracción de Negocio (semanas 3-8)
- [ ] Extraer reglas de: ___ SPs críticos
- [ ] Definir contratos de API/servicio

### Fase 3 — Migración (semanas 9+)
- [ ] Migrar a nueva arquitectura con feature flags
- [ ] Pruebas de paridad funcional
- [ ] Cutover controlado con rollback

## Criterios de Éxito
- [ ] 0 regresiones funcionales detectadas
- [ ] Cobertura de pruebas ≥ ___%
- [ ] Tiempo de respuesta igual o mejor que baseline
