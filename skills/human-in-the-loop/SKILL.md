---
name: 'Human-in-the-Loop — Compuerta de Decisión Humana'
description: 'Define qué acciones requieren aprobación humana explícita antes de proceder y qué pueden ejecutar los agentes de forma autónoma'
---

# Human-in-the-Loop (HITL)

## Principio

Los agentes de Boost DBA **analizan, recomiendan y preparan**. Las decisiones de alto impacto, irreversibles o con riesgo para el negocio **siempre las toma un humano**. Un agente nunca debe ejecutar una acción de alto impacto sin confirmación explícita.

---

## Mapa de Autonomía

### 🟢 Autónomo — El agente puede proceder sin confirmación

| Acción | Justificación |
|--------|---------------|
| Leer, consultar, analizar | Solo lectura, sin efecto en el sistema |
| Generar documentación | No modifica nada |
| Proponer recomendaciones | Es una sugerencia, no una acción |
| Crear scripts (sin ejecutar) | El humano decide si y cuándo ejecutar |
| Construir baseline y métricas | Solo lectura |
| Generar datos de prueba sintéticos | Entorno de prueba, reversible |
| Detectar anomalías y alertas | Diagnóstico, no intervención |

---

### 🟡 Requiere Confirmación — El agente para y espera aprobación

| Acción | Por qué detener |
|--------|----------------|
| Ejecutar script de mantenimiento (REBUILD, UPDATE STATS) | Impacta rendimiento durante ejecución |
| Aplicar cambio de configuración en staging | Puede afectar otros equipos |
| Exportar o compartir resultados fuera del entorno | Riesgo de exfiltración |
| Generar script de migración para ejecutar | Cambio de schema, revisar antes |
| Anonimizar datos de producción | Proceso irreversible sobre datos reales |

**Protocolo:**
```
PAUSA — Acción que requiere confirmación humana

Acción propuesta: [descripción exacta]
Impacto estimado: [qué cambia, qué afecta, cuánto tiempo]
Riesgo: MEDIO
Rollback disponible: SÍ / NO

¿Confirmas que quieres proceder? (sí / no / ver más detalles)
```

---

### 🔴 Bloqueado — El agente NO puede ejecutar bajo ningún concepto

| Acción | Motivo |
|--------|--------|
| DROP TABLE / DROP DATABASE | Irreversible sin backup previo confirmado |
| DELETE masivo sin WHERE acotado | Pérdida de datos potencialmente total |
| Modificar usuarios o permisos en producción | Riesgo de seguridad |
| Ejecutar failover | Impacto operativo inmediato |
| Ejecutar cualquier script directamente en producción | Producción es intocable sin ventana aprobada |
| Compartir SQL de negocio o esquema real externamente | Violación de privacidad |
| Deshabilitar backups o monitorización | Elimina red de seguridad |

**Respuesta del agente ante acción bloqueada:**
```
🔴 ACCIÓN BLOQUEADA

Esta acción está fuera del scope autónomo de Boost DBA.

Motivo: [explicación]
Alternativa: [qué puede hacer el agente en su lugar]

Para ejecutar esta acción: hazlo manualmente con la información
y el script que he preparado, previa validación en staging.
```

---

## Cómo los Agentes Señalan las Compuertas

Cada recomendación de acción debe incluir su nivel de autonomía:

```
RECOMENDACIÓN: Rebuild del índice IX_Pedidos_FechaCreacion
AUTONOMÍA: 🟡 REQUIERE CONFIRMACIÓN
IMPACTO: 5-10 minutos de mayor IO durante rebuild (online)
ROLLBACK: No aplica (rebuild no tiene rollback, índice vuelve a estado anterior si falla)
SCRIPT PREPARADO: [incluir script listo para copiar-pegar]
```

---

## Cuándo el Agente Debe Escalar al Humano

Además de las acciones bloqueadas, escalar siempre que:

1. **Hay ambigüedad** en el objetivo del negocio que el agente no puede resolver solo
2. **El riesgo calculado es ALTO o CRÍTICO** aunque la acción sea técnicamente posible
3. **Hay conflicto entre recomendaciones** de distintos agentes
4. **El contexto de negocio es desconocido** y necesario para decidir correctamente
5. **Los datos analizados son inconsistentes** o sugieren un problema mayor no diagnosticado

En esos casos, el agente produce:
```
⚠️ ESCALADO A REVISIÓN HUMANA

No puedo recomendar con suficiente confianza sin más contexto.

Lo que sé: [hallazgos objetivos]
Lo que necesito saber: [pregunta concreta al humano]
Opciones disponibles: [A] / [B] / [C]
Mi hipótesis preferida: [X] — pero requiere tu validación
```
