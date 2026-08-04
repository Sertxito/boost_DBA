# Patrón 9: Transacciones Abiertas Sin Cierre Explícito

**Categoría**: Estabilidad · Fiabilidad · Bloqueos  
**Síntoma principal**: Transacciones que se abren pero no cierran en todos los caminos de error. Los bloqueos se acumulan hasta parar el sistema.

## El Problema

Sin `TRY/CATCH` completo, cualquier error entre `BEGIN TRANSACTION` y `COMMIT` deja la transacción abierta. Los bloqueos no se liberan. Otras sesiones esperan indefinidamente.

```sql
CREATE PROCEDURE sp_TransferStock
    @FromWarehouse INT, @ToWarehouse INT, @ProductID INT, @Qty INT
AS
BEGIN
    BEGIN TRANSACTION
    
    UPDATE Stock SET Quantity = Quantity - @Qty 
    WHERE WarehouseID = @FromWarehouse AND ProductID = @ProductID
    
    -- Si aquí ocurre: error de red, timeout, RAISERROR, deadlock...
    -- La transacción queda abierta. El bloqueo sobre la fila no se libera.
    -- Otras sesiones que necesiten esa fila esperan indefinidamente.
    -- En producción: el sistema se degrada progresivamente sin causa aparente.
    
    UPDATE Stock SET Quantity = Quantity + @Qty 
    WHERE WarehouseID = @ToWarehouse AND ProductID = @ProductID
    
    COMMIT TRANSACTION
    -- Si el segundo UPDATE falla: primer UPDATE ya escribió, COMMIT nunca llega
END

-- Patrón correcto
CREATE PROCEDURE sp_TransferStock_Safe
    @FromWarehouse INT, @ToWarehouse INT, @ProductID INT, @Qty INT
AS
BEGIN
    SET XACT_ABORT ON  -- rollback automático ante cualquier error
    BEGIN TRY
        BEGIN TRANSACTION
        
        UPDATE Stock SET Quantity = Quantity - @Qty 
        WHERE WarehouseID = @FromWarehouse AND ProductID = @ProductID
        
        UPDATE Stock SET Quantity = Quantity + @Qty 
        WHERE WarehouseID = @ToWarehouse AND ProductID = @ProductID
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW  -- propaga el error al llamador
    END CATCH
END
```

## Impacto

- Bloqueos acumulativos: cada transacción huérfana bloquea filas que otras sesiones necesitan
- Degradación progresiva del sistema hasta parada completa
- Difícil de diagnosticar: el síntoma (timeout de otras queries) no apunta a la causa (transacción abierta)
- En producción: incidente P1 sin causa raíz evidente hasta revisar DMVs

## Señales de Detección

```sql
-- Transacciones abiertas de larga duración (> 5 minutos)
SELECT 
    s.session_id,
    s.login_name,
    s.open_transaction_count,
    s.last_request_start_time,
    DATEDIFF(MINUTE, s.last_request_start_time, GETDATE()) AS minutos_abierta,
    t.text AS ultima_query
FROM sys.dm_exec_sessions s
CROSS APPLY sys.dm_exec_sql_text(s.most_recent_sql_handle) t
WHERE s.open_transaction_count > 0
  AND s.last_request_start_time < DATEADD(MINUTE, -5, GETDATE())
ORDER BY minutos_abierta DESC

-- SPs con BEGIN TRANSACTION pero sin TRY/CATCH
SELECT o.name
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.type = 'P'
  AND m.definition LIKE '%BEGIN TRANSACTION%'
  AND m.definition NOT LIKE '%BEGIN TRY%'
```

## Estrategia de Modernización

1. Audita todos los SPs con `BEGIN TRANSACTION` sin `BEGIN TRY` correspondiente
2. Implementa patrón estándar en todos: `SET XACT_ABORT ON` + `BEGIN TRY/CATCH` con `ROLLBACK` en el CATCH
3. Configura alerta sobre transacciones abiertas > N minutos usando `sys.dm_exec_sessions`
4. Añade `SET XACT_ABORT ON` como primera línea de todos los SPs críticos (red de seguridad adicional)

## Agentes Relacionados

- **Performance Bottleneck Analyzer** → Detecta bloqueos activos y sus causas raíz
- **DBA Reliability & Security Advisor** → Evalúa el riesgo de transacciones sin control de errores
- **Migration Script Generator** → Genera versiones corregidas de SPs con patrón TRY/CATCH completo
