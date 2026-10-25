---
id: F004
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0002, D0003], spike: S001 }
updated: 2026-10-25
---

# Plan: feature 004

La base es el motor del prototipo del spike 001 (tag `archive/spike-001`), reescrito con tests. Hay cuatro diferencias con el prototipo:

- **Una sola variante.** No hay nombre de variante ni `air_can_reverse`. "No darse vuelta en el aire" es regla de D0003, no un parámetro.
- **Toque corto exacto (F004-AC07).** Si al terminar la preparación el botón ya está suelto, despega directamente con la velocidad de corte. El prototipo despegaba con la velocidad del salto lleno y cortaba un paso después, por eso subía 3 px de más.
- **La animación se elige en lógica pura.** Elegir la animación según el estado es una regla, así que sale del nodo y pasa a `PlayerAnimation`.
- **Sin mediciones.** Las mediciones del prototipo (último salto, frenada) no se traen.

## Elecciones

Los patrones ya están fijados en `architecture.md` y en D0003, así que no se vuelven a evaluar. Su porqué, corto:

| Elección | Alternativa descartada | Por qué |
|---|---|---|
| Máquina de estados con `enum` dentro de `PlayerMotor` | Un nodo por estado (`State` hijos de una `StateMachine`) | Son 7 estados con poca lógica de entrada y salida. Con nodos, el motor dejaría de ser lógica pura y no se podría testear sin escenas. |
| `AnimatedSprite2D` | `AnimationPlayer` o `AnimationTree` | La animación es cuadro por cuadro, como se dibuja el pixel art, y no hay que mover nada más en sincronía. `AnimationPlayer` se suma cuando haya hitboxes o sonidos atados a cuadros. |
| La velocidad de la animación se calcula en `PlayerAnimation` y el nodo la pasa a `play(anim, speed)` | Poner los fps de cada animación a mano para que coincidan con el `.tres` | Si el desarrollador cambia `turn_time`, la animación se ajusta sola. Es la regla "el motor manda los tiempos". |
| El motor expone su estado como campos de solo lectura (`state`, `facing`, timers) | Señales `jumped` o `landed` | Por ahora nadie más que el propio personaje necesita enterarse. Las señales se suman cuando otro sistema escuche (sonido, polvo, cámara). |
| Las imágenes se cortan con `SpriteFrames` y una `AtlasTexture` por cuadro, en un `.tres` | Un `SpriteFrames` armado por código al arrancar | Se ve y se edita en el editor de Godot. Es lo mismo que funcionó en el prototipo. |

## Árbol de escenas

`game/entities/player/player.tscn`:

```
Player (CharacterBody2D)              player.gd; config = game/data/player_movement.tres
├── Sprite (AnimatedSprite2D)         %Sprite; sprite_frames = elyon_48_frames.tres
│                                      centered = false; offset = (-32, -63): pies en el origen
└── Shape (CollisionShape2D)          %Shape; RectangleShape2D 20 × 48, position (0, -24)
```

