// =============================================================================
// ProjectName.Reporting/DependencyInjection.cs
//
// Registro del módulo de Reporting en el contenedor de DI.
// =============================================================================

using Microsoft.Extensions.DependencyInjection;
using Microsoft.FeatureManagement;
using ProjectName.Reporting.AccionesFormativas;
using ProjectName.Reporting.AccionesFormativas.Acl;

namespace ProjectName.Reporting;

public static class DependencyInjection
{
    public static IServiceCollection AddReportingModule(
        this IServiceCollection services,
        string connectionString)
    {
        // Conexión SQL
        services.AddScoped<System.Data.IDbConnection>(_ =>
            new Microsoft.Data.SqlClient.SqlConnection(connectionString));

        // AccionesFormativasPlan: ACL + Dapper + Factory
        services.AddScoped<SpAccionesFormativasPlanQuery>();
        services.AddScoped<DapperAccionesFormativasPlanQuery>();
        services.AddScoped<AccionesFormativasPlanQueryFactory>();

        // La interfaz se resuelve via factory (feature flag decide)
        services.AddScoped<IAccionesFormativasPlanQuery>(sp =>
        {
            var factory = sp.GetRequiredService<AccionesFormativasPlanQueryFactory>();
            return factory.CreateAsync().GetAwaiter().GetResult();
        });

        // Feature management (necesario para los flags)
        services.AddFeatureManagement();

        return services;
    }
}

