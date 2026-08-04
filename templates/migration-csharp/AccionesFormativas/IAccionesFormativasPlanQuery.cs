// =============================================================================
// ProjectName.Reporting/AccionesFormativas/IAccionesFormativasPlanQuery.cs
//
// Contrato de dominio — independiente de la implementación (SP o Dapper)
// =============================================================================

namespace ProjectName.Reporting.AccionesFormativas;

/// <summary>
/// Obtiene el detalle de acciones formativas de un expediente
/// dentro de una convocatoria (Informe 8).
/// </summary>
public interface IAccionesFormativasPlanQuery
{
    /// <param name="idConvocatoria">ID de la convocatoria.</param>
    /// <param name="codExpediente">Código de expediente, 9 caracteres (CHAR(9) en BD).</param>
    Task<IReadOnlyList<AccionFormativaPlanDto>> ExecuteAsync(
        int idConvocatoria,
        string codExpediente,
        CancellationToken ct = default);
}

