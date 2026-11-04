---
id: F009
type: feature
status: draft
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0004, D0005], spike: }
updated: 2026-11-03
---

# Plan: feature 009

## Árbol de escenas

Sin nodos nuevos. En `game/entities/player/player.tscn` cambian los cuadros del `AnimatedSprite2D` y el tamaño del `CollisionShape2D`.

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/player/player_movement_config.gd` | Resource | Agrega `roll_min_speed_fraction` y `roll_time` |
| `game/systems/player/player_motor.gd` | Lógica pura | Estado `ROLL`: decide cuándo rueda y conserva la velocidad |
| `game/systems/player/player_animation.gd` | Lógica pura | `ROLL` muestra `rodar`, que dura `roll_time` |
| `game/entities/player/player.gd` | Nodo | Nombre del estado para el overlay |
| `game/art/elyon/elyon.png`, `elyon_frames.tres` | Arte | Las 10 animaciones; reemplazan a `elyon_99.*` |
| `game/data/player_movement.tres` | Resource | `run_speed` en 215 |

**Rodar es un estado del motor y no una condición de la animación.** El bloqueo contra la pared de F008 solo cambia lo que se ve. Rodar cambia las reglas: conserva la velocidad en vez de frenar. Se descartó reutilizar `LAND` con una bandera, como en la copia de prueba, porque la animación y el motor podían decidir distinto.

**La imagen conserva solo los cuadros en uso.** La de la copia tenía 40 cuadros y usaba 33. Se recorta sin retocar los dibujos, y los archivos pierden el "99" porque ya no es el tamaño.

**`roll_min_speed_fraction` y `roll_time` no se escriben en `player_movement.tres`.** Si un `.tres` no guarda una propiedad, Godot usa el valor por defecto del script. Aparecen en el inspector y el desarrollador puede cambiarlos.

## Señales

Ninguna.

## Qué se testea con gdUnit4

- F009-AC01: `test_f009_ac01_hard_landing_with_speed_rolls`, `test_f009_ac01_rolls_only_from_threshold`, `test_f009_ac01_real_fall_while_running_rolls`
- F009-AC02: `test_f009_ac02_roll_keeps_speed_and_ignores_direction`
- F009-AC03: `test_f009_ac03_slow_or_backward_landing_recovers`, `test_f009_ac03_roll_time_zero_never_rolls`
- F009-AC04: `test_f009_ac04_control_returns_after_roll`
- F009-AC05: `test_f009_ac05_roll_shows_rodar_for_roll_time`, `test_f009_ac05_recovery_always_shows_aterrizar`
- F009-AC06: `test_f009_ac06_frames_have_every_animation`

## Impacto en overlay debug

La línea `estado` suma el valor "rodar". El timer de estado muestra lo que le queda.

## Riesgos

- El arte no está publicado en `assets/final/` de `cw2d-art`: la imagen sale de la copia de prueba, respaldada en `~/cw2d_prueba_respaldo_2026-11-03`.
- `test_f004_ac16` cae con velocidad y ahora rodaría: desactiva rodar con `roll_time` en 0 para seguir probando la recuperación.
- Hasta mergear el PR de D0005, `architecture.md` de esta branch sigue diciendo 99 px.
