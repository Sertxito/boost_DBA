// =============================================================================
// ProjectName.Reporting/AccionesFormativas/AccionesFormativasPlanQueryFactory.cs
//
// Factory con Feature Flag — controla si se usa el ACL (SP) o la impl. Dapper.
// Permite cutover gradual sin redeploy.
// =============================================================================

using Microsoft.FeatureManagement;

namespace ProjectName.Reporting.AccionesFormativas;

/// <summary>
/// Activa o desactiva la implementación Dapper mediante feature flag.
/// Flag: "BiReporting.AccionesFormativasPlan.UseDapper"
///
/// false (default) → SpAccionesFormativasPlanQuery (llama al SP original)
/// true            → DapperAccionesFormativasPlanQuery (sin SP)
/// </summary>
public sealed class AccionesFormativasPlanQueryFactory
{
    private readonly IFeatureManager _features;
    private readonly SpAccionesFormativasPlanQuery _acl;
    private readonly DapperAccionesFormativasPlanQuery _dapper;

    public const string FeatureFlag = "BiReporting.AccionesFormativasPlan.UseDapper";

    public AccionesFormativasPlanQueryFactory(
        IFeatureManager features,
        SpAccionesFormativasPlanQuery acl,
        DapperAccionesFormativasPlanQuery dapper)
    {
        _features = features;
        _acl      = acl;
        _dapper   = dapper;
    }

    public async Task<IAccionesFormativasPlanQuery> CreateAsync()
    {
        return await _features.IsEnabledAsync(FeatureFlag)
            ? _dapper
            : _acl;
    }
}

