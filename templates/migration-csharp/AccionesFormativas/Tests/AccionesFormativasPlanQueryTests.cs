// =============================================================================
// ProjectName.Reporting.Tests/AccionesFormativas/AccionesFormativasPlanQueryTests.cs
//
// Tests de regresión: validan que la impl. Dapper produce el mismo resultado
// que el SP original (golden files).
//
// Requiere: SQL Server real o Testcontainers con datos de test.
// =============================================================================

using System.Text.Json;
using Dapper;
using FluentAssertions;
using Microsoft.Data.SqlClient;
using ProjectName.Reporting.AccionesFormativas;
using ProjectName.Reporting.AccionesFormativas.Acl;
using Xunit;

namespace ProjectName.Reporting.Tests.AccionesFormativas;

/// <summary>
/// PASO 1: Ejecutar una sola vez con SQL_CONNECTION_STRING apuntando a producción
/// para capturar los golden files.
///
/// PASO 2: En CI los tests comparan DapperAccionesFormativasPlanQuery contra los
/// golden files (sin conexión a producción, usando Testcontainers con los mismos datos).
/// </summary>
public sealed class AccionesFormativasPlanQueryTests : IAsyncLifetime
{
    // Casos de test representativos (conv + expediente reales)
    // Completar con valores reales antes del primer run
    private static readonly (int IdConv, string CodExpte)[] TestCases =
    [
        (1, "EXP000001"),
        (1, "EXP000002"),
        (2, "EXP000010"),
        // Añadir 20-30 casos que cubran: con anulación, sin titulación, múltiples AFs...
    ];

    private SqlConnection? _conn;
    private SpAccionesFormativasPlanQuery? _acl;
    private DapperAccionesFormativasPlanQuery? _dapper;

    private static readonly string GoldenDir =
        Path.Combine(AppContext.BaseDirectory, "golden-files", "AccionesFormativasPlan");

    public async Task InitializeAsync()
    {
        var connStr = Environment.GetEnvironmentVariable("ProjectName_TEST_CONN")
            ?? throw new InvalidOperationException(
                "Establece ProjectName_TEST_CONN con la connection string de test");

        _conn   = new SqlConnection(connStr);
        _acl    = new SpAccionesFormativasPlanQuery(_conn);
        _dapper = new DapperAccionesFormativasPlanQuery(_conn);

        Directory.CreateDirectory(GoldenDir);

        await _conn.OpenAsync();
    }

    public async Task DisposeAsync()
    {
        if (_conn is not null)
            await _conn.DisposeAsync();
    }

    // -------------------------------------------------------------------------
    // PASO 1: Capturar golden files desde el SP (ejecutar una sola vez)
    // -------------------------------------------------------------------------

    [Fact(Skip = "Solo ejecutar manualmente para regenerar golden files")]
    public async Task CaptureGoldenFiles()
    {
        foreach (var (idConv, codExpte) in TestCases)
        {
            var result = await _acl!.ExecuteAsync(idConv, codExpte);
            var json   = JsonSerializer.Serialize(result, JsonOpts);
            var file   = GoldenFilePath(idConv, codExpte);

            await File.WriteAllTextAsync(file, json);
            Console.WriteLine($"Golden file creado: {file} ({result.Count} filas)");
        }
    }

    // -------------------------------------------------------------------------
    // PASO 2: Comparar Dapper contra golden files (ejecutar en CI siempre)
    // -------------------------------------------------------------------------

    public static IEnumerable<object[]> GoldenFileCases()
    {
        foreach (var (idConv, codExpte) in TestCases)
            yield return [idConv, codExpte];
    }

    [Theory]
    [MemberData(nameof(GoldenFileCases))]
    public async Task DapperQuery_MatchesGoldenFile(int idConvocatoria, string codExpediente)
    {
        var goldenFile = GoldenFilePath(idConvocatoria, codExpediente);

        if (!File.Exists(goldenFile))
            throw new FileNotFoundException(
                $"Golden file no encontrado. Ejecuta CaptureGoldenFiles primero: {goldenFile}");

        var expected = JsonSerializer.Deserialize<List<AccionFormativaPlanDto>>(
            await File.ReadAllTextAsync(goldenFile), JsonOpts)!;

        var actual = await _dapper!.ExecuteAsync(idConvocatoria, codExpediente);

        actual.Should().BeEquivalentTo(expected,
            opts => opts.WithStrictOrdering(),
            because: $"Conv={idConvocatoria} Expte={codExpediente}");
    }

    // -------------------------------------------------------------------------
    // Tests unitarios de comportamiento
    // -------------------------------------------------------------------------

    [Fact]
    public async Task ExecuteAsync_ExpedienteInexistente_DevuelveListaVacia()
    {
        var result = await _dapper!.ExecuteAsync(
            idConvocatoria: 999999,
            codExpediente: "NOEXISTE1");

        result.Should().BeEmpty();
    }

    [Fact]
    public async Task ExecuteAsync_CodExpedienteMasDe9Chars_TruncaCorrectamente()
    {
        // No debe lanzar excepción: CHAR(9) se trunca
        var act = async () => await _dapper!.ExecuteAsync(1, "123456789EXTRA");
        await act.Should().NotThrowAsync();
    }

    [Fact]
    public async Task ExecuteAsync_CodExpedienteMenos9Chars_RellenaCorrecto()
    {
        // "EXP001" debe tratarse igual que "EXP001   " (padding con espacios)
        var corto  = await _dapper!.ExecuteAsync(1, "EXP001");
        var largo  = await _dapper!.ExecuteAsync(1, "EXP001   ");
        corto.Should().BeEquivalentTo(largo);
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private static string GoldenFilePath(int idConv, string codExpte) =>
        Path.Combine(GoldenDir, $"conv{idConv}_{codExpte.Trim()}.json");

    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        WriteIndented = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    };
}

