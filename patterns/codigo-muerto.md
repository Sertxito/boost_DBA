# Patrón 3: Código Muerto que Asusta a Todos

**Categoría**: Deuda técnica · Mantenibilidad  
**Síntoma principal**: Procedimientos huérfanos que nadie usa pero nadie se atreve a eliminar.

## El Problema

Procedimientos que no se han ejecutado en años permanecen en producción porque nadie puede garantizar al 100% que no los llama nada.

```sql
-- No ejecutado desde 2019. El reporte que alimentaba fue retirado hace 5 años.
-- Pero si intentas removerlo, alguien dirá: "espera, creo que algo podría usar eso"
-- Así que se queda, generando ruido y deuda técnica

CREATE PROCEDURE sp_LegacyReportExtract
AS
BEGIN
    -- Código comentado que nunca se limpió
    /*
    SELECT * FROM Orders WHERE OrderDate > '2015-01-01'
    */
    
    -- Tabla que ya no existe pero el SP tampoco se eliminó
    SELECT * FROM ReportStaging_Old  -- esta tabla fue dropeada en 2021
END
```

## Impacto

- Los desarrolladores pierden tiempo analizando código que no se ejecuta
- La percepción de riesgo crece artificialmente, paralizando la modernización
- Dificulta el análisis de dependencias (¿es una dependencia real o muerta?)
- Acumula deuda técnica que nunca se salda

## Señales de Detección

```sql
-- SPs sin ejecución reciente (requiere Query Store habilitado)
SELECT o.name, MAX(rs.last_execution_time) AS ultima_ejecucion
FROM sys.objects o
LEFT JOIN sys.query_store_query q ON q.object_id = o.object_id
LEFT JOIN sys.query_store_plan p ON q.query_id = p.query_id
LEFT JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
WHERE o.type = 'P'
GROUP BY o.name
HAVING MAX(rs.last_execution_time) < DATEADD(YEAR, -1, GETDATE())
   OR MAX(rs.last_execution_time) IS NULL
ORDER BY ultima_ejecucion ASC

-- Alternativa: sys.dm_exec_procedure_stats (solo desde último reinicio)
SELECT OBJECT_NAME(object_id), last_execution_time, execution_count
FROM sys.dm_exec_procedure_stats
WHERE last_execution_time < DATEADD(YEAR, -1, GETDATE())
```

## Estrategia de Modernización

1. Mide ejecuciones reales con Query Store (ventana mínima de 90 días)
2. Busca referencias en código de aplicación (strings con el nombre del SP)
3. Marca como deprecated en comentario con fecha y responsable
4. Período de cuarentena: 1 trimestre de monitorización adicional
5. Elimina con confianza documentando la decisión

## Agentes Relacionados

- **DB Dependency Analyzer** → Confirma ausencia de referencias al objeto
- **DB Documentation Generator** → Documenta el inventario de objetos muertos antes de eliminar
- **Proactive Maintenance Advisor** → Incluye limpieza de código muerto en plan de mantenimiento
