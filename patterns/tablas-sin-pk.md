# Patrón 11: Tablas Sin Clave Primaria o Con Identidad Mal Definida

**Categoría**: Integridad · Rendimiento · Alta Disponibilidad  
**Síntoma principal**: Tablas heap sin PK que hacen full scan en cada acceso. PKs compuestas con lógica de negocio que puede generar duplicados. Impacto directo en replicación y AlwaysOn.

## El Problema

Una tabla sin clave primaria (heap) no tiene orden lógico ni row locator eficiente. Cada lectura es un full scan. Además, AlwaysOn y la replicación transaccional requieren PK o unique index para identificar filas inequívocamente.

```sql
-- Tabla heap: sin PK, sin índice clustered, sin orden
CREATE TABLE EventLog (
    EventDate DATETIME,
    UserID    INT,
    Action    VARCHAR(100),
    Details   NVARCHAR(MAX)
    -- Full scan en cada SELECT
    -- DELETE WHERE EventDate < '2023-01-01': table lock completo
    -- AlwaysOn: degradado, usa full table scan para replicar cambios
    -- Imposible identificar una fila específica para auditoría
)

-- PK compuesta con lógica de negocio que puede romperse
CREATE TABLE OrderLines (
    OrderID     INT,
    ProductCode VARCHAR(20),  -- ¿el código puede cambiar? ¿puede haber variantes?
    Quantity    INT,
    PRIMARY KEY (OrderID, ProductCode)
    -- Si ProductCode se reutiliza o tiene variantes: duplicados imposibles de prevenir
    -- Si el código cambia: UPDATE en cascada de todas las FK
)

-- PK técnica correcta: surrogate key independiente de la lógica de negocio
CREATE TABLE OrderLines (
    OrderLineID INT IDENTITY(1,1) PRIMARY KEY,  -- inmutable, predecible, eficiente
    OrderID     INT NOT NULL,
    ProductCode VARCHAR(20) NOT NULL,
    Quantity    INT NOT NULL,
    UNIQUE (OrderID, ProductCode)  -- restricción de negocio separada de la PK
)
```

## Impacto

- **Rendimiento**: Heaps hacen full scan en cada lectura; sin row locator, los updates también son más costosos
- **Bloqueos**: Sin índice clustered, los DELETE/UPDATE de muchas filas generan table locks
- **Alta Disponibilidad**: AlwaysOn y replicación transaccional requieren PK o unique index; sin ellos funcionan en modo degradado
- **Integridad**: Sin PK, no hay garantía de unicidad; los duplicados son posibles y silenciosos
- **Auditoría y rollback**: Imposible referenciar una fila específica sin identificador único

## Señales de Detección

```sql
-- Tablas sin ninguna clave primaria
SELECT t.name AS tabla, SUM(p.rows) AS filas_aprox
FROM sys.tables t
LEFT JOIN sys.key_constraints k 
    ON t.object_id = k.parent_object_id AND k.type = 'PK'
JOIN sys.partitions p 
    ON t.object_id = p.object_id AND p.index_id IN (0, 1)
WHERE k.object_id IS NULL
  AND t.is_ms_shipped = 0
GROUP BY t.name
ORDER BY filas_aprox DESC

-- Tablas heap (sin índice clustered) con muchas filas
SELECT t.name, SUM(p.rows) AS filas
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id = 0  -- 0 = heap
WHERE t.is_ms_shipped = 0
GROUP BY t.name
HAVING SUM(p.rows) > 50000
ORDER BY filas DESC
```

## Estrategia de Modernización

1. Prioriza tablas grandes sin PK que participen en replicación o AlwaysOn
2. Añade columna surrogate: `ALTER TABLE EventLog ADD EventLogID INT IDENTITY(1,1)`
3. Crea PK sobre esa columna: `ALTER TABLE EventLog ADD CONSTRAINT PK_EventLog PRIMARY KEY (EventLogID)`
4. Para tablas ya en replicación: coordina con la configuración del publicador antes de modificar esquema
5. Valida PKs existentes de negocio: `SELECT COUNT(*), COUNT(DISTINCT CONCAT(OrderID,'-',ProductCode)) FROM OrderLines` — si difieren, hay duplicados

## Agentes Relacionados

- **High Availability Advisor** → Evalúa impacto en AlwaysOn y replicación
- **DBA Reliability & Security Advisor** → Incluye tablas sin PK en auditoría de integridad
- **Migration Script Generator** → Genera el DDL de adición de PK con rollback y validaciones previas
