# Patrón 8: Cursores en Lugar de Operaciones Set-Based

**Categoría**: Rendimiento · Escalabilidad  
**Síntoma principal**: Procesamiento fila a fila con cursores donde una sola operación de conjunto resolvería lo mismo 10x-100x más rápido.

## El Problema

SQL es un lenguaje orientado a conjuntos. Los cursores procesan fila a fila, generando un roundtrip al motor por cada registro y bloqueando recursos durante todo el proceso.

```sql
-- MAL: Cursor que actualiza precios fila por fila
DECLARE @ProductID INT, @Price DECIMAL
DECLARE cur CURSOR FOR
    SELECT ProductID, Price FROM Products WHERE CategoryID = 5
OPEN cur
FETCH NEXT FROM cur INTO @ProductID, @Price
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE Products SET Price = @Price * 1.10 WHERE ProductID = @ProductID
    -- En 500K filas: 500K UPDATEs individuales, 500K bloqueos de fila, 500K log entries
    FETCH NEXT FROM cur INTO @ProductID, @Price
END
CLOSE cur
DEALLOCATE cur

-- BIEN: Una sola operación set-based
UPDATE Products
SET Price = Price * 1.10
WHERE CategoryID = 5
-- Un solo plan de ejecución, un solo scan, un log entry por lote
```

## Impacto

- Rendimiento 10x-100x inferior según el volumen de datos
- CPU sostenida alta durante toda la ejecución del cursor
- Bloqueos de fila de larga duración que impactan otras sesiones
- El tiempo de ejecución escala linealmente con el número de filas (fatal en tablas grandes)
- Los problemas se ocultan en entornos de desarrollo con datos pequeños

## Señales de Detección

```sql
-- SPs con cursores declarados
SELECT o.name, m.definition
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.type = 'P'
  AND m.definition LIKE '%DECLARE%CURSOR%'
ORDER BY o.name

-- Sesiones con cursores abiertos actualmente
SELECT c.session_id, c.name AS cursor_name, c.fetch_status,
       s.login_name, s.last_request_start_time
FROM sys.dm_exec_cursors(0) c
JOIN sys.dm_exec_sessions s ON c.session_id = s.session_id
WHERE c.is_open = 1
```

## Cuándo los Cursores SÍ son Aceptables

- Operaciones que genuinamente son fila a fila por naturaleza (generación de documentos individuales, llamadas a APIs externas por registro)
- Conjuntos muy pequeños (< 1000 filas) donde el rendimiento no importa
- Operaciones de mantenimiento de DBA puntales (no en camino de producción)

## Estrategia de Modernización

1. Inventaría cursores con `sys.sql_modules LIKE '%DECLARE%CURSOR%'`
2. Para cada cursor: analiza si la lógica puede vectorizarse (la mayoría sí)
3. Reemplaza UPDATE/INSERT/DELETE dentro del cursor por operación con JOIN o subquery
4. Para lógica compleja fila a fila: evalúa `CROSS APPLY`, funciones de ventana o CTEs recursivas
5. Mide antes/después: `SET STATISTICS TIME, IO ON` antes de la query

## Agentes Relacionados

- **Performance Bottleneck Analyzer** → Detecta cursores como fuente de CPU alta
- **Query Optimizer** → Propone la versión set-based equivalente con benchmark
