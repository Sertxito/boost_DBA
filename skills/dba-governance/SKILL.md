---
name: 'Gobierno DBA: Seguridad y Fiabilidad'
description: 'Skill para revisar hardening, permisos, backup/restore y continuidad operativa'
---

# Gobierno DBA: Seguridad y Fiabilidad

## Proposito
Evaluar madurez operativa de SQL Server en seguridad, continuidad y cumplimiento tecnico minimo.

## Entradas
- Instancia o base de datos objetivo
- Politicas internas (si existen)
- Objetivos RPO/RTO

## Salidas
- Hallazgos de riesgo priorizados
- Plan de remediacion
- Checklist de continuidad
- Evidencia de auditoria tecnica

## Pasos

### 1. Backups y recuperacion
- Verifica backups full/diff/log
- Valida restauracion de prueba
- Contrasta con RPO/RTO objetivo

### 2. Permisos y cuentas privilegiadas
- Revisa cuentas con privilegios altos
- Detecta grants excesivos o no justificados
- Propone modelo de minimo privilegio

### 3. Configuracion y hardening
- Revisa configuraciones de superficie de ataque
- Verifica politicas de acceso y cifrado
- Identifica configuraciones de alto riesgo

### 4. Plan de remediacion
- Prioriza por criticidad y esfuerzo
- Define responsables y ventana de cambio

### 5. Seguimiento
- Define indicadores de riesgo residual
- Programa re-auditoria periodica

## Checklist de Calidad
- [ ] Riesgos criticos identificados
- [ ] Plan accionable por prioridad
- [ ] Evidencia de verificacion documentada
- [ ] Riesgo residual estimado
