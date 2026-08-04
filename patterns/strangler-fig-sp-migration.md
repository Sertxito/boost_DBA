# Patrón: Strangler Fig — Migración Incremental de SPs a C#

**Categoría**: Arquitectura · Modernización  
**Nivel de Riesgo**: 🟢 BAJO (si se aplica correctamente)  
**Aplicable a**: Cualquier SP con lógica de negocio

---

## El Problema

Tienes miles de stored procedures con lógica de negocio crítica y necesitas migrarla a C# sin parar producción ni arriesgarte a un rewrite big-bang que falle.

```sql
-- Situación actual: lógica crítica embebida en SP
CREATE PROCEDURE dbo.UP_I_PARTICIPANTE_INSCRIPCION
    @ID_CONVOCATORIA INT, @NIF VARCHAR(9), @SITUACION_LABORAL INT
AS
BEGIN
    -- 200 líneas mezclando:
    -- Validaciones de negocio
    -- Reglas de elegibilidad
    -- Cálculos de cuota
    -- INSERT en 5 tablas
    -- Auditoría
    -- Cifrado
END
```

**El miedo real:** "Si reescribimos esto en C# y nos equivocamos, afecta a los beneficiarios reales."

---

## La Solución: Strangler Fig

Igual que la higuera estranguladora crece alrededor del árbol sin tirarlo hasta que está lista para sustituirlo.

```
┌───────────────────────────────────────────┐
│                                           │
│   ÁRBOL VIEJO (SP)        HIGUERA (C#)   │
│                                           │
│   SP activo en prod   →   C# crece al    │
│   durante TODO el         lado, tomando  │
│   proceso de migración    ruta por ruta  │
│                                           │
│   El SP NO se toca        El C# se       │
│   hasta que C# 100%       prueba contra  │
│   probado                 golden files   │
│                                           │
└───────────────────────────────────────────┘
```

---

## Los 5 Pasos del Strangler Fig

### Paso 1: Documentar el SP (sin tocar código)

Antes de escribir C#, entender exactamente qué hace el SP:

```sql
-- Query de análisis: inputs, outputs, tablas afectadas
SELECT 
    p.name                    AS ParameterName,
    t.name                    AS ParameterType,
    p.max_length,
    p.is_output
FROM sys.parameters p
JOIN sys.types t ON p.user_type_id = t.user_type_id
WHERE p.object_id = OBJECT_ID('dbo.UP_I_PARTICIPANTE_INSCRIPCION')
ORDER BY p.parameter_id
```

**Salida esperada:** Interface C# generada automáticamente.

### Paso 2: Capturar Golden Files (regresión baseline)

Ejecutar el SP actual y guardar sus outputs como archivos de referencia:

```csharp
// En test project: capturar outputs actuales del SP (una sola vez)
[Fact]
public async Task CaptureGoldenFiles_InscripcionParticipante()
{
    var testCases = new[]
    {
        new { IdConvocatoria = 1, Nif = "12345678A", SituacionLaboral = 1 },
        new { IdConvocatoria = 1, Nif = "87654321B", SituacionLaboral = 2 },
        // ... 20-30 casos representativos
    };

    foreach (var tc in testCases)
    {
        var result = await _conn.QueryAsync(
            "EXEC dbo.UP_I_PARTICIPANTE_INSCRIPCION @ID, @NIF, @SIT",
            tc);

        var json = JsonSerializer.Serialize(result);
        await File.WriteAllTextAsync(
            $"golden-files/inscripcion-{tc.Nif}.json", json);
    }
}
```

### Paso 3: Anti-Corruption Layer (ACL)

Crear la interface C# y una implementación que sigue llamando al SP:

```csharp
// 1. Definir el contrato del dominio
public interface IInscripcionService
{
    Task<Result<InscripcionResult>> InscribirAsync(InscribirCommand cmd);
}

// 2. ACL: implementación que llama al SP (sin lógica nueva)
public class SqlInscripcionService : IInscripcionService
{
    public async Task<Result<InscripcionResult>> InscribirAsync(InscribirCommand cmd)
    {
        try
        {
            var result = await _conn.QuerySingleAsync<InscripcionResult>(
                "EXEC dbo.UP_I_PARTICIPANTE_INSCRIPCION @IdConvocatoria, @Nif, @SituacionLaboral",
                new { cmd.IdConvocatoria, cmd.Nif, cmd.SituacionLaboral });
            return Result.Success(result);
        }
        catch (SqlException ex)
        {
            return Result.Failure<InscripcionResult>(ex.Message);
        }
    }
}

// 3. Registrar en DI — la app usa la interface, no el SP directamente
builder.Services.AddScoped<IInscripcionService, SqlInscripcionService>();
```

**Ahora la aplicación habla con C#. El SP sigue activo.**

### Paso 4: Implementación C# (con regresión)

Implementar la lógica en C# y validar contra golden files:

