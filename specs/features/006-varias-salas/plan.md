---
id: F006
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0004], spike: }
updated: 2026-10-29
---

# Plan: feature 006 — varias salas y el paso entre ellas

## Idea general

`Elyon` no cambia de escena: lo que cambia es la sala que tiene al lado dentro de `World`. Al cruzar un borde, `World` saca la sala actual del árbol, pone la vecina (ya instanciada de antemano) y mueve a Elyon a la posición de llegada. Como el nodo `Player` es el mismo, su velocidad, su estado del motor y hacia dónde mira siguen intactos sin hacer nada: un salto o una carrera siguen del otro lado.

Las reglas (qué borde cruzó, qué significa en esta sala, a qué sala va y dónde aparece) son lógica pura en `game/systems/rooms/`. `World` solo las aplica.

## Árbol de escenas

```
World (Node2D, world.gd)                    @export level: LevelData = test_level.tres
├── <sala actual> (Node2D, room.gd)        se cambia en cada cruce; siempre primer hijo
│   ├── Background (ColorRect)
│   ├── Tiles (TileMapLayer)                material sharp_pixel, filtro lineal
│   ├── Entrance (Marker2D)                 pies de Elyon al entrar
│   └── Exit (Marker2D)                     pies de Elyon al llegar volviendo
├── Player (CharacterBody2D)                sin cambios
└── DebugOverlay (CanvasLayer)
```

Salas de prueba en `game/levels/test/`:

| Sala | Archivo | Entrada | Salida | Bajo el borde inferior |
|---|---|---|---|---|
| 1 | `test_room_1.tscn` (la `test_room.tscn` actual, renombrada) | izquierda | derecha | vacío mortal (el precipicio de siempre) |
| 2 | `test_room_2.tscn` (nueva) | izquierda | abajo | la sala 3 |
| 3 | `test_room_3.tscn` (nueva) | arriba | derecha | vacío mortal |

