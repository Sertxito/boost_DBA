---
name: 'dependency-impact'
description: 'Mapea dependencias y analiza impacto de cambios propuestos'
---

# Habilidad de Impacto de Dependencias

## Propósito
Crea mapas comprensivos de dependencias y análisis de impacto para cambios propuestos en bases de datos para identificar qué se rompe antes de que lo rompas.

## Entrada
- Schema de base de datos y definiciones de objetos
- Código fuente de stored procedures y funciones
- Cambio propuesto (ej. "renombra tabla Users a Customers", "remueve procedimiento sp_OldReport")
- Opcional: código de aplicación que pueda referenciar objetos cambiados
- Opcional: definiciones de trabajos ETL/reportes

## Salida
- **Gráfico de Dependencias**: Representación visual mostrando:
  - Qué objetos referencian el objeto cambiado (impacto upstream)
  - Qué objetos el objeto cambiado referencia (dependencias downstream)
  - Dependencias circulares y cadenas de acoplamiento
  - Dependencias entre bases de datos (si existen)

- **Reporte de Análisis de Impacto**:
  - Radio de impacto estimado (número de objetos afectados)
  - Nivel de riesgo (Bajo/Medio/Alto/Crítico)
  - Lista de todos los procedimientos dependientes, views, aplicaciones
  - Frecuencia de ejecución de objetos afectados (si disponible)
  - Evaluación de complejidad de reversión

- **Estrategia de Pruebas**:
  - Casos de prueba recomendados para validar cambio
  - Queries para verificar no corrupción de datos
  - Recomendaciones de baseline de rendimiento

- **Plan de Reversión**:
  - Procedimientos de reversión paso a paso
  - Requisitos de recuperación de datos
  - Tiempo estimado de recuperación

## Instrucciones Paso a Paso

### 1. Modela el Cambio Propuesto
Documenta el cambio exacto:
- **Tipo**: Renombrar, Eliminar, Modificar, Agregar Columna, etc.
- **Objeto**: Nombre exacto (schema.nombre)
- **Estado Actual**: Definición/comportamiento actual
- **Estado Propuesto**: Definición/comportamiento nuevo
- **Razón**: Justificación de negocio

### 2. Dependencias Directas
```sql
-- Encuentra procedimientos/funciones que referencian directamente el objeto
SELECT DISTINCT OBJECT_NAME(referencing_id) AS DependentObject,
       OBJECT_NAME(referenced_id) AS ReferencedObject
FROM sys.sql_expression_dependencies
WHERE referenced_id = OBJECT_ID('schema.nombre_objeto')
```

### 3. Dependencias Transitivas
```sql
-- Encuentra dependencias indirectas (A depende de B, B depende de C)
-- Encuentra recursivamente todo impacto upstream/downstream
WITH DependencyChain AS (
    SELECT referencing_id AS DependentID, referenced_id AS TargetID, 1 AS Depth
    FROM sys.sql_expression_dependencies
    WHERE referenced_id = OBJECT_ID('schema.nombre_objeto')
    
    UNION ALL
    
    SELECT d.referencing_id, dc.TargetID, dc.Depth + 1
    FROM DependencyChain dc
    JOIN sys.sql_expression_dependencies d ON dc.DependentID = d.referenced_id
    WHERE dc.Depth < 10  -- Limita recursión
)
SELECT DISTINCT OBJECT_NAME(DependentID) AS AffectedObject, Depth
FROM DependencyChain
ORDER BY Depth
```

### 4. Impacto en Aplicación
```sql
-- Identifica si objeto está referenciado en código de aplicación
-- (Requiere análisis de repositorio de código o rastreo de SQL dinámico)
SEARCH: Grep/búsqueda semántica de nombre de objeto en codebase de aplicación
```

### 5. Frecuencia de Ejecución
```sql
-- Determina con qué frecuencia se ejecutan procedimientos afectados
SELECT OBJECT_NAME(object_id) AS ProcedureName,
       execution_count, 
       last_execution_time,
       (SELECT COUNT(*) FROM sys.sql_expression_dependencies WHERE referencing_id = object_id) AS DependsOnCount
FROM sys.dm_exec_procedure_stats
WHERE database_id = DB_ID()
ORDER BY execution_count DESC
```

### 6. Evaluación de Riesgo
Puntúa el cambio:
- **Radio de Impacto**: Número de objetos dependientes × profundidad de árbol de dependencias
- **Criticidad**: Frecuencia de ejecución de procedimientos dependientes
- **Complejidad**: Cambios de schema, requisitos de migración de datos
- **Esfuerzo de Pruebas**: Número de casos de prueba necesarios
- **Riesgo General**: Combinación ponderada de factores anteriores

### 7. Lista de Verificación de Validación de Pruebas
- [ ] Procedimientos dependientes se ejecutan sin errores
- [ ] Restricciones de integridad de datos aún válidas
- [ ] Métricas de rendimiento dentro de rango aceptable
- [ ] Sin referencias de código abandonado (manejo de errores en capa app)
- [ ] Procesos ETL/reportes producen salida correcta
- [ ] Trabajos programados se completan satisfactoriamente
- [ ] Transacciones se comprometen sin deadlocks

## Escenarios de Ejemplo

### Escenario 1: Renombra una Tabla
```
Cambio: Renombra [Users] a [Customers]
Impacto: 
  - 23 stored procedures referencian tabla Users
  - 5 views dependen de Users
  - 12 procedimientos ETL deben actualizarse
  - 3 reportes consultan Users directamente
  - Aplicación tiene nombre de tabla hardcoded en 47 lugares
Riesgo: ALTO - Requiere cambios de código en 3 capas
Recomendación: Usa enfoque de versionamiento de schema en lugar
```

### Escenario 2: Remueve Procedimiento No Utilizado
```
Cambio: Drop sp_LegacyMonthlyReport
Impacto:
  - Última ejecución: hace 2 años
  - 0 procedimientos dependen de él
  - Un trabajo SQL Agent programado lo referencia (crea logs de error)
Riesgo: BAJO
Recomendación: Seguro de remover después de deshabilitar trabajo SQL Agent
```

### Escenario 3: Agrega Nueva Columna con Restricciones
```
Cambio: Agrega columna NOT NULL a tabla de producción
Impacto:
  - Todos los procedimientos INSERT deben actualizarse
  - Valores NULL existentes deben rellenarse
  - 156 instrucciones INSERT afectadas
  - Sin dependencias de clave foránea
Riesgo: MEDIO - Requiere estrategia de migración de datos
Recomendación: Agrega como nullable primero, rellena datos, luego agrega restricción
```

## Formatos de Salida
- **Diagrama Mermaid**: Visualización de gráfico de dependencias
- **Reporte Markdown**: Análisis de impacto legible por humanos
- **JSON**: Datos estructurados para automatización
- **Script SQL**: Plantilla de procedimiento de reversión

## Lista de Verificación de Validación
- [ ] Todas las dependencias directas identificadas
- [ ] Dependencias transitivas trazadas 2+ niveles
- [ ] Impactos en capa de aplicación identificados
- [ ] Dependencias entre bases de datos anotadas
- [ ] Estadísticas de ejecución incluidas
- [ ] Evaluación de riesgo documentada
- [ ] Estrategia de pruebas definida
- [ ] Plan de reversión creado