- El `ColorRect` del greybox se va.
- `World` y la sala de prueba no cambian de estructura.

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/player/player_movement_config.gd` | Resource | Suma los parámetros nuevos de la spec, agrupados (`@export_group`): Suelo, Salto, Aire, Aterrizaje, Ayudas. También los valores derivados: `get_gravity`, `get_fall_gravity`, `get_jump_velocity`, `get_release_velocity`, `get_accel_rate`, `get_decel_rate`. Los valores por defecto del script pasan a ser los de la spec. |
| `game/systems/player/player_input.gd` | lógica pura | Suma `jump_held` (botón sostenido) a `direction` y `jump_just_pressed`. |
| `game/systems/player/player_motor.gd` | lógica pura | Reemplaza el motor de la F003. Tiene el `enum State { IDLE, RUN, BRAKE, TURN, JUMP_PREP, AIR, LAND }` y `step(velocity, input, on_floor, delta) -> Vector2`. Expone `state`, `facing`, `get_state_timer()`, `get_coyote()`, `get_buffer()` y `reset()`. |
| `game/systems/player/player_animation.gd` | lógica pura | Funciones estáticas: `pick(state, velocity, run_speed) -> StringName` (AC18) y `speed_for(frame_count, fps, duration) -> float` (AC19). |
| `game/entities/player/player.gd` | nodo | Lee el input (con `is_action_pressed("jump")` para sostenido) y llama a `step` y a `move_and_slide`. Después pide la animación a `PlayerAnimation` y la reproduce con `flip_h` según `facing`. `reset_to` también reinicia el motor. Suma líneas a `get_debug_info`. |
| `game/art/elyon/elyon_48.png` | arte | La tira de 21 cuadros de 64 × 64 del spike, provisoria. |
| `game/art/elyon/elyon_48_frames.tres` | Resource (`SpriteFrames`) | Las 9 animaciones, con sus fps y loop, apuntando a la tira nueva. |
| `game/data/player_movement.tres` | Resource (tuning) | Cambio único autorizado en la spec: los valores iniciales de la tabla. |

`World`, `RoomGeometry`, `DebugOverlay` y la sala de prueba no cambian.

## Señales

Ninguna nueva. Ver "Elecciones".

## Qué se testea con gdUnit4

Archivos:
- `test/player/player_motor_test.gd`: se reescribe; los tests de la F003 que el motor nuevo contradice se van, y quedan en git.
- `test/player/player_movement_config_test.gd`: se actualiza.
- `test/player/player_animation_test.gd`: nuevo.

| Criterio | Test |
|---|---|
| F004-AC01 | `test_f004_ac01_accelerates_to_run_speed_in_accel_time` |
| F004-AC02 | `test_f004_ac02_brakes_to_zero_in_decel_time` |
| F004-AC03 | `test_f004_ac03_turns_in_place_after_turn_time` |
| F004-AC04 | `test_f004_ac04_running_turn_brakes_first` |
| F004-AC05 | `test_f004_ac05_jump_prep_keeps_momentum_and_ignores_input` |
| F004-AC06 | `test_f004_ac06_held_jump_reaches_jump_height` |
| F004-AC07 | `test_f004_ac07_tap_reaches_min_jump_height` |
| F004-AC08 | `test_f004_ac08_mid_release_height_between_min_and_max` |
| F004-AC09 | `test_f004_ac09_fall_gravity_scaled_and_capped` |
| F004-AC10 | `test_f004_ac10_no_double_jump` |
| F004-AC11 | `test_f004_ac11_held_jump_does_not_repeat_on_landing` |
| F004-AC12 | `test_f004_ac12_coyote_time_allows_late_jump` / `test_f004_ac12_coyote_time_expires` |
| F004-AC13 | `test_f004_ac13_jump_buffer_starts_prep_on_landing` / `test_f004_ac13_jump_buffer_expires` |
| F004-AC14 | `test_f004_ac14_air_control_reduced_and_no_reverse` |
| F004-AC15 | `test_f004_ac15_soft_landing_responds_immediately` |
| F004-AC16 | `test_f004_ac16_hard_landing_recovers_without_control` |
| F004-AC17 | `test_f004_ac17_derived_values` (en `player_movement_config_test.gd`) |
| F004-AC18 | `test_f004_ac18_animation_for_each_state` (en `player_animation_test.gd`) |
| F004-AC19 | `test_f004_ac19_speed_stretches_animation_to_duration` (en `player_animation_test.gd`) |

Los casos límite de la spec también llevan test, sin ID de criterio:
- salto durante el giro o la recuperación;
- borde durante la preparación;
- sin coyote después de saltar;
- izquierda y derecha juntas;
- reinicio.

Las alturas se miden como en la F003: un helper simula pasos de 1/60 s (`pos += v·dt` después de cada `step`) con un piso falso en y = 0.

## Impacto en overlay debug

`Player.get_debug_info()` suma estas líneas a las de velocidad y piso:

- `estado`: el nombre en castellano (quieto, correr, frenar, girar, preparar salto, en el aire, recuperarse);
- `mira`: derecha o izquierda;
- `timer estado`: segundos que le quedan al giro, la preparación o la recuperación;
- `coyote / buffer`: segundos restantes de cada uno.

## Riesgos

- **Cabeza contra el techo.** 48 + 52 = 100 px: el salto lleno toca justo el techo de cada piso. Si `move_and_slide` lo detecta como choque un paso antes, el salto mide un poco menos. No cambia los criterios, que se miden en lógica pura, pero conviene mirarlo en la simulación de la sala (T7).
- **Bordes de escalón.** En las esquinas, `is_on_floor()` puede dar falso un paso suelto. El motor lo tomaría como "caminó al vacío" y el coyote time lo absorbe. Si aparece un parpadeo de animación (`caer` por un cuadro), se mira en el playtest.
- **Arte provisorio.** Los cuadros varían un poco de diseño entre sí. Es aceptado (spec, "Arte provisorio") y no es motivo para retocarlos en esta feature.
- **Tests de la F003.** Tres de sus tests de motor (caminar en seco, salto inmediato, gravedad sin escala) describen el comportamiento viejo y se reemplazan. La spec de la F003 no se toca: es el registro de lo que se construyó.
