# Patrón 12: Triggers en Cascada Sin Documentar

**Categoría**: Trazabilidad · Estabilidad · Riesgo de cambio  
**Síntoma principal**: Un UPDATE simple desencadena una cadena de efectos secundarios (emails, escrituras cross-BD, llamadas externas) que nadie conoce ni documenta.

## El Problema

Los triggers ejecutan lógica oculta al llamador. Cuando los triggers disparan otros triggers o llaman sistemas externos, el resultado de una operación simple se vuelve impredecible y cualquier fallo en la cadena hace rollback de todo.

```sql
-- Aparentemente inocente:
UPDATE Orders SET Status = 'Shipped' WHERE OrderID = 12345

-- Lo que realmente ocurre (sin documentación en ningún sitio):
-- 1. trigger_Orders_AfterUpdate dispara
--      → INSERT en OrderHistory
--      → 2. trigger_OrderHistory_AfterInsert dispara
--              → EXEC sp_send_dbmail (envía email al cliente)
--              → INSERT en EmailLog
--              → 3. trigger_EmailLog_AfterInsert dispara
--                      → UPDATE en tabla de métricas de otra BD
--                      → si falla (BD no disponible, timeout): ROLLBACK de TODO
--
-- Resultado: el UPDATE de estado falla porque una BD de métricas está caída
-- El DBA tarda 2 horas en entender por qué un UPDATE de 1 fila hace rollback

-- Detectar si nested triggers está habilitado:
SELECT value_in_use FROM sys.configurations WHERE name = 'nested triggers'
-- Si = 1: los triggers pueden disparar otros triggers (hasta 32 niveles)
```

## Impacto

- Operaciones simples con efectos secundarios invisibles para el desarrollador
- Un fallo en cualquier trigger de la cadena hace rollback de toda la transacción original
- El diagnóstico de errores es muy difícil: el error viene de un trigger anidado, no de la operación visible
- Las pruebas de integración no cubren la cadena completa si nadie sabe que existe
- Las migraciones y modernizaciones rompen en producción porque el trigger no se considera

## Señales de Detección

```sql
-- Inventario de todos los triggers con su tabla y tipo
SELECT 
    t.name AS trigger_name,
    o.name AS tabla,
    t.type_desc,
    t.is_disabled,
    t.is_instead_of_trigger
FROM sys.triggers t
JOIN sys.objects o ON t.parent_id = o.object_id
WHERE t.parent_class = 1  -- triggers de tabla (no de BD)
ORDER BY o.name, t.name

-- Triggers que llaman sistemas externos o otras BDs
SELECT t.name AS trigger_name, o.name AS tabla, m.definition
FROM sys.triggers t
JOIN sys.objects o ON t.parent_id = o.object_id
JOIN sys.sql_modules m ON t.object_id = m.object_id
WHERE m.definition LIKE '%sp_send_dbmail%'
   OR m.definition LIKE '%OPENROWSET%'
   OR m.definition LIKE '%linked server%'
   OR m.definition LIKE '%xp_cmdshell%'
   OR m.definition LIKE '%EXEC [^s]%'  -- llamadas a SPs externos
```

## Cuándo los Triggers SÍ son Aceptables

- Auditoría simple de cambios en tablas críticas (INSERT/UPDATE/DELETE → tabla de historial)
- Mantenimiento de columnas calculadas que no pueden ser columnas computadas
- Como alternativa: **Temporal Tables** (SQL Server 2016+) para historial sin triggers

## Estrategia de Modernización

1. Genera inventario completo de triggers con la query anterior
2. Para cada trigger: documenta qué hace, qué dispara, qué sistemas externos llama
3. Identifica cadenas (trigger A → inserta en B → trigger B dispara)
4. Extrae lógica de negocio de triggers a capa de aplicación con contratos explícitos
5. Para auditoría: migra a **Temporal Tables** o tabla de historial gestionada por la aplicación
6. Deshabilita triggers con `DISABLE TRIGGER` antes de eliminar para periodo de validación

## Agentes Relacionados

- **DB Dependency Analyzer** → Mapea las cadenas completas de triggers
- **Legacy Logic Extractor** → Documenta la lógica de negocio embebida en cada trigger
- **Change Impact Assessor** → Evalúa qué se rompe si se modifica una tabla con triggers
