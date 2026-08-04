---
name: 'Migración de Stored Procedures a Capa de Aplicación'
description: 'Skill para extraer lógica de negocio de SPs a C#/.NET, aplicando Strangler Fig, DDD y patrones de anti-corrupción'
---

# Migración SP → Capa de Aplicación (C#/.NET)

## Propósito

Guiar la migración incremental de lógica de negocio embebida en stored procedures hacia una capa de aplicación en C# (o cualquier lenguaje), sin big-bang, con rollback en cada paso y sin interrumpir producción.

---

## Estrategia General: Strangler Fig Pattern

La clave es **nunca reemplazar todo de golpe**. Cada SP se convierte en un servicio C# de forma incremental, manteniendo el SP activo en paralelo hasta que el nuevo código supera el 100% de los tests.

```
ESTADO INICIAL:
  App → SP en SQL Server (lógica completa en BD)

ESTADO INTERMEDIO (Anti-Corruption Layer):
  App → C# Service → SP (wrapper que traduce sin lógica nueva)
              ↓
           [Tests de regresión pasan]

ESTADO FINAL:
  App → C# Service (lógica en código, SP eliminado o archivado)
```

**Nunca se corta el cable antes de tender el nuevo.**

---

## Fases de Migración

### Fase 0: Preparación (Sin tocar código)

Antes de escribir una línea de C#:

- [ ] **Mapear dominios** a bounded contexts (usar reporte `06-BUSINESS-LOGIC-DOMAINS.md`)
- [ ] **Clasificar SPs** en cuatro categorías:
  - 🟢 **CRUD puro** → EF Core / Dapper directo (sin lógica)
  - 🟡 **Lógica simple** → C# service con unit tests
  - 🟠 **Lógica compleja** → C# domain model + integration tests
  - 🔴 **Transaccional crítico** → Migración última, máxima cobertura
- [ ] **Establecer contrato**: qué devuelve cada SP (input/output types) → genera C# interfaces
- [ ] **Crear suite de regresión**: ejecutar SP actual → capturar outputs como golden files

### Fase 1: Anti-Corruption Layer (ACL)

Crear wrappers C# que llaman a los SPs existentes. Sin lógica nueva, solo traducción:

```csharp
// PASO 1: Interface del dominio (contrato, sin implementación SQL)
public interface IPlanFormacionRepository
{
    Task<PlanFormacion?> GetByIdAsync(int id);
    Task<IReadOnlyList<PlanFormacion>> GetByConvocatoriaAsync(int idConvocatoria);
    Task<int> CreateAsync(CreatePlanFormacionCommand cmd);
}

// PASO 2: Implementación que delega al SP (Anti-Corruption Layer)
public class SqlPlanFormacionRepository : IPlanFormacionRepository
{
    private readonly SqlConnection _conn;

    public async Task<PlanFormacion?> GetByIdAsync(int id)
    {
        // Llama al SP existente — CERO lógica nueva aquí
        return await _conn.QuerySingleOrDefaultAsync<PlanFormacion>(
            "EXEC dbo.UP_S_PLANFORMACION_BY_ID @ID",
            new { ID = id });
    }
}
```

**Resultado:** La app habla con C# interfaces. La implementación sigue siendo SQL.

### Fase 2: Migración por Dominio (Read Models primero)

Empezar por los SPs de **lectura** del esquema `bi` (los más seguros, sin side effects):

```csharp
// ANTES: app llama directamente al SP de reporting
EXEC bi.AccionesFormativasPlanFormacion_S @ID_PLAN = 123

// DESPUÉS: C# query object con Dapper (mantenible, testeble)
public class AccionesFormativasQuery
{
    public async Task<IReadOnlyList<AccionFormativa>> ExecuteAsync(int idPlan)
    {
        const string sql = @"
            SELECT af.ID, af.D_DESCRIPCION, af.N_HORAS, af.F_INICIO, af.F_FIN,
                   c.D_NOMBRE AS D_CENTRO, s.D_NOMBRE AS D_SECTOR
            FROM dbo.T_ACCION_FORMATIVA af
            JOIN dbo.T_CENTRO c ON af.ID_CENTRO = c.ID
            JOIN dbo.T_SECTOR s ON af.ID_SECTOR = s.ID
            WHERE af.ID_PLANFORMACION = @IdPlan
            ORDER BY af.F_INICIO";

        return (await _conn.QueryAsync<AccionFormativa>(sql, new { IdPlan = idPlan }))
               .ToList();
    }
}
```