```csharp
// Nueva implementación C# (lógica extraída del SP)
public class CSharpInscripcionService : IInscripcionService
{
    private readonly INifValidator _nifValidator;
    private readonly IConvocatoriaRepository _convRepo;
    private readonly IParticipanteRepository _participanteRepo;

    public async Task<Result<InscripcionResult>> InscribirAsync(InscribirCommand cmd)
    {
        // Validaciones extraídas del SP línea a línea
        if (!_nifValidator.IsValid(cmd.Nif))
            return Result.Failure<InscripcionResult>("NIF inválido");

        var conv = await _convRepo.GetByIdAsync(cmd.IdConvocatoria);
        if (conv is null)
            return Result.Failure<InscripcionResult>("Convocatoria no encontrada");

        if (conv.Estado != EstadoConvocatoria.Publicada)
            return Result.Failure<InscripcionResult>("Convocatoria no abierta");

        // ... resto de reglas extraídas

        var idNuevo = await _participanteRepo.InsertAsync(cmd);
        return Result.Success(new InscripcionResult(idNuevo));
    }
}

// Test de regresión contra golden files
[Theory]
[MemberData(nameof(GoldenFileCases))]
public async Task CSharpImpl_MatchesGoldenFiles(string goldenFile, InscribirCommand cmd)
{
    var expected = JsonSerializer.Deserialize<InscripcionResult>(
        await File.ReadAllTextAsync(goldenFile));

    var actual = await _csharpService.InscribirAsync(cmd);

    actual.Value.Should().BeEquivalentTo(expected);
}
```

### Paso 5: Feature Flag y Cutover

Cambiar la implementación activa mediante feature flag, sin redespliegue:

```csharp
// Feature flag controla cuál implementación está activa
public class InscripcionServiceFactory
{
    public IInscripcionService Create(IFeatureManager features)
    {
        return features.IsEnabled("UseNewInscripcionService")
            ? _serviceProvider.GetRequiredService<CSharpInscripcionService>()
            : _serviceProvider.GetRequiredService<SqlInscripcionService>(); // ACL → SP
    }
}

// appsettings.json (cambio sin redeploy)
{
  "FeatureManagement": {
    "UseNewInscripcionService": false  // ← cambiar a true para activar C#
  }
}
```

**Proceso de cutover:**
1. Activar flag al 1% del tráfico → monitorear errores
2. 10% → 50% → 100% (si sin errores)
3. Mantener SP vivo 2-4 semanas después del 100%
4. Eliminar SP y ACL

---

## Priorización: ¿Por Dónde Empezar?

### Cuadrante de Priorización

```
IMPACTO NEGOCIO
     ▲
     │  🔴 CRÍTICOS        🟡 ESTRATÉGICOS
     │  (migrar último,    (migrar 2do,
     │   máxima cobertura)  validar con negocio)
     │
     │  🟢 QUICK WINS      🟠 TÉCNICOS
     │  (migrar primero,   (migrar 3ro,
     │   fácil + seguro)    sin impacto usuario)
     └────────────────────────────────────► COMPLEJIDAD
```

### Para ProjectName

| Categoría | SPs | Ejemplos | Fase |
|---|---|---|---|
| 🟢 Quick Wins | bi.\*_S (1.195) | Reporting queries | **1ª** |
| 🟢 Quick Wins | ale.\*_S (11) | Alegaciones reads | **1ª** |
| 🟡 Estratégicos | plc.\* (338) | Cálculos de convoc. | **2ª** |
| 🟠 Técnicos | vt.\* (240) | Validaciones | **2ª** |
| 🔴 Críticos | dbo.UP_UID_\* | Transaccionales | **4ª** |
| 🔴 Críticos | Cadena de cifrado | SP de apertura de llave | **4ª** (paralelo) |

---

## Señales de que el Patrón está Funcionando

- ✅ Cada SP migrado tiene test de regresión que pasa
- ✅ Feature flags permiten rollback en segundos
- ✅ El SP original no se modifica hasta el cutover final
- ✅ Errores en producción caen tras cada migración (no suben)
- ✅ El equipo de negocio puede validar cada dominio migrado

## Señales de Alerta

- ❌ Se modifica el SP a la vez que se escribe el C# (doble riesgo)
- ❌ No hay golden files (sin regresión = sin seguridad)
- ❌ Se migra un SP sin entender qué hace
- ❌ Se intenta migrar demasiados SPs en paralelo (conflictos)
- ❌ El feature flag está siempre en `true` sin período de estabilización

---

## Agentes Relacionados

- **Extractor de Lógica Legacy** → Documentar el SP antes de migrar
- **Change Impact Assessor** → Evaluar qué depende del SP que vamos a migrar
- **Analizador de Dependencias** → Encontrar el orden correcto de migración
- **Modernization Orchestrator** → Coordinar el roadmap completo
- **Migration Script Generator** → Scripts SQL de transición (deprecate, archive, drop)

