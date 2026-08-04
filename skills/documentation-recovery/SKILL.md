---
name: 'documentation-recovery'
description: 'Auto-genera documentación faltante analizando código y extrayendo metadatos'
---

# Habilidad de Recuperación de Documentación

## Propósito
Crea documentación comprensiva y precisa analizando artefactos de código de SQL Server - la documentación que nadie escribió pero todos necesitan.

## Entrada
- Cadena de conexión de SQL Server
- Objetos de base de datos a documentar (todos o subset específico)
- Contexto de proceso de negocio (opcional)
- Notas de entrevista de stakeholders (opcional)
- Código de aplicación que interactúa con base de datos (opcional)

## Salida
- **Diccionario de Datos**: 
  - Cada tabla con propósito de negocio, propietario, frecuencia de uso
  - Cada columna con tipo de datos, restricciones, significado de negocio
  - Relaciones y claves foráneas con lógica de negocio
  - Índices con implicaciones de rendimiento

- **Documentación de Procedimiento**:
  - Propósito y contexto de negocio
  - Parámetros con descripciones y valores de ejemplo
  - Valores de retorno y conjuntos de resultados
  - Dependencias y qué objetos modifica
  - Problemas conocidos o casos extremos
  - Ejemplos de uso y patrones típicos de llamada

- **Diagramas Entidad-Relación**:
  - Schema visual con nombres de entidad de negocio
  - Flujo de datos entre entidades principales
  - Caminos críticos y límites de transacción

- **Documentación de Linaje de Datos**:
  - Cómo fluyen datos de fuente a través de ETL a reportes
  - Reglas de transformación y lógica de negocio
  - Reglas de calidad de datos y puntos de validación
  - Cambios históricos a schema/lógica

- **Runbooks de Procesos**:
  - Procedimientos paso a paso para operaciones críticas
  - Cuándo se ejecutan procedimientos y duración esperada
  - Qué hacer si algo se rompe
  - Indicadores de éxito/fallo
  - Procedimientos de reversión

## Instrucciones Paso a Paso

### 1. Definición de Scope
Identifica qué documentar:
- **Scope**: Base de datos completa vs. schemas/módulos específicos
- **Audiencia**: Desarrolladores, DBAs, Analistas de Negocio, Usuarios Finales
- **Nivel de Detalle**: Resumen ejecutivo vs. especificación técnica
- **Prioridad**: Sistemas críticos primero, nice-to-have después

### 2. Contexto de Negocio
Recopila significado de negocio:
- ¿Qué representa cada tabla? (no solo nombre técnico)
- ¿Qué eventos de negocio disparan procedimientos?
- ¿Cuáles reportes/procesos dependen de estos datos?
- ¿Quiénes son los propietarios y stakeholders del sistema?

### 3. Documentación de Schema
```sql
-- Genera diccionario de datos a partir del schema
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    CAST(c.max_length AS VARCHAR(10)) AS Length,
    CASE WHEN c.is_nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END AS Nullable,
    ISNULL(dc.definition, 'N/A') AS DefaultValue,
    OBJECT_DEFINITION(c.default_object_id) AS ComputedFormula
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.system_type_id = ty.system_type_id
LEFT JOIN sys.default_constraints dc ON c.default_object_id = dc.object_id
```

### 4. Extrae Lógica de Procedimiento
```sql
-- Obtiene definición de procedimiento y métricas de complejidad
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    OBJECT_DEFINITION(object_id) AS ProcedureCode,
    (SELECT COUNT(*) FROM sys.sql_expression_dependencies 
     WHERE referencing_id = object_id) AS DependenciesCount
FROM sys.procedures
```

### 5. Analiza Parámetros & Resultados
```sql
-- Documenta parámetros de procedimiento
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    name AS ParameterName,
    system_type_name(user_type_id) AS DataType,
    is_output,
    has_default_value
FROM sys.parameters
WHERE OBJECT_OBJECTPROPERTY(object_id, 'IsProcedure') = 1
```

### 6. Extracción de Reglas de Negocio desde Código SQL Real

**OBLIGATORIO**: Las reglas de negocio se extraen leyendo el cuerpo SQL de los SPs, NO inferiendo por nombre ni por metadata. El proceso es:

#### 6.1 Localizar SPs Críticos/Complejos

```powershell
# Localizar línea exacta del SP en el schema
Select-String -Path "schema/db.sql" -Pattern "NOMBRE_SP" | Select-Object -First 3 LineNumber, Line
```

#### 6.2 Leer el Cuerpo Completo

```powershell
# Extraer cuerpo completo por número de línea
Get-Content "schema/db.sql" -TotalCount ($lineStart + 500) | Select-Object -Skip ($lineStart - 1)
```

#### 6.3 Plantilla de Regla de Negocio (extraída del código real)

```markdown
### R[N]: [Nombre descriptivo de la regla]

**SP de origen**: `schema.NombreSP`
**Fecha SP**: [del encabezado del SP]
**Autor SP**: [del encabezado del SP]

**Descripción de negocio**: [En lenguaje de negocio, sin SQL]

**Lógica SQL que la implementa**:
\`\`\`sql
-- Fragmento real del SP
CASE WHEN campo = valor THEN ... END
\`\`\`

**Variables y umbrales clave**:
| Variable | Valor/Tipo | Significado |
|---|---|---|
| @PARAM | INT | ... |

**Estados involucrados**: (si aplica máquina de estados)
| ID | Estado | Condición de transición |
|---|---|---|
| 1 | BORRADOR | ... |
| 5 | FINALIZADO | ... |

**Dependencias**:
- Tablas leídas: T_TABLA_A, T_TABLA_B
- Tablas escritas: T_TABLA_C
- SPs llamados: schema.SP_DEPENDIENTE

**Preguntas abiertas**: (lo que el código no deja claro)
- ¿Por qué el valor mágico 65535 en F_BAJA?
- ¿Qué convocatoria controla el ID_DICCIONARIO_CONFIG = 498?
```

