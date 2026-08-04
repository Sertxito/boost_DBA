# Especificaciones (specs)

Esta carpeta contiene las instrucciones transversales y obligatorias para todos los agentes y skills de Boost DBA.

## Que hay en specs

- [agent-behavioral-spec.md](agent-behavioral-spec.md): reglas anti-alucinacion, evidencia, confianza, limites y escalado HITL.
- [session-framing-guide.md](session-framing-guide.md): plantilla y modos para encuadrar sesiones con foco y continuidad.

## Encaje con patterns y references

Los tres bloques no compiten, se complementan:

- specs = como pensar y decidir
- patterns = que detectar (catalogo de anti-patrones)
- references = con que contrastar (fuente oficial por plataforma)

Flujo operativo recomendado:

1. Encuadrar sesion con `session-framing-guide.md`.
2. Analizar artefactos SQL y detectar hallazgos apoyandose en `patterns/`.
3. Validar recomendaciones contra `references/official-docs.md`.
4. Emitir salida con formato y compuertas de `agent-behavioral-spec.md`.

## Regla de prioridad

Si hay conflicto entre una recomendacion puntual y una regla de comportamiento:

1. Prevalece `agent-behavioral-spec.md`.
2. Luego prevalece `session-framing-guide.md` para no perder foco.
3. `patterns/` y `references/` se usan como evidencia y contraste tecnico.

## Checklist minimo por salida

- Evidencia tecnica explicita (query/resultado/artefacto)
- Nivel de confianza (ALTA/MEDIA/BAJA/SIN DATOS)
- Impacto y rollback
- Cita de fuente oficial cuando aplique version/tier/plataforma
