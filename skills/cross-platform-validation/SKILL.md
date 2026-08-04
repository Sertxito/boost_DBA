---
name: 'Validación Cross-Platform y Referencias Oficiales'
description: 'Skill para contrastar recomendaciones con documentación oficial y mapear equivalencias entre plataformas de base de datos'
---

# Validación Cross-Platform y Referencias Oficiales

## Propósito
Garantizar que cada recomendación emitida por Boost DBA está respaldada por documentación oficial y es válida para la plataforma y versión específica del cliente.

## Fuente de Verdad
[references/official-docs.md](../../references/official-docs.md)

## Entradas
- Recomendación a validar
- Plataforma objetivo (SQL Server / Azure SQL / PostgreSQL / AWS RDS / Cosmos DB)
- Versión o tier específico (si se conoce)

## Salidas
- Recomendación validada con cita de fuente oficial
- Nota de compatibilidad por versión/tier
- Equivalencias en otras plataformas (si aplica)
- Advertencias de comportamiento diferente entre plataformas

## Protocolo de Validación

### Paso 1: Identificar plataforma y versión
```
Plataforma: [SQL Server 2019 / Azure SQL Standard / PostgreSQL 15 / ...]
Versión mínima requerida: [...]
Disponible en tier: [Basic / Standard / Premium / ...]
```

### Paso 2: Contrastar con referencia oficial
- Buscar en [official-docs.md](../../references/official-docs.md) el enlace canónico
- Verificar que el comportamiento documentado coincide con la recomendación
- Anotar si hay cambios de comportamiento entre versiones

### Paso 3: Formato de recomendación validada
```
RECOMENDACIÓN: [descripción]
PLATAFORMA: [SQL Server / Azure SQL / ...]
VERSIÓN MÍNIMA: [2016 / Gen5 / PostgreSQL 12 / ...]
FUENTE OFICIAL: [URL]
APLICA EN TIER: [todos / Premium / ...]
NOTAS DE COMPATIBILIDAD: [diferencias cross-platform si las hay]
```

### Paso 4: Mapeo cross-platform (si aplica migración)
| Aspecto | Origen | Destino | Gap / Equivalencia |
|---------|--------|---------|-------------------|
| [feature] | [implementación origen] | [implementación destino] | [gap o equivalente] |

## Checklist de Calidad
- [ ] Fuente oficial citada con URL
- [ ] Versión mínima documentada
- [ ] Tier o edición especificada cuando aplica
- [ ] Comportamientos diferentes entre plataformas señalados explícitamente
- [ ] Sin extrapolaciones sin evidencia documental
