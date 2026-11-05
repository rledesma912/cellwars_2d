---
id: F010
type: feature
status: draft
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0005], spike: }
updated: 2026-11-04
---

# Plan: feature 010

## Árbol de escenas

Sin nodos nuevos. Cambian el recurso de animaciones y una sala de prueba:

```
World (Node2D)
├── Room (sala actual)              # una sala de prueba suma la caída de dos pisos (AC11)
└── Player (CharacterBody2D)
    ├── Shape (CollisionShape2D)
    └── Sprite (AnimatedSprite2D)   # elyon_frames.tres suma caer_largo y morir_caida
```

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/player/player_movement_config.gd` | Resource | Suma `long_fall_height` (260) y `lethal_fall_height` (420) al grupo "Aterrizaje" |
| `game/systems/player/player_motor.gd` | Lógica pura | Decide la muerte por altura al aterrizar, clasifica la caída y deja de contarla al morir |
| `game/systems/player/player_animation.gd` | Lógica pura | Elige `caer_largo` y `morir_caida`, y dice qué animaciones se quedan en su último cuadro |
| `game/entities/player/player.gd` | Nodo | Le pasa a `pick` la gravedad de la caída y si está en el piso, y expone la línea `caída` |
| `game/art/elyon/elyon.png`, `elyon_frames.tres` | Arte | Reemplaza los 9 cuadros de `morir` y suma los 6 cuadros nuevos: la tira pasa de 6048 a 6912 px de ancho |
| `game/levels/test/` | Sala de prueba | Caída de dos pisos sobre piso común, a la que se llega desde los dos lados |

`player_movement.tres` no se toca. Los valores nuevos son los defaults del script, y el editor los muestra igual en el inspector, como ya pasa con `roll_time`.

### Decisiones de diseño

**La muerte por altura es una causa nueva, `DeathCause.FALL`, decidida en `_land()`.**
Descarté que `Player` mirara la altura y llamara a `die()`: sería una regla de juego en un nodo. `_land()` ya decide entre seguir, rodar o recuperarse, y este es un caso más. `FALL` usa `death_time`, igual que `HAZARD`, pero queda separada porque es otra causa y deja el código más claro. Al morir así, `_alive()` tiene que pasar a `_dead()` en ese mismo paso; hoy caería en `_air()`.

**El motor clasifica la caída en un enum (`FallSeverity`: `NORMAL`, `LONG`, `LETHAL`), y `pick` recibe ese valor.**
Descarté pasarle a `pick` la distancia y los dos límites, porque las reglas de altura quedarían repartidas entre dos clases. Los parámetros nuevos de `pick` tienen valores por defecto, así que los tests actuales siguen valiendo.

**La altura se congela al morir.** `_dead()` no suma distancia.
La alternativa era seguir contando, pero Elyon podría morir por una zona con menos de 420 px, empezar `morir` en el aire y saltar a `caer_largo` al pasar los 420, cortando la animación. Congelada, la animación queda definida en el momento de morir, como pide el caso límite de la spec. En el pozo no cambia nada: los pies tocan la zona a los 460 px y la muerte ya cuenta como `LETHAL`.

**`pick` necesita saber si está en el piso solo para `morir_caida`.**
En el paso en que toca el piso, el estado todavía es `AIR` y sigue `caer_largo`. En el siguiente ya es `DEAD`, y pasa directo a `morir_caida`, sin ningún cuadro de pie (AC10).

**"Se queda en el último cuadro" pasa a ser una función pura, `PlayerAnimation.holds_last_frame()`.**
Hoy es una comparación con `&"morir"` dentro del nodo. Con dos animaciones así, conviene una regla que se pueda testear. `morir_caida` no se agrega a `duration_for`, que devuelve 0, y entonces va a su ritmo natural (AC08).

**La altura sigue sumando al cruzar de sala.** `World` solo cambia la `position` de Elyon y el motor no se entera, así que no hace falta código: una caída sigue siendo una sola caída.

**Sigue `AnimatedSprite2D` con `SpriteFrames`**, como fija `architecture.md`. No hace falta `AnimationPlayer` ni `AnimationTree`: son cuadros, sin mezclas ni otras propiedades que animar.

## Señales

Ninguna nueva. `death_finished` sigue llevando a Elyon al checkpoint, también en la muerte por altura.

## Qué se testea con gdUnit4

| Criterio | Test | Archivo |
|---|---|---|
| AC01 | `test_f010_ac01_lethal_landing_dies_with_death_time` (con y sin velocidad) | `player_motor_test.gd` |
| AC02 | `test_f010_ac02_just_below_lethal_rolls_or_recovers` | `player_motor_test.gd` |
| AC03 | `test_f010_ac03_fall_death_ignores_input_and_finishes` | `player_motor_test.gd` |
| AC04 | `test_f010_ac04_fall_counts_from_highest_point` | `player_motor_test.gd` |
| AC05 | `test_f010_ac05_air_animation_by_severity` | `player_animation_test.gd` |
| AC06 | `test_f010_ac06_dead_on_floor_by_severity` | `player_animation_test.gd` |
| AC07 | `test_f010_ac07_dead_in_air_lethal_keeps_caer_largo` | `player_animation_test.gd` |
| AC08 | `test_f010_ac08_morir_caida_keeps_own_pace_and_last_frame` | `player_animation_test.gd` |
| AC09 | `test_f010_ac09_frames_have_new_animations` | `player_animation_test.gd` |

También se suman tests de los valores por defecto en `player_movement_config_test.gd`. `test_f009_ac06_frames_have_every_animation` pasa de esperar 11 animaciones a 13.

## Impacto en overlay debug

Una línea nueva, `caída`: la altura que lleva contada en píxeles, por ejemplo `caída: 312 px`. Sirve para AC10, AC11, AC12, AC18 y para ajustar los dos límites jugando.

## Riesgos

- **El arte vive en otro repositorio.** Se copia desde `build/blender/elyon_v9/` de `cw2d-art`, que no está publicado en `assets/final/`. La tira de `elyon.png` queda como copia en este repositorio, igual que las animaciones anteriores.
- **Margen del pozo.** Los pies tocan la zona a los 460 px, 40 px por encima de `lethal_fall_height`. Si se sube ese límite a más de 460, la muerte en el pozo se ve con `morir`. El rango sugerido llega a 700, así que conviene tenerlo presente al ajustar.
- **Muerte al llegar a una sala.** Como la altura suma entre salas, Elyon puede morir al aterrizar en una sala que recién ve. Al armar niveles, una salida de abajo tiene que contar lo que se cae antes y después de cruzar.
- **Salas binarias.** Las baldosas de las salas se guardan como un bloque de bytes. Los cambios se hacen decodificando y volviendo a codificar ese bloque, para que el resto de la escena no cambie, y se verifican con una simulación de física que mide las caídas.

## Salas de prueba

- **Sala 3 (AC11):** hueco de 6 baldosas en el piso de arriba (x 800–920), que se cruza saltando, y el piso del medio termina en x 760. Debajo queda una caída de 480 px sobre piso común, a la que se llega desde los dos lados. El bloque del piso de abajo pasa a x 600–680, porque si no frenaría la caída a 400 px, y la zona mortal del piso del medio pasa a x 600, porque si no quedaría en el borde del hueco.
- **Sala 2 (AC18):** un segundo hueco de salida a la derecha del que ya existe (x 1120–1260), abierto en el piso del medio y en el de abajo. La zona colgante y el hueco original no cambian, porque los usa el playtest de F007. Desde el piso del medio se baja unos 340 px hasta cruzar y otros 100 en la sala 3: la suma supera el límite y Elyon muere al aterrizar.
