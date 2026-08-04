---
name: 'database-analysis'
description: 'Análisis comprensivo de stored procedures y schema de SQL Server'
---

# Habilidad de Análisis de Base de Datos

## Propósito
Extrae y cataloga todos los objetos de base de datos, sus propiedades y características de entornos SQL Server.

## Entrada
- Cadena de conexión de SQL Server o credenciales
- Nombre(s) de base de datos a analizar
- Scope: schema específico o base de datos completa
- Opcional: filtro por tipo de objeto (procedimientos, funciones, tablas, views)

## Salida
- **Inventario de Schema**: Lista completa de todos los objetos con propiedades
  - Tablas: nombre, columnas (tipo, nullable, default), claves primarias, índices
  - Stored Procedures: parámetros, valores de retorno, complejidad de lógica estimada
  - Views: cadena de dependencias, mapeo de columnas
  - Funciones: escalares/table-valued, parámetros, tipos de retorno
  - Índices: tipo (clustered, non-clustered), columnas, estadísticas de uso

- **Documentación de Metadatos**: Para cada objeto:
  - Fecha de creación, fecha de última modificación
  - Tamaño en disco/memoria
  - Estadísticas de ejecución (si disponibles)
  - Objetos referenciados (tablas, procedimientos, funciones)

- **Reporte de Análisis**: 
  - Conteo de objetos por tipo
  - Métricas de complejidad de schema
  - Candidatos de código muerto (procedimientos/funciones no utilizados)
  - Hotspots de rendimiento

## Instrucciones Paso a Paso

### 1. Conectar & Autenticar
```sql
-- Verifica conexión a base de datos objetivo
SELECT DB_NAME() AS [Database], @@SERVERNAME AS [Server]
```

### 2. Extrae Objetos de Schema
```sql
-- Obtiene todas las tablas, views, stored procedures, funciones
SELECT 
    OBJECT_NAME(object_id) AS [Name],
    CASE type WHEN 'U' THEN 'Table' WHEN 'V' THEN 'View' 
             WHEN 'P' THEN 'Procedure' WHEN 'FN' THEN 'Function' END AS [Type],
    create_date, modify_date
FROM sys.objects
WHERE database_id = DB_ID()
```

### 3. Analiza Estructura de Tabla
```sql
-- Extrae columnas de tabla, restricciones, índices
SELECT t.name AS TableName, c.name AS ColumnName, ty.name AS DataType,
       c.max_length, c.is_nullable, c.is_identity
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
```

### 4. Extrae Código de Procedimiento/Función
```sql
-- Obtiene definiciones de stored procedure y función
SELECT object_id, definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('nombre_procedimiento')
```

### 5. Mapea Referencias & Dependencias
```sql
-- Encuentra qué objetos referencian qué
SELECT OBJECT_NAME(referencing_id) AS ReferencingObject,
       OBJECT_NAME(referenced_id) AS ReferencedObject
FROM sys.sql_expression_dependencies
```

### 6. Identifica Objetos No Utilizados
```sql
-- Encuentra stored procedures con conteo de ejecución cero
SELECT name FROM sys.procedures p
LEFT JOIN sys.dm_exec_procedure_stats s ON p.object_id = s.object_id
WHERE s.object_id IS NULL
```

## Ejemplo de Uso

**Escenario 1: Auditoría de Base de Datos Completa**
- Entrada: Conexión a SQL Server de producción, base de datos 'LegacyERP'
- Salida: Catálogo de 3,200+ objetos con fechas de modificación, estadísticas de uso
- Caso de Uso: Entiende complejidad de base de datos antes de modernización

**Escenario 2: Análisis de Procedimiento**
- Entrada: Stored procedure específico 'sp_MonthlyClosing'
- Salida: Definición de procedimiento, todos los parámetros, tablas/procedimientos referenciados, conteo de ejecución
- Caso de Uso: Evalúa criticidad y dependencias de ETL crítico

**Escenario 3: Detección de Código Muerto**
- Entrada: Base de datos con problemas de rendimiento
- Salida: Lista de procedimientos no utilizados, funciones obsoletas, tablas abandonadas
- Caso de Uso: Remueve deuda técnica sin afectar producción

## Formatos de Salida

- **JSON**: Datos estructurados para automatización
- **HTML Report**: Dashboard amigable para ejecutivos
- **SQL Script**: Queries de análisis re-ejecutables

## Requisitos
- Acceso de lectura a vistas del catálogo del sistema de SQL Server (sys.objects, sys.columns, etc.)
- Acceso a queries de DMVs sys.dm_* para estadísticas de ejecución
- Sin permisos de escritura necesarios (solo análisis de lectura)

## Troubleshooting
- **"Permission denied on sys.dm_exec_procedure_stats"**: Limitado a procedimientos ejecutados por usuario actual
- **"Cannot find procedure X"**: Verifica que nombre de schema se incluya (dbo.nombre_procedimiento)
- **"Execution stats are NULL"**: El procedimiento puede no haber sido ejecutado desde reinicio de SQL Server

