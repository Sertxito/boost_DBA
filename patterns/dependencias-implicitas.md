# Patrón 2: Dependencias Implícitas de Stored Procedures

**Categoría**: Riesgo de cambio · Trazabilidad  
**Síntoma principal**: Cadenas de llamadas entre procedimientos sin documentar. Nadie sabe qué dispara qué.

## El Problema

Los procedimientos llaman otros procedimientos sin documentación, creando cadenas de llamadas ocultas.

```sql
CREATE PROCEDURE sp_MonthlyClosing
AS
BEGIN
    -- Esto llama sp_UpdateMetrics, que llama sp_SendReports, 
    -- que llama sp_GenerateFiles, que podría llamar sistemas externos
    -- ¡Buena suerte encontrando todas las dependencias!
    EXEC sp_UpdateMetrics
    PRINT 'Done'
END

CREATE PROCEDURE sp_UpdateMetrics
AS
BEGIN
    EXEC sp_SendReports  -- dependencia oculta
END

CREATE PROCEDURE sp_SendReports
AS
BEGIN
    -- Llamada a sistema externo con posible timeout
    -- Nada lo documenta
END
```

## Impacto

- Cambiar un procedimiento puede causar fallos en cascada inesperados
- Imposible evaluar el impacto completo de cualquier modificación
- Los timeouts de sistemas externos se manifiestan como errores en procedimientos aparentemente no relacionados
- El análisis de causa raíz tarda horas o días

## Señales de Detección

```sql
-- Cadenas de llamadas entre SPs
SELECT 
    referencing.name AS llamador,
    referenced.name AS llamado
FROM sys.sql_expression_dependencies d
JOIN sys.objects referencing ON d.referencing_id = referencing.object_id
JOIN sys.objects referenced ON d.referenced_id = referenced.object_id
WHERE referencing.type = 'P' AND referenced.type = 'P'
ORDER BY referencing.name

-- Profundidad de la cadena: ejecutar recursivamente para mapear niveles
```

## Estrategia de Modernización

1. Genera matriz de dependencias completa con `sys.sql_expression_dependencies`
2. Documenta cada cadena con su propósito y efecto secundario
3. Extrae gradualmente a capa de aplicación con patrón orquestador
4. Reemplaza llamadas síncronas en cadena por arquitectura basada en mensajes para pasos independientes

## Agentes Relacionados

- **DB Dependency Analyzer** → Genera mapa completo de dependencias entre objetos
- **Change Impact Assessor** → Evalúa qué se rompe si se toca un nodo de la cadena
- **Legacy Logic Extractor** → Documenta el propósito de cada eslabón
