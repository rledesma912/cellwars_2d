---
id: F004
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0002, D0003], spike: S001 }
updated: 2026-10-25
---

# Playtest: feature 004

## Preparación (escena, overlay F3)

**Para jugar**
- Abrí el proyecto en Godot con la branch `feat/004-movimiento-del-soldado`.
- Ejecutá el juego completo con **F5** y tocá **Jugar**.
- Abrí abajo el panel **Salida** del editor, para ver errores (rojo) y advertencias (amarillo).

**Controles**

| Acción | Teclado | Gamepad |
|---|---|---|
| Correr | A/D o flechas | Cruceta o stick izquierdo |
| Saltar | Espacio o K | Botón A |
| Pausa | Esc | Start |
| Panel de debug | F3 | Select/Back |

- Salto más alto: mantené el botón apretado.
- Salto corto: dale un toque.

**Panel F3:** muestra FPS, velocidad, "en el piso", estado, mira, timer estado, y coyote / buffer.

**Tuning:** `game/data/player_movement.tres` (doble clic, y se abre en el inspector). Los parámetros están agrupados en Suelo, Salto, Aire, Aterrizaje y Ayudas.

**Recorrido de la sala de prueba**
1. Entrada a la izquierda, en el piso 1.
2. Saltá el precipicio.
3. Subí los dos escalones de la derecha.
4. En el piso 2, andá hacia la izquierda.
5. Subí los dos escalones de ese lado.
6. En el piso 3, andá hacia la derecha hasta la salida.

## Checklist [manual]

- [X] **F004-AC20:** tocá Jugar.
  - Esperado: en el inicio aparece Elyon animado (48 px, mochila y manguera), parado sobre el piso, sin flotar ni hundirse, mirando a la derecha y con la animación de quieto.
  - Corré a la izquierda. Esperado: se ve espejado.
  - Overlay: `mira` cambia entre derecha e izquierda.
- [X] **F004-AC21:** desde la entrada, llegá a la salida solo corriendo y saltando.
  - Esperado: se puede, sin trabarse en techos ni escalones.
  - El precipicio se salta corriendo.
  - Al saltar desde el piso, la cabeza llega justo al techo.
- [X] **F004-AC22:** probá lo que ya hacía la F003.
  - Caé por el precipicio. Esperado: reaparece en el inicio, quieto y mirando a la derecha.
  - Hacé lo mismo saliendo por la entrada y por la salida. Esperado: lo mismo.
  - Pausá a mitad de una preparación del salto y de una recuperación (caé del piso 2 al piso 1). Esperado: queda congelado.
  - Tocá Continuar. Esperado: sigue desde donde estaba.
  - Overlay: `estado` reaparece en "quieto" y `mira` en "derecha".
- [X] **F004-AC23:** apretá F3 y movete.
  - Esperado: `estado` pasa por quieto, correr, frenar, girar, preparar salto, en el aire y recuperarse.
  - `timer estado` baja durante el giro, la preparación y la recuperación.
  - `coyote / buffer` se carga al pisar el vacío y al apretar salto en el aire.
- [X] **F004-AC24:** cerrá el juego y cambiá en `player_movement.tres` `jump_prep_time` a 0,2 y `turn_time` a 0,25. Volvé a jugar.
  - Esperado: la preparación y el giro duran claramente más, y su animación se estira para durar lo mismo.
  - Después dejá los valores que prefieras.

## Checklist [feel]

<!-- Solo lo marca el desarrollador. -->

- [X] **F004-AC25:** ¿el soldado se siente con peso y compromiso, pero responde, como el que elegiste en el spike 001? (anotar sensación y valor probado)
  - Arranque y frenado: `accel_time`, `decel_time`.
  - Peso del salto: `time_to_apex`, `fall_gravity_scale`.
  - Control en el aire: `air_control`.
  - Ayudas: `coyote_time`, `jump_buffer_time`.
- [X] **F004-AC26:** ¿se ven la preparación del salto, el giro y la recuperación sin que parezca que el control se trabó? (anotar sensación y valor probado)
  - Tiempos: `jump_prep_time`, `turn_time`, `land_recovery_time`.
  - Desde qué altura hay recuperación: `hard_landing_height`.

## Notas del playtest
