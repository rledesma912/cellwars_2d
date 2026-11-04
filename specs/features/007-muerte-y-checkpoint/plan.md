---
id: F007
type: feature
status: draft
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0005], spike: }
updated: 2026-11-04
---

# Plan: feature 007

## Árbol de escenas

Escena nueva, `game/entities/mortal_zone/mortal_zone.tscn`:

```
MortalZone (Area2D, mortal_zone.gd)
└── Shape (CollisionShape2D)    # el rectángulo se crea desde `size`
```

Se instancia dentro de las salas de prueba:

```
TestRoomN (Node2D, room.gd)
├── Background (ColorRect)
├── Tiles (TileMapLayer)
├── Entrance (Marker2D)
├── Exit (Marker2D)
└── MortalZone (instancia)      # nuevo
```

`Player` y `World` no cambian de estructura.

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/player/player_movement_config.gd` | Resource | Grupo "Muerte": `death_time`, `void_restart_time`. El `.tres` no se toca |
| `game/systems/player/player_motor.gd` | Lógica pura | Estado `DEAD` y enum `DeathCause { HAZARD, VOID }`. `die(cause)` entra al estado y elige la duración; `step` lo atiende antes que nada; `is_dead()` e `is_death_finished()` |
| `game/systems/player/player_animation.gd` | Lógica pura | `DEAD` muestra `morir`, que dura `death_time` |
| `game/systems/rooms/level_progress.gd` | Lógica pura | `checkpoint()` da la sala actual, entrada y sin movimiento. `apply(VOID)` deja de reiniciar: el vacío ahora pasa por la muerte |
| `game/entities/player/player.gd` | Nodo | `die(cause)`, `is_dead()`, señal `death_finished`, nombre del estado en el overlay |
| `game/entities/mortal_zone/mortal_zone.gd` | Nodo | Dibuja el rectángulo gris rojizo y avisa a `Player` cuando lo toca |
| `game/world/world.gd` | Nodo | Mientras Elyon está muerto ignora los bordes; el vacío llama a `die(VOID)`; con `death_finished` vuelve al checkpoint |
| `game/art/elyon/elyon.png`, `elyon_frames.tres` | Arte | Animación `morir`: 9 cuadros sin repetición, duraciones relativas que suman 9 |
| `game/levels/test/test_room_{1,2,3}.tscn` | Sala de prueba | Una zona mortal por sala (ver abajo) |

### Decisiones de Godot

- **Estado nuevo en el enum del motor, igual que `ROLL`** (patrón de D0003). Morir cambia las reglas: ignora controles, frena y lleva un tiempo. Descartado: resolverlo en `Player` con un `if`, porque la regla quedaría en un nodo y sin tests.
- **`Area2D` para la zona.** Un `Area2D` detecta que algo lo toca sin frenarlo, y su señal `body_entered` avisa una sola vez al entrar. Descartado: `StaticBody2D`, que además es un obstáculo sólido. También descartado preguntar en cada paso si Elyon se superpone con la zona: es repetir lo que Godot ya hace.
- **Filtro `body is Player`.** Las baldosas y Elyon están en la misma capa de colisión, así que la zona también recibe aviso de las baldosas que toca. Descartado: crear una capa solo para Elyon, porque una sola entidad mortal no lo justifica. Lo revisamos cuando haya enemigos.
- **Señal `death_finished` de `Player` a `World`**, como pide la regla de comunicación entre sistemas. Descartado: que `World` pregunte en cada paso. `Player` la emite una sola vez porque `World` lo reinicia al recibirla, y entonces deja de estar muerto.
- **`@tool` en `mortal_zone.gd`.** Hace correr el script en el editor, y así el rectángulo se ve al colocarlo en una sala. El shape solo se crea en el juego, para que el editor no lo guarde en la sala. Descartado: `ColorRect` más shape a mano en cada sala, porque hay que mantener dos tamaños iguales.
- **El rectángulo se dibuja con `_draw`, sin el material de suavizado.** No es pixel art, es un rectángulo liso de greybox, igual que el fondo de las salas.
- **En el aire mantiene la velocidad horizontal.** AC02 solo pide la caída. Como el aire no tiene rozamiento, no frena, y así el cuerpo sigue la trayectoria que traía.

### Zonas en las salas de prueba

| Sala | Dónde | Medida (baldosas) | Sirve para |
|---|---|---|---|
| 1 | Sobre el piso de abajo, columnas 14–17, antes del hueco | 4 × 1 | AC07: se salta por encima |
| 2 | Colgando sobre la salida de abajo, columnas 50–55, filas 28–29 | 6 × 2 | AC08 y AC10: se camina al hueco por debajo; si se salta hasta tocarla, muere en el aire y cruza la salida muerto |
| 3 | Sobre el piso del medio, columnas 36–39 | 4 × 1 | AC07: se salta por encima |

Todas quedan lejos de las entradas. Las de las salas 1 y 3 también quedan lejos de las salidas; la de la sala 2 está sobre la salida a propósito. Su parte de abajo está 100 px sobre el nivel del piso y el cuerpo mide 82 px, así que Elyon pasa por debajo sin tocarla, también si aparece en la marca `Exit`. Las medidas se confirman jugando (AC12).

## Señales

| Señal | Emisor | Receptor | Payload |
|---|---|---|---|
| `body_entered` (de Godot) | `MortalZone` | la misma `MortalZone` | el cuerpo que entró |
| `death_finished` | `Player` | `World` | ninguno |

## Qué se testea con gdUnit4

`test/player/player_motor_test.gd`

- F007-AC01: `test_f007_ac01_dies_from_every_state`, `test_f007_ac01_ignores_input_until_reset`
- F007-AC02: `test_f007_ac02_brakes_on_floor`, `test_f007_ac02_falls_in_air_up_to_max`
- F007-AC03: `test_f007_ac03_hazard_lasts_death_time`, `test_f007_ac03_void_lasts_void_restart_time`, `test_f007_ac03_zero_time_finishes_on_first_step`
- F007-AC04: `test_f007_ac04_dying_again_keeps_remaining_time`

`test/player/player_animation_test.gd`

- F007-AC05: `test_f007_ac05_dead_shows_morir`, `test_f007_ac05_morir_lasts_death_time`, `test_f007_ac05_morir_durations_sum_frame_count`
- `test_f009_ac06_frames_have_every_animation` pasa de 10 a 11 animaciones.

`test/rooms/level_progress_test.gd`

- F007-AC06: `test_f007_ac06_checkpoint_is_current_room_entrance`, `test_f007_ac06_checkpoint_after_coming_back`
- `test_f006_ac05_change_keeps_motion` cambia: el vacío ya no reinicia en `apply`; se comprueba con `checkpoint()` que vuelve quieto.

## Impacto en overlay debug

Ninguna línea nueva. `estado` muestra "morir" y `timer estado` el tiempo que queda de la muerte.

## Riesgos

- **`_animate` vuelve a arrancar una animación terminada.** Hoy, si la animación actual ya no se reproduce, la inicia de nuevo. `morir` no se repite y dura lo mismo que la muerte, así que por redondeo podría terminar un paso antes y mostrar el primer cuadro. En `morir`, `_animate` no la reinicia y deja el último cuadro.
- **`body_entered` avisa solo al entrar.** Si Elyon reapareciera dentro de una zona, no moriría. AC12 lo evita: las entradas quedan afuera. Una zona pisada mientras está muerto se ignora, y el reinicio lo saca de ella.
- **El ancho de la textura crece** de 4752 a 6048 px. Entra en el límite habitual de 8192, y la laptop lo confirma en el playtest.
- **AC14, justicia de la zona.** El cuerpo de colisión mide 82 px y el dibujo 77 px, así que la cabeza puede tocar una zona 5 px antes de que se vea. Si se nota, se ajusta la zona de la sala 2; no el cuerpo.
- **Cambio en una prueba de F006.** `apply(VOID)` cambia de significado a propósito, porque la spec de F007 lo reemplaza. F006 sigue cumpliéndose, ahora con la espera; se actualiza `INDEX.md` al cerrar.
