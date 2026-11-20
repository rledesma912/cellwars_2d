---
id: F012
type: feature
status: draft
superseded_by:
links: { gdd: [G001, G003], decisions: [D0006, D0007], spike: S003 }
updated: 2026-11-20
---

# Plan: feature 012 (disparo)

La forma del prototipo S003 pasa al juego sin lo descartado:

- solo automático (sin tiro a tiro ni ráfaga);
- solo proyectil (sin rayo);
- sin reglas para correr;
- sin quedar plantado.

## Árbol de escenas

```
World (Node2D, world.gd)                 # ya existe
├── <sala actual> (Room)                 # ya existe, primer hijo
├── Player (CharacterBody2D, player.gd)  # ya existe
│   ├── Sprite (AnimatedSprite2D)        # pasa a la hoja Elyon2
│   ├── Shape (CollisionShape2D)
│   └── Gun (Line2D)                     # nuevo: marca el arma corriendo y en el aire
├── Projectiles (Node2D)                 # nuevo: contenedor de los proyectiles en vuelo
│   └── Projectile (Node2D, projectile.gd)   # uno por tiro, se crea en código
└── DebugOverlay                         # ya existe

game/entities/projectile/projectile.tscn
Projectile (Node2D, projectile.gd)       # se dibuja con _draw: un rectángulo de 12 × 4
```

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/combat/shoot_config.gd` | Resource | `ShootConfig`: cadencia, velocidad, alcance, ángulos, tiempo de pose y bocas del arma |
| `game/data/shoot.tres` | Resource (`.tres`) | Valores iniciales del spike S003 (los crea el agente una vez) |
| `game/systems/combat/shoot_logic.gd` | lógica pura | `ShootLogic`: gatillo automático con tope de cadencia, situaciones en que se puede disparar, tiempo de pose. Estáticas: `aim_from`, `stance_for(PlayerMotor.State)`, `direction`, `muzzle` |
| `game/systems/combat/projectile_flight.gd` | lógica pura | `ProjectileFlight`: posición y distancia recorrida. `advance(delta)` devuelve el tramo (desde, hasta) del paso y si terminó. El primer tramo arranca en el punto de resguardo (centro de Elyon a la altura de la boca) |
| `game/entities/player/player.gd` | nodo | Lee `shoot`, `move_up` y `move_down`, llama a `ShootLogic`, emite `shot_fired`, pone la animación de disparo de pie y la línea `Gun`. Sus líneas de F3 |
| `game/entities/player/player.tscn` | escena | `shoot_config` apunta a `shoot.tres`; nodo `Gun` |
| `game/systems/player/player_animation.gd` | lógica pura | `shot_animation(aim)` → `disparar_adelante` / `disparar_arriba` / `disparar_abajo` |
| `game/entities/projectile/projectile.gd` + `.tscn` | nodo | Pide el tramo a `ProjectileFlight`, lanza el rayo (`intersect_ray`) y se libera al chocar o al terminar |
| `game/world/world.gd` + `world.tscn` | nodo | Escucha `shot_fired`, crea el proyectil en `Projectiles` y vacía el contenedor al cambiar de sala y al volver a la entrada |
| `game/art/elyon/elyon.png` + `elyon_frames.tres` | arte | Se reemplazan por la hoja Elyon2 del tag `archive/spike-003` (con la ruta corregida) |
| `project.godot` | config | Acción `shoot` (`J`, `X`, botón X); `dash` pasa al botón B; nombre de la capa 1 de física ("mundo") |

### Elecciones de Godot

- **Proyectil: un `Node2D` que lanza un rayo por código en cada paso** (`PhysicsDirectSpaceState2D.intersect_ray` desde donde estaba hasta donde va a estar).
  - Descartado `Area2D`: detecta lo que *ya se superpone*. A 900 px/s avanza 15 px por paso y podría saltearse algo fino. Además avisa recién en el paso siguiente.
  - Descartado `RayCast2D` como nodo hijo: haría lo mismo, pero hay que moverlo y forzarlo (`force_raycast_update`) en cada paso. Es un nodo más sin ganar nada.
  - Descartado `RigidBody2D`: el motor de física lo movería con rebotes y masa, que no queremos.
  - Es lo que se probó en el spike.
- **El proyectil no usa `move_and_slide`**: no es un cuerpo, no choca contra nada por sí solo. Solo pregunta "¿hay algo en este tramo?". Se mueve cambiando `global_position`.
- **Contenedor `Projectiles` en World, no dentro de la sala**:
  - Las salas se sacan del árbol y se guardan vivas al cambiar (precarga). Un proyectil adentro de una sala vieja reaparecería al volver.
  - En un contenedor propio, World los borra todos de una vez (`queue_free` de cada hijo).
  - Hereda la pausa de World: en pausa no corre su `_physics_process` y se quedan quietos.
- **Señal `shot_fired` de Player a World, no que Player cree el proyectil**:
  - Player no sabe dónde viven los proyectiles ni cuándo se borran.
  - World ya es quien arma la partida.
  - Es la misma forma que `death_finished`.
- **Tramo de resguardo** (pegado a la pared): el primer tramo va desde el centro de Elyon, a la altura de la boca, hasta la primera posición del proyectil. Así un tiro con la boca metida en la pared choca en el acto, en vez de nacer del otro lado (F012-AC13).
  - `intersect_ray` ignora un choque si el rayo *empieza* dentro de un cuerpo (`hit_from_inside` en `false`). Pero el centro de Elyon nunca está dentro de la pared.
- **Pose de disparo de pie en el nodo, la regla en `ShootLogic`**:
  - `ShootLogic` lleva el tiempo de pose: cuánto falta y si está en pose.
  - Player solo elige qué cuadro mostrar: reinicia la animación en cada tiro y conserva el cuadro al cambiar de ángulo.
  - Mientras está en pose, Player no llama a `_animate`. Si lo llamara, cada paso pondría "quieto" y reiniciaría la animación de disparo.
- **Capa de física**: el proyectil busca solo la capa 1 (paredes, pisos y techos de las baldosas) y excluye a Elyon. Los blancos y enemigos van a usar otra capa en el spike de combate.

## Señales

| Señal | Emisor | Receptores | Payload |
|---|---|---|---|
| `shot_fired` | `Player` | `World` | `origin: Vector2` (boca, en coordenadas del mundo), `direction: Vector2` (largo 1), `guard_from: Vector2` (centro de Elyon a la altura de la boca) |

## Qué se testea con gdUnit4

`test/combat/shoot_logic_test.gd`:

- F012-AC01 → `test_f012_ac01_aim_from_up_down`
- F012-AC02 → `test_f012_ac02_direction_by_aim_facing_and_air`
- F012-AC03 → `test_f012_ac03_auto_fires_seven_shots_in_sixty_steps`
- F012-AC04 → `test_f012_ac04_repress_does_not_beat_cadence`
- F012-AC05 →
  - `test_f012_ac05_stance_for_motor_states`
  - `test_f012_ac05_no_fire_when_busy`
  - `test_f012_ac05_fires_when_back_from_busy`
- F012-AC06 → `test_f012_ac06_muzzle_mirrors_with_facing`

`test/combat/projectile_flight_test.gd`:

- F012-AC07 → `test_f012_ac07_flight_ends_at_range_in_24_steps`
- F012-AC07 → `test_f012_ac07_first_segment_starts_at_guard`

`test/player/player_animation_test.gd` (ya existe), como apoyo de AC15:

- `test_shot_animation_by_aim`

## Impacto en overlay debug

Líneas nuevas de Player, bajo "— disparo —":

- `apunta`: adelante / arriba / abajo.
- `puede disparar`: sí / no (situación).
- `próximo tiro en`: segundos.
- `pose de tiro`: segundos que le quedan.
- `disparos`: total desde que arrancó la partida.

## Riesgos

- **La hoja Elyon2 cambia todas las animaciones**:
  - Hay que confirmar que las duraciones que pide `PlayerAnimation.duration_for` siguen bien con la cantidad de cuadros de Elyon2. En el spike se jugó con la misma clase `Player`, así que se espera que sí.
  - Puede hacer falta revisar el `offset` del sprite si los pies no caen en (72, 143).
  - Se cubre con F012-AC16.
- **Muerte con disparo apretado**: muerto es una situación sin tiro. Al volver a la entrada, si sigue apretado, dispara: es lo esperado.
- **`.tres` y el editor**: si el editor guarda `shoot.tres`, omite los valores iguales a los de fábrica. Los valores de fábrica del script son los mismos del `.tres`, así que no cambia nada.
- **La pose de disparo tapa `_animate`**: si Elyon empieza a caer mientras está en pose (por ejemplo, el piso desaparece), la situación pasa a "en el aire" y la pose se corta. Se prueba en AC11.
