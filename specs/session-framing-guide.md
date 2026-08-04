---
name: 'Guía de Encuadre de Sesión DBA'
description: 'Cómo iniciar una sesión con Boost DBA para obtener análisis enfocados, precisos y sin pérdida de contexto'
---

# Guía de Encuadre de Sesión DBA

## Por Qué Importa el Encuadre

Un agente DBA sin contexto suficiente puede:
- Hacer recomendaciones genéricas en lugar de específicas a tu sistema
- Perder el hilo entre preguntas si el alcance no está claro
- Mezclar hallazgos de análisis distintos y confundir al equipo

Esta guía te ayuda a arrancar cada sesión con el contexto correcto para obtener el máximo valor.

---

## Plantilla de Encuadre de Sesión

Copia y rellena esto al inicio de cada sesión con Boost DBA:

```
PROYECTO: [nombre del proyecto o sistema]
PLATAFORMA: [SQL Server 20XX / Azure SQL Standard|Premium / AWS RDS / PostgreSQL XX]
ENTORNO: [producción / staging / desarrollo]
FUENTE DE VERDAD: [dba_NombreProyecto/ o "aún no inicializada"]

OBJETIVO DE ESTA SESIÓN:
[Una frase clara: "Quiero encontrar el cuello de botella de las consultas de facturación"
 o "Necesito saber el impacto de añadir una columna a la tabla Pedidos"
 o "Quiero un plan de modernización para los SPs del módulo de RRHH"]

CONTEXTO DE NEGOCIO RELEVANTE:
[Lo que el agente necesita saber para no recomendar cosas inapropiadas:
 "Es un sistema de nóminas, los datos son especialmente sensibles"
 "Hay una ventana de mantenimiento los domingos de 2am a 6am"
 "La tabla Clientes tiene 80M de filas y crece 500K/mes"]

LO QUE YA SÉ / LO QUE NO QUIERO REPETIR:
[Si venimos de una sesión anterior o hay contexto previo:
 "Ya analizamos dependencias en la sesión anterior, centrarse en rendimiento"
 "Sabemos que sp_CierresMes es el más crítico"]

RESTRICCIONES:
[Límites que el agente debe respetar:
 "No podemos tocar producción hasta el próximo sprint"
 "Solo tenemos acceso de lectura"
 "El presupuesto de mantenimiento es limitado, priorizar quick wins"]
```

---

## Modos de Sesión

Elige uno al inicio para que el agente ajuste su foco:

### 🔍 Modo Diagnóstico
> Objetivo: entender qué está pasando, sin tomar decisiones todavía.

El agente: observa, mide, describe y plantea hipótesis.
No hace: recomendaciones de cambio hasta que el diagnóstico esté completo.

```
"Entra en modo diagnóstico. Quiero entender [síntoma] antes de decidir nada."
```

---

### 🎯 Modo Recomendación
> Objetivo: obtener acciones concretas y priorizadas con evidencia.

El agente: propone cambios con evidencia, impacto y rollback.
Requiere: diagnóstico previo o datos suficientes en la fuente de verdad.

```
"Tenemos el diagnóstico. Dame las 3 acciones más impactantes con menor riesgo."
```

---

### 📋 Modo Planificación
> Objetivo: crear un roadmap o plan de trabajo estructurado.

El agente: organiza hallazgos en fases, estima esfuerzo y define criterios de éxito.
No decide: qué hacer, sino cómo ordenar lo que ya se ha decidido hacer.

```
"Con lo que sabemos, crea un plan de 90 días ordenado por impacto y riesgo."
```

---

### 🔄 Modo Revisión
> Objetivo: revisar el estado de un plan o cambio anterior.

El agente: contrasta el estado actual con lo planeado, identifica desviaciones.

```
"Revisa el estado del plan de mantenimiento de índices que definimos hace 2 semanas."
```

---

## Señales de que la Sesión Está Perdiendo el Foco

Si el agente empieza a:
- Dar recomendaciones genéricas sin citar datos concretos de tu sistema
- Mezclar análisis de distintos módulos o tablas sin distinción
- Repetir información ya discutida
- Hacer suposiciones sobre el negocio sin preguntarte

**Para y reencuadra con:**
```
"Para. Recuerda que estamos en [modo] para [objetivo].
 El contexto relevante es [recordatorio].
 Vuelve a centrarte en [pregunta concreta]."
```

---

## Cómo Cerrar una Sesión Correctamente

Al finalizar, pide siempre:

```
"Cierra la sesión con:
 1. Resumen de hallazgos clave (máximo 5 puntos)
 2. Decisiones tomadas y pendientes de humano
 3. Próximos pasos concretos con responsable
 4. Qué actualizar en la fuente de verdad"
```

Esto evita que el contexto se pierda entre sesiones y mantiene la fuente de verdad actualizada.

---

## Errores Comunes de Encuadre

| Error | Consecuencia | Solución |
|-------|-------------|----------|
| "Analiza mi base de datos" sin más | El agente hace análisis genérico sin foco | Especifica módulo, síntoma y objetivo |
| Cambiar de tema a mitad de sesión | El agente pierde el hilo y mezcla contextos | Un tema por sesión, o cierra y reabre |
| No indicar la plataforma | El agente puede recomendar features que no existen en tu versión | Indicar siempre motor y versión |
| Pedir recomendaciones sin diagnóstico | El agente inventa hallazgos para justificar recomendaciones | Diagnóstico primero, recomendación después |
| No decir qué no se puede tocar | El agente puede proponer cambios en producción sin ventana | Declarar restricciones al inicio |
