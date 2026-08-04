// =============================================================================
// ProjectName.Reporting/AccionesFormativas/Acl/SpAccionesFormativasPlanQuery.cs
//
// ANTI-CORRUPTION LAYER — Llama al SP original sin lógica nueva.
// Esta clase es TEMPORAL. Se elimina cuando DapperAccionesFormativasPlanQuery
// pase el 100% de los tests de regresión en producción.
//
// Strangler Fig — Fase 1 de 3
// =============================================================================

using System.Data;
using Dapper;

namespace ProjectName.Reporting.AccionesFormativas.Acl;

/// <summary>
/// Implementación ACL: delega directamente a bi.AccionesFormativasPlanFormacion_S.
/// No contiene lógica de negocio. Solo traducción de tipos y llamada al SP.
/// </summary>
internal sealed class SpAccionesFormativasPlanQuery : IAccionesFormativasPlanQuery
{
    private readonly IDbConnection _db;

    public SpAccionesFormativasPlanQuery(IDbConnection db)
    {
        _db = db;
    }

    public async Task<IReadOnlyList<AccionFormativaPlanDto>> ExecuteAsync(
        int idConvocatoria,
        string codExpediente,
        CancellationToken ct = default)
    {
        // CHAR(9) en BD — padear con espacios si viene corto
        var expte = codExpediente.PadRight(9).Substring(0, 9);

        var result = await _db.QueryAsync<AccionFormativaPlanDto>(
            "bi.AccionesFormativasPlanFormacion_S",
            new
            {
                ID_CONVOCATORIA = idConvocatoria,
                D_COD_EXPTE     = expte,
            },
            commandType: CommandType.StoredProcedure);

        return result.ToList();
    }
}