#### 6.4 Señales de Reglas de Negocio en SQL

| Patrón SQL | Tipo de regla |
|---|---|
| `CASE WHEN estado = N THEN` | Máquina de estados / Transición |
| `IF NOT EXISTS (SELECT...)` | Validación de unicidad |
| `MERGE ... WHEN NOT MATCHED` | Upsert con lógica de creación |
| `DecryptByKey(campo)` | Datos sensibles protegidos por ley |
| `EXEC UP_V_ABRIR_LLAVE` | Acceso a datos cifrados (GDPR relevante) |
| `AVG/SUM/MAX` sobre jeraquías | Cálculo agregado de puntuación |
| `WHILE @Nivel > 0` | Propagación jerárquica de valores |
| `ID_TIPOEXCESO = N` | Casuística de excesos por tipo |
| `plc.ParticipanteFinalizadoOAbandono(...)` | Lógica de elegibilidad encapsulada |
| `B_EXCESO = 1 AND ID_TIPOEXCESO = N` | Clasificación de excesos regulatorios |
| `@ID_DICCIONARIO_CONFIG = N` | Configuración por convocatoria |
| `IN ('CABANT01A', ...)` | Codes de causa de anulación |

#### 6.5 Proceso de Extracción por SP

Para cada SP Critical/Complex:
1. Leer encabezado → obtener propósito declarado
2. Leer parámetros → entender el contrato de entrada
3. Identificar patrones de la tabla 6.4 → clasificar tipo de regla
4. Documentar con la plantilla 6.3
5. Marcar preguntas abiertas que requieren validación con el negocio

### 7. Crea Matrices de Dependencias
```sql
-- Mapea cuáles procedimientos modifican cuáles tablas
SELECT 
    OBJECT_NAME(referencing_id) AS Procedure,
    OBJECT_NAME(referenced_id) AS TableModified,
    'UPDATE' AS ModificationType
FROM sys.sql_expression_dependencies
WHERE OBJECTPROPERTY(referencing_id, 'IsProcedure') = 1
  AND OBJECTPROPERTY(referenced_id, 'IsTable') = 1
```

### 8. Genera Documentos de Salida

**Plantilla Markdown: Documentación de Tabla**
```markdown
## [NombreTabla]

**Propósito de Negocio**: [Qué entidad de negocio representa esto]

**Propietario**: [Equipo/Persona responsable]

**Frecuencia de Uso**: [Con qué frecuencia se modifican/acceden datos]

### Columnas

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| ID | INT | NO | Identificador único |
| Nombre | VARCHAR(100) | NO | Nombre de negocio |

### Relaciones
- Clave Foránea: TablaParent.ID referencia [NombreTabla].ParentID

### Índices
- PK_[NombreTabla]: Clustered en ID
- IX_[NombreTabla]_Name: Non-clustered en Name (INCLUDES ParentID)

### Cambios Recientes
- 2024-01: Agregada columna LastModified
- 2024-02: Migrada a nuevo schema
```

**Plantilla Markdown: Documentación de Procedimiento**
```markdown
## sp_ProcessMonthlyClosing

**Propósito de Negocio**: Ejecuta procesamiento de cierre de fin de mes, reconcilia cuentas, congela datos de mes anterior

**Propietario**: Operaciones Financieras

**Frecuencia de Ejecución**: Último día laborable del mes a las 23:00

### Parámetros
- @BusinessUnitID INT - Requerido - Cuál unidad de negocio cerrar
- @ClosingDate DATETIME - Opcional - Anula fecha de cierre
- @SendNotifications BIT - Default: 1 - Envía notificaciones a equipo GL

### Pasos de Procesamiento
1. Bloquea datos del mes actual
2. Valida que todas las transacciones se hayan ingresado
3. Ejecuta procedimientos de reconciliación
4. Genera reportes de cierre
5. Archiva datos archivados
6. Desbloquea mes anterior

### Manejo de Errores
- Si la reconciliación falla, transacción se revierte y error se registra
- Notificaciones se envían al equipo de Operaciones con detalles de error

### Problemas Conocidos
- Toma 45 minutos completarse en meses pesados
- Debe ejecutarse en modo de usuario único para prevenir bloqueos
- Requiere validación manual de saldos GL

### Incidentes Recientes
- 2024-01-31: Timeout debido a índice faltante en Transactions.AcctDate
- 2024-02-29: Falló debido a cuenta GL no existente en tabla de control
```

## Lista de Verificación de Documentación
- [ ] Todas las tablas documentadas con propósito de negocio
- [ ] Todas las columnas documentadas con significado y uso
- [ ] Todos los procedimientos documentados con propósito y parámetros
- [ ] Todas las relaciones y restricciones documentadas
- [ ] Todos los procedimientos críticos tienen runbooks
- [ ] Diagramas de flujo de datos creados para procesos principales
- [ ] Reglas de negocio extraídas y documentadas
- [ ] Problemas conocidos y workarounds anotados
- [ ] Propiedad del equipo asignada
- [ ] Patrones de ejecución documentados

## Mantenimiento
- Asigna propietario para actualizaciones continuas
- Establece frecuencia de revisión (se recomienda trimestral)
- Control de versiones de documentación con código
- Crea validación automatizada para detectar cambios de schema

## Formatos de Salida
- **Markdown**: Control de versiones amigable, legible
- **Wiki**: Buscable, vinculable (Confluence, GitBook)
- **PDF**: Para archivo y distribución
- **Dashboard HTML**: Documentación interactiva basada en navegador

