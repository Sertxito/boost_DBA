---
name: 'Generación de Datos de Prueba Seguros'
description: 'Skill para generar datos sintéticos realistas y anonimizar subconjuntos de producción para testing'
---

# Generación de Datos de Prueba Seguros

## Propósito
Crear datos de prueba que respeten constraints, relaciones y distribuciones reales sin exponer información sensible de producción.

## Entradas
- Schema de base de datos objetivo
- Volumen deseado (número de filas por tabla)
- Columnas o tablas con datos sensibles a anonimizar
- Escenarios de prueba específicos (opcional)

## Salidas
- Script de generación de datos sintéticos
- Script de anonimización para subconjuntos de producción
- Informe de cobertura de constraints y relaciones
- Nota de seguridad confirmando ausencia de datos reales

## Pasos

### 1. Inventario de constraints y relaciones
```sql
SELECT
    fk.name AS clave_foranea,
    OBJECT_NAME(fk.parent_object_id) AS tabla_hijo,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS columna_hijo,
    OBJECT_NAME(fk.referenced_object_id) AS tabla_padre,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS columna_padre
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
ORDER BY tabla_padre, tabla_hijo;
```

### 2. Identificación de columnas sensibles
- Detecta columnas con nombres que sugieren datos personales (email, nombre, DNI, teléfono, dirección)
- Marca columnas para anonimización obligatoria

### 3. Estrategias de anonimización por tipo
| Tipo | Estrategia |
|------|-----------|
| Email | usuario_[ID]@prueba.test |
| Nombre | Nombre_[hash corto] |
| Teléfono | 000-000-[4 dígitos aleatorios] |
| NIF/DNI | 00000000X |
| Dirección | Calle Prueba [número] |
| Fechas | Desplazar ±N días aleatorio |
| Importes | Multiplicar por factor aleatorio [0.8-1.2] |

### 4. Validación de integridad
- Verifica FK integrity después de generación
- Confirma que ningún dato generado coincide con producción
- Ejecuta preflight de seguridad sobre el dataset generado

## Checklist de Calidad
- [ ] Todas las FK respetadas en el orden de inserción
- [ ] Columnas sensibles anonimizadas sin excepción
- [ ] Dataset validado: sin datos reales identificables
- [ ] Script idempotente (truncate + insert)
- [ ] Preflight de seguridad ejecutado sobre salida
