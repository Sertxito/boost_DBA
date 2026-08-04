// =============================================================================
// ProjectName.Reporting/AccionesFormativas/DapperAccionesFormativasPlanQuery.cs
//
// IMPLEMENTACIÓN FINAL — SQL embebido, sin SP.
// Reemplaza bi.AccionesFormativasPlanFormacion_S cuando los tests pasen.
//
// Strangler Fig — Fase 3 de 3
// =============================================================================

using System.Data;
using Dapper;

namespace ProjectName.Reporting.AccionesFormativas;

/// <summary>
/// Implementación Dapper que replica el SQL del SP bi.AccionesFormativasPlanFormacion_S
/// sin depender del stored procedure. Activar via feature flag "BiReporting.UseDapper".
/// </summary>
internal sealed class DapperAccionesFormativasPlanQuery : IAccionesFormativasPlanQuery
{
    // SQL extraído del SP original y formateado para legibilidad.
    // Semánticamente idéntico: mismas tablas, mismo WHERE, mismo ORDER.
    private const string Sql = """
        SELECT
             TP.D_TIPOPLAN                       AS TipoPlan
            ,P.D_COD_EXPEDIENTE                  AS CodExpediente
            ,A.D_AGRUPACION                      AS Agrupacion
            ,ES.D_ESTADO                         AS SituacionGestion
            ,E.D_RAZONSOCIAL                     AS RazonSocial
            ,PS.ID_SECTOR                        AS IdSector
            ,S.D_SECTOR                          AS Sector
            ,AF.N_ORDINAL                        AS Ordinal
            ,AF.D_DENOMINACION                   AS Denominacion
            ,AF.ID_MODDIST                       AS IdModDist
            ,AF.ID_MODPRES                       AS IdModPres
            ,AF.ID_MODTELE                       AS IdModTele
            ,AF.ID_PLANREF_AF                    AS IdPlanRefAf
            ,AF.N_PARTICIPANTES                  AS NumParticipantes
            ,TIT.D_NOMBRE_TITULACION             AS NombreTitulacion
            ,TC.D_TIPOCOMPETENCIA                AS TipoCompetencia
            ,TIT.D_COD_TITULACION                AS CodTitulacion
            ,TI.D_CERTIFICADO                    AS Certificado
            ,TI.D_MODULO                         AS Modulo
            ,TI.D_UNIDAD                         AS Unidad
            ,AF.N_HPRESENCIALES                  AS HorasPresenciales
            ,AF.N_HTELEFORMACION                 AS HorasTeleformacion
            ,AF.N_HTUTORIASDIST                  AS HorasTutoriasDistancia
            ,AF.N_HTUTORIASPRES                  AS HorasTutoriasPresencial
            ,AF.N_HPRACTUTORIAPRES               AS HorasPracTutoriaPresencial
            ,AF.N_HPRACTUTORIADIST               AS HorasPracTutoriaDistancia
            ,AF.N_HPRACTELEFORMACION             AS HorasPracTeleformacion
            ,AF.N_AYUDAMODULO                    AS AyudaMaxima
            ,AF.N_AYUDASOLICITADA                AS AyudaSolicitada
            ,AF.N_COSTE_HORA_PARTICIPANTE        AS CosteHoraParticipante
            ,AF.B_ANULADA                        AS Anulada
            ,ANU.D_ANULACION                     AS RazonAnulacion
        FROM
            T_PLANFORMACION P

            JOIN T_TIPOPLAN TP
                ON  P.ID_TIPOPLAN = TP.ID_TIPOPLAN
                AND TP.B_BAJA = 0

            JOIN T_PLANFORM_SECTOR PS
                ON  P.ID_PLANFORMACION = PS.ID_PLANFORMACION
                AND PS.B_BAJA = 0

            JOIN T_PLANFORM_ENTIDAD PE
                ON  P.ID_PLANFORMACION = PE.ID_PLANFORMACION
                AND PE.B_BAJA = 0

            JOIN T_ENTIDAD E
                ON  PE.ID_ENTIDAD = E.ID_ENTIDAD
                AND PE.B_BAJA = 0

            JOIN T_SECTOR S
                ON  PS.ID_SECTOR = S.ID_SECTOR
                AND S.B_BAJA = 0

            JOIN T_AGRUPACION A
                ON  S.ID_AGRUPACION = A.ID_AGRUPACION
                AND A.B_BAJA = 0

            JOIN TE_ESTADO ES
                ON  P.ID_ESTADO = ES.ID_ESTADO
                AND ES.B_BAJA = 0

            JOIN T_PLANFORM_AF AF
                ON  PS.ID_PLANFORMACION = AF.ID_PLANFORMACION
                AND PS.ID_SECTOR = AF.ID_SECTOR
                AND AF.B_BAJA = 0

            LEFT JOIN T_PLANREFERENCIA_AAFF PRA
                ON  AF.ID_PLANREF_AF = PRA.ID_PLANREF_AF
                AND PRA.B_BAJA = 0

            JOIN (
                SELECT
                     T.ID_TITULACION
                    ,TJ.J_TITULACION
                    ,T.D_COD_FTFE
                    ,T.D_COD_TITULACION
                    ,T.D_NOMBRE_TITULACION
                    ,TR.D_COD_TITULACION AS D_CERTIFICADO
                    ,CASE
                        WHEN T.ID_TIPO_TITULACION = 3 THEN TM.D_COD_TITULACION
                        WHEN T.ID_TIPO_TITULACION = 2 THEN T.D_COD_TITULACION
                     END AS D_MODULO
                    ,CASE
                        WHEN T.ID_TIPO_TITULACION = 3 THEN T.D_COD_TITULACION
                     END AS D_UNIDAD
                FROM TM_TITULACION_JERARQUIA TJ
                    JOIN TM_TITULACION T
                        ON T.ID_TITULACION = TJ.ID_TITULACION
                    LEFT JOIN TM_TITULACION TM
                        ON  TM.ID_TITULACION = TJ.ID_TITULACION_MODULO
                        AND TM.B_BAJA = 0
                    JOIN TM_TITULACION TR
                        ON TR.ID_TITULACION = TJ.ID_TITULACION_RAIZ
                WHERE T.B_BAJA = 0
            ) TI ON PRA.J_TITULACION = TI.J_TITULACION

            LEFT JOIN TM_TITULACION TIT
                ON  TIT.ID_TITULACION = PRA.ID_TITULACION
                AND TIT.B_BAJA = 0

            LEFT JOIN T_PLANFORMAF_CONVANULACION PFA
                ON  AF.ID_PLANFORM_AF = PFA.ID_PLANFORM_AF
                AND PFA.B_BAJA = 0
                AND PFA.ID_CONVOCATORIA = @IdConvocatoria

            LEFT JOIN TM_ANULACION ANU
                ON  PFA.ID_ANULACION = ANU.ID_ANULACION
                AND ANU.B_BAJA = 0

            LEFT JOIN TE_TIPOCOMPETENCIA TC
                ON  PRA.ID_TIPOCOMPETENCIA = TC.ID_TIPOCOMPETENCIA
                AND TC.B_BAJA = 0

        WHERE
            P.B_BAJA = 0
            AND P.D_COD_EXPEDIENTE = @CodExpediente
            AND TP.ID_CONVOCATORIA = @IdConvocatoria
            AND PE.B_SOLICITANTE = 1
        """;

    private readonly IDbConnection _db;

    public DapperAccionesFormativasPlanQuery(IDbConnection db)
    {
        _db = db;
    }

    public async Task<IReadOnlyList<AccionFormativaPlanDto>> ExecuteAsync(
        int idConvocatoria,
        string codExpediente,
        CancellationToken ct = default)
    {
        // CHAR(9) en BD original — conservar el mismo comportamiento
        var expte = codExpediente.PadRight(9).Substring(0, 9);

        var result = await _db.QueryAsync<AccionFormativaPlanDto>(
            Sql,
            new
            {
                IdConvocatoria = idConvocatoria,
                CodExpediente  = expte,
            });

        return result.ToList();
    }
}