Nivel: `game/levels/test/test_level.tres` (`LevelData`, `rooms = [sala 1, sala 2, sala 3]`).

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/rooms/room_geometry.gd` | lógica pura (existente) | Se agrega `enum Edge { NONE, LEFT, RIGHT, TOP, BOTTOM }` y `crossed_edge(bounds) -> Edge` (AC03). `is_outside_room()` pasa a ser `crossed_edge() != NONE`, así el test de la F003 sigue valiendo. |
| `game/systems/rooms/room_exits.gd` | lógica pura, nueva (`RoomExits`, funciones estáticas) | `resolve(edge, entrance_side, exit_side) -> Outcome` (`NONE`, `NEXT`, `PREVIOUS`, `VOID`) (AC04). `arrival(edge, feet, crossed_marker, target_marker) -> Vector2` conserva el desplazamiento relativo (AC05). `opposite(side)` y `validate(sides) -> PackedStringArray` con los errores de un nivel (AC06). |
| `game/systems/rooms/level_progress.gd` | lógica pura, nueva (`LevelProgress`, con estado) | Sabe en qué sala está (`index`, `count`). `apply(outcome) -> RoomChange`: sala destino, a qué marcador llega (entrada o salida) y si conserva el movimiento o vuelve quieto (AC01, AC02, parte de AC05). |
| `game/systems/rooms/level_data.gd` | Resource, nuevo (`LevelData`) | `@export var rooms: Array[PackedScene]`. Es contenido del nivel, no tuning. |
| `game/world/room.gd` | nodo, nuevo (`Room`) | Script de la raíz de cada sala. `@export entrance_side` y `exit_side` (`RoomGeometry.Edge`), y devuelve las posiciones de `Entrance` y `Exit`. Sin reglas. |
| `game/world/world.gd` | nodo (existente) | Instancia la sala 1, guarda las vecinas instanciadas, en cada paso de física pregunta a `RoomGeometry`/`RoomExits`/`LevelProgress` y aplica el resultado: cambia la sala y mueve a Elyon (`position`) o lo resetea (`reset_to`). Línea "sala" en F3. |
| `game/entities/player/player.gd` | nodo (existente) | Sin cambios: ya tiene `get_bounds()` y `reset_to()`. Para conservar el movimiento, `World` solo cambia `position`. |

### Elecciones no obvias

- **Precarga: instanciar las vecinas fuera del árbol** (elegido) **vs. `ResourceLoader.load_threaded_request`** (descartado). La spec fija `rooms: Array[PackedScene]`. Un `.tres` que referencia escenas las carga junto con él, así que al abrir el nivel las 3 salas ya están en memoria y no queda nada para cargar en otro hilo. Lo que puede costar algo es `instantiate()`, que crea los nodos. Por eso `World` deja instanciadas la anterior y la siguiente, fuera del árbol, y el cruce es solo sacar un nodo y poner otro. Cargar con hilos pediría guardar rutas en vez de escenas y manejar el estado de la carga. No vale la pena con salas así de chicas: el skill de GodotPrompter recomienda medir antes de usar hilos, y AC11 lo mide. El caso límite "precarga sin terminar" queda cubierto: si la vecina no está instanciada (no debería pasar), se instancia en el momento.
- **Sacar la sala con `remove_child` y no con `queue_free`**: `remove_child` la deja viva fuera del árbol para reusarla si Elyon vuelve. Las salas que dejan de ser vecinas se liberan con `queue_free`.
- **Mismo `Player`, solo cambia `position`**: no se recrea ni se resetea el motor, así se conservan velocidad, estado y dirección sin código extra (AC05, AC08).
- **`Room` como script de la raíz de la sala** (elegido) **vs. metadatos en los `Marker2D`** (descartado). Un `@export` con un enum aparece como desplegable en el inspector y lo valida el tipo. Con metadatos sería texto libre y fácil de escribir mal.
- **Llamadas directas y no señales**: `World` es dueño de las salas y del jugador, y las reglas son funciones puras que devuelven un resultado. No hay otro sistema que necesite enterarse del cambio de sala todavía. Cuando lo haya (checkpoint en la F007), se agrega una señal `room_changed`.
- **`Edge` en `RoomGeometry`**: el mismo enum sirve para "qué borde cruzó" y para "de qué lado está la entrada o la salida".

### Reglas, en detalle

- `crossed_edge`: `LEFT` si `bounds.end.x < 0`; `RIGHT` si `bounds.position.x > 1280`; `BOTTOM` si `bounds.position.y > 720`; si no, `NONE`. Arriba nunca cuenta (AC03).
- `resolve`: si el borde es `exit_side` → `NEXT`; si es `entrance_side` → `PREVIOUS`; si es `BOTTOM` → `VOID`; si no → `NONE` (AC04). Si la entrada está arriba, cruzar arriba ya da `NONE` por `crossed_edge`: no se vuelve hacia arriba.
- `LevelProgress.apply`:
  - `NEXT`: si no es la última → sala `index + 1`, llega a la **entrada**, conserva el movimiento. Si es la última → sala 1, entrada, quieto (provisorio, AC02).
  - `PREVIOUS`: si no es la primera → sala `index − 1`, llega a la **salida**, conserva el movimiento. Si es la primera → sala 1, entrada, quieto (AC02).
  - `VOID`: misma sala, entrada, quieto.
- `arrival`: en un cruce por un costado, `x` del marcador destino e `y = destino.y + (pies.y − cruzado.y)`. En un cruce por abajo, `y` del marcador destino y `x = destino.x + (pies.x − cruzado.x)` (AC05).
- Los marcadores se ponen un poco hacia adentro de su borde (por ejemplo, `x = 30` a la izquierda, `x = 1250` a la derecha, `y = 120` arriba), así Elyon aparece entero dentro de la pantalla y no vuelve a cruzar en el mismo paso.

## Señales

Ninguna nueva (ver "Llamadas directas y no señales").

## Qué se testea con gdUnit4

| Criterio | Test | Archivo |
|---|---|---|
| F006-AC01 | `test_f006_ac01_advance_and_go_back` | `test/rooms/level_progress_test.gd` |
| F006-AC02 | `test_f006_ac02_list_edges` | `test/rooms/level_progress_test.gd` |
| F006-AC03 | `test_f006_ac03_crossed_edge` | `test/rooms/room_geometry_test.gd` |
| F006-AC04 | `test_f006_ac04_edge_meaning` | `test/rooms/room_exits_test.gd` |
| F006-AC05 | `test_f006_ac05_arrival_keeps_offset` y `test_f006_ac05_change_keeps_motion` | `test/rooms/room_exits_test.gd`, `test/rooms/level_progress_test.gd` |
| F006-AC06 | `test_f006_ac06_validate_rules` (reglas con datos armados) y `test_f006_ac06_test_level_is_valid` (carga `test_level.tres`, instancia cada sala y lee sus lados y marcadores) | `test/rooms/room_exits_test.gd` |

El segundo test de AC06 instancia escenas: no usa input ni pantalla, así que corre igual en headless. Libera cada sala al terminar.

## Impacto en overlay debug

- `World`: "sala: 2 / 3" (AC12), además de la línea de escala que ya tiene.

## Riesgos

- **Cambiar la sala dentro de `_physics_process`**: sacar un `TileMapLayer` con colisiones mientras corre la física puede dar el error "flushing queries". Si aparece en el smoke run, el cambio se hace con `call_deferred` (en el mismo cuadro, después de la física).
- **Un paso con el piso viejo**: `is_on_floor()` se actualiza en el siguiente `move_and_slide()`. Si Elyon llega corriendo, puede notarse un cuadro raro en la animación. Se mira en el playtest (AC08, AC14).
- **Array tipado en `.tres`**: en el spike 002 un array tipado exportado falló dentro de un `.tscn`. En un `.tres` (`Array[PackedScene]([...])`) debería andar. Si no, se crea con un script headless que lo guarda con `ResourceSaver`.
- **Aberturas alineadas**: si la abertura de una sala no coincide con la de la vecina, Elyon aparece contra una pared. AC06 valida los lados, no la geometría. Las salas se dibujan con las aberturas a la altura de sus marcadores y se revisa en el playtest (AC07–AC10).
- **Renombrar `test_room.tscn`**: el `uid` vive dentro del archivo, así que `git mv` no lo rompe. Igual se revisan las referencias (`world.tscn`).
