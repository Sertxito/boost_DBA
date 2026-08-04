# Patrón 5: Procedimientos Complejos que Hacen Demasiado

**Categoría**: Mantenibilidad · Testabilidad · Rendimiento  
**Síntoma principal**: Un solo SP de 300-1000 líneas que valida, transforma, actualiza, llama sistemas externos, genera reportes y envía notificaciones.

## El Problema

Un procedimiento orquesta un proceso de negocio complejo sin separación de responsabilidades. Si un paso falla, el estado resultante es ambiguo.

```sql
-- sp_ProcessMonthlyClosing: 500 líneas que hacen todo
CREATE PROCEDURE sp_ProcessMonthlyClosing
    @CompanyID INT, @Month INT, @Year INT
AS
BEGIN
    -- Validación de entrada (sin TRY/CATCH propio)
    -- Transformación de datos (acoplada a la validación)
    -- UPDATE de 6 tablas diferentes
    -- EXEC sp_ExternalSystem (puede hacer timeout)
    -- Generación de 3 reportes
    -- sp_send_dbmail (puede fallar silenciosamente)
    -- Logging dispersado entre los 500 pasos anteriores
    -- Sin transacciones claras: si falla en el paso 400, ¿qué quedó escrito?
END
```

## Impacto

- Imposible probar pasos individuales en aislamiento
- Un fallo en cualquier punto deja el sistema en estado incierto
- Los cuellos de botella de rendimiento no se pueden aislar
- Tarda horas entender qué hace el procedimiento
- Cualquier cambio tiene riesgo de romper pasos no relacionados

## Señales de Detección

```sql
-- SPs con más de X líneas de código
SELECT 
    o.name,
    LEN(m.definition) AS chars,
    (LEN(m.definition) - LEN(REPLACE(m.definition, CHAR(10), ''))) AS lineas_aprox
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.type = 'P'
  AND (LEN(m.definition) - LEN(REPLACE(m.definition, CHAR(10), ''))) > 200
ORDER BY lineas_aprox DESC

-- SPs que llaman sistemas externos (dbmail, linked servers, xp_cmdshell)
SELECT o.name FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.type = 'P'
  AND (m.definition LIKE '%sp_send_dbmail%'
    OR m.definition LIKE '%OPENROWSET%'
    OR m.definition LIKE '%xp_cmdshell%')
```

## Estrategia de Modernización

1. Descompone en procedimientos con responsabilidad única: validar, transformar, persistir, notificar
2. Cada paso debe ser invocable independientemente y tener su propio TRY/CATCH
3. Implementa patrón saga para coordinar pasos con compensación ante fallos
4. Mueve orquestación de pasos a capa de aplicación
5. Extrae notificaciones (email, eventos) a sistemas asíncronos desacoplados

## Agentes Relacionados

- **Legacy Logic Extractor** → Documenta qué hace cada bloque lógico del SP
- **Change Impact Assessor** → Evalúa riesgo de la descomposición
- **Modernization Orchestrator** → Planifica el refactor por fases seguras