**Orden de migración:**
1. `bi.*` (1.195 SPs de reporting, solo lectura) → **Dapper queries** o **EF Core projections**
2. `dbo.UP_S_*` (selects del monolito) → **Dapper queries** parametrizadas
3. `dbo.UP_I_*, UP_U_*` (inserts/updates) → **EF Core entities** o **Dapper commands**
4. `dbo.UP_UID_*` (transaccionales complejos) → **Domain Services** con orquestación

### Fase 3: Migrar Lógica de Negocio (Write Models)

Extraer las reglas de negocio de los SPs más complejos a C# domain objects:

```csharp
// REGLA R7: Inscripción de Participante (extraída de SP dbo.UP_I_PARTICIPANTE)
public class InscripcionParticipanteService
{
    private readonly IParticipanteRepository _repo;
    private readonly IConvocatoriaRepository _convRepo;
    private readonly INifValidator _nifValidator;

    public async Task<Result<int>> InscribirAsync(InscribirParticipanteCommand cmd)
    {
        // Validaciones extraídas del SP
        if (!_nifValidator.IsValid(cmd.Nif))
            return Result.Failure<int>("NIF/CIF inválido");

        var convocatoria = await _convRepo.GetByIdAsync(cmd.IdConvocatoria);
        if (convocatoria.Estado != EstadoConvocatoria.Publicada)
            return Result.Failure<int>("La convocatoria no está abierta");

        // Regla de negocio: % mínimo de desempleados
        var porcentajeDesempleados = await _repo
            .GetPorcentajeDesempleadosAsync(cmd.IdConvocatoria);
        if (cmd.SituacionLaboral == SituacionLaboral.Empleado &&
            porcentajeDesempleados < convocatoria.MinPorcentajeDesempleados)
            return Result.Failure<int>(
                $"El grupo requiere mín. {convocatoria.MinPorcentajeDesempleados}% desempleados");

        var id = await _repo.InsertAsync(cmd);
        return Result.Success(id);
    }
}
```

### Fase 4: Cifrado — Migrar de funciones legacy a Azure Key Vault

El sistema de cifrado actual (funciones/procedimientos legacy) se reemplaza por:

```csharp
// ANTES: los SPs abren contexto criptografico dentro de SQL
// DESPUÉS: C# gestiona el ciclo de vida del cifrado

// Program.cs / DI setup
builder.Services.AddAzureKeyVault(
    new Uri($"https://{keyVaultName}.vault.azure.net/"),
    new DefaultAzureCredential());

// Servicio de cifrado
public class EncryptionService
{
    private readonly CryptographyClient _cryptoClient;

    public async Task<string> EncryptAsync(string plainText)
    {
        var result = await _cryptoClient.EncryptAsync(
            EncryptionAlgorithm.RsaOaep,
            Encoding.UTF8.GetBytes(plainText));
        return Convert.ToBase64String(result.Ciphertext);
    }

    public async Task<string> DecryptAsync(string cipherText)
    {
        var result = await _cryptoClient.DecryptAsync(
            EncryptionAlgorithm.RsaOaep,
            Convert.FromBase64String(cipherText));
        return Encoding.UTF8.GetString(result.Plaintext);
    }
}

// Repository usa el servicio — sin OPEN SYMMETRIC KEY
public async Task<Beneficiario> GetDatosEncriptadosAsync(int id)
{
    var row = await _conn.QuerySingleAsync<BeneficiarioRow>(
        "SELECT DatosEncriptados FROM T_BENEFICIARIO WHERE ID = @Id", new { id });

    return new Beneficiario
    {
        Id = row.Id,
        DatosSensibles = await _encryption.DecryptAsync(row.DatosEncriptados)
    };
}
```

---

## Clasificación de SPs para ProjectName

### 🟢 Migración Inmediata — CRUD Puro (Dapper / EF Core)

```
bi.*_S        → Queries de reporting → EF Core projections o Dapper
dbo.UP_S_*    → Selects simples      → Dapper QueryAsync<T>
ale.*_S       → Alegaciones reads    → Dapper QueryAsync<T>
anu.UP_S_*    → Anulaciones reads    → Dapper QueryAsync<T>
```

**Esfuerzo:** 2-4 horas por SP · ~1.200 SPs · ~2.400-4.800 horas total

### 🟡 Migración Media — Lógica Simple (C# Services)

```
dbo.UP_I_*    → Inserts con validación básica   → Service + Command
dbo.UP_U_*    → Updates con condiciones         → Service + Command
plc.*         → Cálculos de convocatoria        → Domain Service
vt.*          → Validaciones técnicas           → Validator classes
```

**Esfuerzo:** 4-8 horas por SP · ~800 SPs · ~3.200-6.400 horas total

