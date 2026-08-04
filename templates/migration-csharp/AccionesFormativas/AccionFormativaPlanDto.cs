// =============================================================================
// ProjectName.Reporting/AccionesFormativas/AccionFormativaPlanDto.cs
//
// DTO generado desde bi.AccionesFormativasPlanFormacion_S
// Autor SP original: Oscar Quero (12/05/2011)
// Migrado: 2026-06-07
// =============================================================================

namespace ProjectName.Reporting.AccionesFormativas;

/// <summary>
/// Informe 8: Informe de AAFF en planes presentados (detalle).
/// Contiene los datos de cada acción formativa asociada a un expediente
/// dentro de una convocatoria.
/// </summary>
public sealed record AccionFormativaPlanDto
{
    // --- Plan de Formación ---
    public string? TipoPlan { get; init; }           // TP.D_TIPOPLAN
    public string? CodExpediente { get; init; }      // P.D_COD_EXPEDIENTE
    public string? Agrupacion { get; init; }         // A.D_AGRUPACION
    public string? SituacionGestion { get; init; }   // ES.D_ESTADO

    // --- Entidad ---
    public string? RazonSocial { get; init; }        // E.D_RAZONSOCIAL

    // --- Sector ---
    public int IdSector { get; init; }               // PS.ID_SECTOR
    public string? Sector { get; init; }             // S.D_SECTOR

    // --- Acción Formativa ---
    public int Ordinal { get; init; }                // AF.N_ORDINAL
    public string? Denominacion { get; init; }       // AF.D_DENOMINACION
    public int? IdModDist { get; init; }             // AF.ID_MODDIST
    public int? IdModPres { get; init; }             // AF.ID_MODPRES
    public int? IdModTele { get; init; }             // AF.ID_MODTELE
    public int? IdPlanRefAf { get; init; }           // AF.ID_PLANREF_AF
    public int NumParticipantes { get; init; }       // AF.N_PARTICIPANTES

    // --- Titulación ---
    public string? NombreTitulacion { get; init; }   // TIT.D_NOMBRE_TITULACION
    public string? TipoCompetencia { get; init; }    // TC.D_TIPOCOMPETENCIA
    public string? CodTitulacion { get; init; }      // TIT.D_COD_TITULACION
    public string? Certificado { get; init; }        // TI.D_CERTIFICADO
    public string? Modulo { get; init; }             // TI.D_MODULO
    public string? Unidad { get; init; }             // TI.D_UNIDAD

    // --- Horas ---
    public decimal? HorasPresenciales { get; init; }        // AF.N_HPRESENCIALES
    public decimal? HorasTeleformacion { get; init; }       // AF.N_HTELEFORMACION
    public decimal? HorasTutoriasDistancia { get; init; }   // AF.N_HTUTORIASDIST
    public decimal? HorasTutoriasPresencial { get; init; }  // AF.N_HTUTORIASPRES
    public decimal? HorasPracTutoriaPresencial { get; init; } // AF.N_HPRACTUTORIAPRES
    public decimal? HorasPracTutoriaDistancia { get; init; }  // AF.N_HPRACTUTORIADIST
    public decimal? HorasPracTeleformacion { get; init; }   // AF.N_HPRACTELEFORMACION

    // --- Importes ---
    public decimal? AyudaMaxima { get; init; }          // AF.N_AYUDAMODULO
    public decimal? AyudaSolicitada { get; init; }      // AF.N_AYUDASOLICITADA
    public decimal? CosteHoraParticipante { get; init; } // AF.N_COSTE_HORA_PARTICIPANTE

    // --- Estado de anulación ---
    public bool Anulada { get; init; }               // AF.B_ANULADA
    public string? RazonAnulacion { get; init; }     // ANU.D_ANULACION
}

