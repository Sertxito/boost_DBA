# Patrón 4: Valores Hardcoded en Procedimientos

**Categoría**: Mantenibilidad · Flexibilidad  
**Síntoma principal**: Constantes de negocio embebidas en código SQL que requieren despliegues para cambiar.

## El Problema

Las constantes de negocio (tasas, umbrales, fechas de corte) se embeben directamente en el cuerpo de los procedimientos en lugar de vivir en configuración.

```sql
CREATE PROCEDURE sp_CalculateOrderTotal
AS
BEGIN
    -- Tasa de impuesto hardcoded: ¿qué pasa si la empresa expande a otro país?
    DECLARE @TaxRate DECIMAL(5,4) = 0.21
    
    -- Umbral hardcoded: ¿qué pasa si el negocio cambia la política?
    IF @OrderTotal > 10000
    BEGIN
        -- lógica de manejo especial para órdenes grandes
    END
    
    -- Corte de mes hardcoded: ¿y si cambia el calendario fiscal?
    IF DAY(GETDATE()) >= 25
    BEGIN
        -- lógica de fin de mes
    END
END
```

## Impacto

- Un cambio de configuración requiere modificación de código + ciclo de pruebas + despliegue
- Imposible hacer A/B testing de reglas de negocio
- Diferentes unidades de negocio no pueden coexistir con reglas distintas
- Los valores se dispersan: el mismo umbral puede estar hardcoded de formas distintas en diferentes SPs

## Señales de Detección

```sql
-- Buscar literales numéricos y de fecha en definiciones de SPs
SELECT o.name, m.definition
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.type = 'P'
  AND (
    m.definition LIKE '%= 0.2[0-9]%'    -- posibles tasas
    OR m.definition LIKE '%> [0-9]0000%' -- posibles umbrales monetarios
    OR m.definition LIKE '%DAY(GETDATE()) >=%' -- cortes de fecha hardcoded
  )
```

## Estrategia de Modernización

1. Crea tabla de configuración: `Config(ConfigKey VARCHAR(100), ConfigValue NVARCHAR(500), ValidFrom DATE, ValidTo DATE, BusinessUnit VARCHAR(50))`
2. Extrae todos los valores hardcoded identificados a esa tabla
3. Reemplaza literales por `SELECT @Value = ConfigValue FROM Config WHERE ConfigKey = 'TaxRate' AND ValidFrom <= GETDATE() AND (ValidTo IS NULL OR ValidTo >= GETDATE())`
4. Cachea en capa de aplicación para valores de alta frecuencia
5. A largo plazo: migra a sistema de feature flags con soporte multi-tenant

## Agentes Relacionados

- **Legacy Logic Extractor** → Inventaría todos los literales con significado de negocio
- **Modernization Orchestrator** → Planifica la migración a configuración por fases