### 🟠 Migración Compleja — Domain Models (DDD)

```
dbo.UP_UID_*  → Transaccionales críticos        → Aggregate roots + Domain events
bi.Agrupacion*→ Lógica de agrupación masiva     → CQRS read models
bya.*         → Beneficiarios + años            → Bounded Context propio
gcc.*         → Gestión de centros              → Bounded Context propio
```

**Esfuerzo:** 8-20 horas por SP · ~400 SPs · ~3.200-8.000 horas total

### 🔴 Migración Crítica — Última Fase (máxima cobertura)

```
sp_abrir_contexto_cifrado  → Migrar a Azure Key Vault (fase paralela)
dbo.*PLANFORMACION*   → Core del negocio (validar con stakeholders)
dbo.*CONVOCATORIA*    → Flujo de adjudicación (máxima criticidad)
```

**Esfuerzo:** 20-40 horas por SP · ~100 SPs · ~2.000-4.000 horas total

---

## Arquitectura Target: Bounded Contexts

```
┌─────────────────────────────────────────────────────────────────────┐
│ API Gateway / BFF                                                   │
└─────────────────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Formación   │ │Convocatorias │ │Beneficiarios │ │   Centros    │
│  Service     │ │   Service    │ │   Service    │ │   Service    │
│  (.NET API)  │ │  (.NET API)  │ │  (.NET API)  │ │  (.NET API)  │
│              │ │              │ │              │ │              │
│ EF Core      │ │ EF Core      │ │ Dapper       │ │ EF Core      │
│ SQL Server   │ │ SQL Server   │ │ SQL Server   │ │ SQL Server   │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
         │              │              │              │
         └──────────────┴──────────────┴──────────────┘
                                │
                    ┌───────────▼───────────┐
                    │  Shared Kernel        │
                    │  - ValidacionService  │
                    │  - EncryptionService  │
                    │  - AuditService       │
                    │  - DomainEvents       │
                    └───────────────────────┘
```

---

## Stack .NET Recomendado

| Capa | Tecnología | Cuándo |
|---|---|---|
| **API** | ASP.NET Core Minimal APIs / Controllers | Siempre |
| **Queries simples** | Dapper | SPs de lectura, reporting |
| **Queries complejas** | EF Core + LINQ | Entidades con relaciones |
| **Lógica de negocio** | C# Domain Services | Reglas extraídas de SPs |
| **Validación** | FluentValidation | Reemplaza validaciones en SP |
| **Cifrado** | Azure Key Vault + Azure.Security | Reemplaza funciones legacy de cifrado |
| **Transacciones** | IDbTransaction / UnitOfWork | Reemplaza BEGIN TRAN en SPs |
| **Tests** | xUnit + Moq + Testcontainers | Suite de regresión |
| **ORM** | EF Core 8+ | Write models, migrations |
| **Migrations BD** | EF Core Migrations / DbUp | Evolución de schema |

---

## Checklist por SP Migrado

- [ ] SP documentado (inputs, outputs, reglas de negocio)
- [ ] Interface C# definida (contrato)
- [ ] Golden files creados (outputs actuales capturados)
- [ ] Anti-Corruption Layer implementado (llama al SP)
- [ ] Tests de regresión pasan contra ACL
- [ ] Implementación C# creada (sin SP)
- [ ] Tests pasan contra implementación C#
- [ ] Performance validada (no regresión)
- [ ] SP marcado como `DEPRECATED` (comentario + fecha)
- [ ] Monitoreo en producción (ambas implementaciones paralelas)
- [ ] SP eliminado (tras período de estabilización: 2-4 semanas)

---

## Anti-Patrones a Evitar

| Anti-patrón | Problema | Solución |
|---|---|---|
| **Reescribir todo de golpe** | Riesgo catastrófico | Strangler Fig: SP por SP |
| **Duplicar lógica** | Inconsistencia | Un solo canonical source |
| **Hardcodear strings SQL en C#** | Mismo problema que SPs | Dapper + stored SQL en archivos `.sql` |
| **God Service** | Monolito en C# | Un servicio por bounded context |
| **Saltarse tests** | Regresiones silenciosas | Golden files + regresión automática |
| **Migrar cifrado en la misma fase** | Double risk | Migrar cifrado por separado, primero |

---

## Métricas de Progreso

```
SPs totales:           N
SPs migrados:              0   (0%)
SPs con ACL:               0   (0%)
SPs deprecados:            0   (0%)
SPs eliminados:            0   (0%)
Cobertura de tests:        0%
```

Actualizar este bloque en cada sprint como indicador de avance.

