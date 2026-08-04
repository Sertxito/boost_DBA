# Patrón 1: Lógica de Negocio Dispersa

**Categoría**: Mantenibilidad · Riesgo de cambio  
**Síntoma principal**: La misma regla de negocio implementada en múltiples sitios, ligeramente diferente cada vez.

## El Problema

Las reglas de negocio se implementan directamente en múltiples stored procedures en lugar de consolidarse.

```sql
-- Regla: "Clientes con crédito > 50K reciben descuento del 5%"
-- Implementada en 3 lugares diferentes, ligeramente diferente cada vez

-- Ubicación 1: sp_CalculateOrderTotal
IF (SELECT CreditLimit FROM Customers WHERE ID = @CustID) > 50000
    SET @Total = @Total * 0.95

-- Ubicación 2: sp_ApplyDiscount  
IF (SELECT CreditLimit FROM Customers WHERE ID = @CustID) >= 50000
    SET @Total = @Total * 0.95

-- Ubicación 3: sp_BatchProcessing
IF (SELECT CreditLimit FROM Customers WHERE ID = @CustID) > 50000
    SET @Total = @Total * 0.95
    -- Pero este también agrega un 2% extra ¿por qué razón???
    SET @Total = @Total * 0.98
```

## Impacto

- Los cambios de regla requieren actualizaciones en múltiples lugares
- Comportamiento inconsistente entre procedimientos (> vs >=, lógica adicional)
- Imposible saber cuál implementación refleja la regla real
- Los bugs se introducen silenciosamente en una sola ubicación sin que las demás se actualicen

## Señales de Detección

```sql
-- Buscar lógica similar replicada en múltiples SPs
SELECT o.name, m.definition
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE m.definition LIKE '%CreditLimit%'
  AND o.type = 'P'
ORDER BY o.name
-- Si más de 1 SP aparece con la misma columna de negocio: revisar divergencia
```

## Estrategia de Modernización

1. Consolida en tabla de configuración: `DiscountRules(RuleId, MinCreditLimit, DiscountPercent, ValidFrom, ValidTo)`
2. Crea único procedimiento canónico: `sp_CalculateDiscount(@CustomerID, @Total)`
3. Actualiza todos los llamadores para delegar a ese procedimiento
4. Migra gradualmente la lógica a capa de aplicación con tests de regresión

## Agentes Relacionados

- **Legacy Logic Extractor** → Extrae y documenta la regla de negocio real de cada variante
- **Change Impact Assessor** → Evalúa impacto de consolidar las variantes
- **DB Dependency Analyzer** → Identifica todos los SPs que implementan la regla
