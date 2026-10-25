---
id: D0003
type: decision
status: approved
superseded_by:
links: { gdd: [G001], decisions: [D0002], spike: S001 }
updated: 2026-10-25
---

# 0003: Movimiento híbrido y soldado de 48 px

- Origen: spike 001 (movimiento y peso del soldado). Aprobada por el desarrollador el 2026-10-25 ("Apruebo la D0003").

## Contexto

El pilar 1 de la visión pide un control "con peso y compromiso, sin inercia excesiva ni respuestas instantáneas". El movimiento de la F003 arranca y frena en seco, salta 60 px y usa un rectángulo de 26 × 40 px. Antes de diseñar salas, trampas y combate había que fijar el estilo de movimiento, sus valores y el tamaño del soldado.

Restricción: el desarrollador quiere mantener 3 pisos por sala (`D0002`: 100 px de aire por piso), así que cuerpo + salto no pueden pasar de 100 px.

## Opciones consideradas

Estilo (las tres jugadas en el prototipo):

| Opción | Cómo es | Resultado |
|---|---|---|
| A. Moderno con peso | Aceleración corta, control total en el aire, salto variable, coyote time y jump buffer | Responde bien, pero se siente liviano |
| B. Cinemático comprometido | Preparación visible, arco fijo, pasos de arranque y frenado, giro lento, sin ayudas | Mucho peso, pero traba |
| **C. Híbrido** | Base de A con preparación corta, control en el aire reducido sin darse vuelta, recuperación breve al caer de alto | **Elegida**: "el equilibrio de un movimiento moderno y el feeling de peso del soldado" |

Tamaño (Elyon generado en pixel art y jugado en el prototipo):

| Opción | Salto | Resultado |
|---|---|---|
| 40 px | 60 px | "Le falta definición" |
| **48 px** | **52 px** | **Elegida** |
| Más de 48 px | menos de 52 px, o 2 pisos por sala | Descartada: el desarrollador quiere 3 pisos por sala |

## Decisión

- **Movimiento híbrido**, con un motor de lógica pura con estados: quieto, correr, frenar, girar, preparar salto, en el aire y recuperarse.
  - Aceleración y frenado cortos; giro breve estando quieto (frena antes si venía corriendo para el otro lado).
  - Salto variable con preparación corta; coyote time y jump buffer.
  - En el aire corrige a la mitad de la fuerza del piso y no puede darse vuelta.
  - Recuperación breve al caer desde más de 100 px.
- **Soldado de 48 px de alto**, cuerpo de colisión de 20 × 48 px, **salto máximo de 52 px** (cuerpo + salto = 100 px, el aire de un piso).
- **Valores iniciales**: los de `prototypes/spike_001/variant_c48.tres` (detalle en el informe del spike 001). En el juego viven en `game/data/player_movement.tres`, que ajusta el desarrollador.
- **El motor manda los tiempos y la animación se adapta**: cada tiempo de acción (preparación, giro, recuperación) está en el `.tres`, y la animación correspondiente se estira o acorta para durarlo.
- **Animación con `AnimatedSprite2D`**, elegida desde el estado del motor. Cuadros de 64 × 64 px con los pies abajo al centro (32, 63), mirando a la derecha (la izquierda se obtiene espejando).
- Toda acción futura sigue la misma filosofía (anticipación y recuperación cortas, compromiso parcial); su sensación se prueba en su propia feature con criterios `[feel]`.

## Consecuencias (qué se actualiza: GDD, architecture.md, specs)

- `specs/architecture.md`:
  - sección del jugador: motor con estados (enum, lógica pura), regla "el motor manda los tiempos", `AnimatedSprite2D`, cuadros de 64 × 64 con pies en (32, 63);
  - pendientes de render resueltos: 640×360 se mantiene; `snap_2d_transforms_to_pixel` en `true` sin efectos visibles.
- `CLAUDE.md` (tabla Stack): quitar "a validar en Spike 001" de la resolución.
- `specs/gdd/vision.md`: la pregunta abierta sobre el conjunto de movimientos queda respondida en lo básico (correr, saltar, girar, frenar); agacharse, rodar y colgarse siguen abiertas.
- `specs/backlog.md`:
  - quitar el Spike 001;
  - agregar la feature "Movimiento del soldado": reemplazar el motor de la F003 por el híbrido con tests, cuerpo de 20 × 48, valores iniciales de `variant_c48.tres` y la animación provisoria de Elyon en el juego;
  - agregar la nota "salas: con salto de 52 px, escalones de hasta 2 baldosas" para F004 y el mapa del nivel 1;
- `specs/features/003-personaje-simple/spec.md` no cambia (registro de lo construido); la feature nueva reemplaza su movimiento.
