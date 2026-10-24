---
id: F003
type: feature
status: done
superseded_by:
links: { gdd: [G001], decisions: [D0002], spike: }
updated: 2026-10-24
---

# Plan: feature 003

## Árbol de escenas

```
World (Node2D, world.gd)                         game/world/world.tscn
├── TestRoom (instancia)                         game/levels/test/test_room.tscn
│   ├── Tiles (TileMapLayer, tile_set = greybox.tres)
│   └── Spawn (Marker2D)                          punto de inicio del personaje
├── Player (instancia)                            game/entities/player/player.tscn
│   ├── Body (ColorRect 26×40, gris claro)        el "rectángulo"
│   └── Shape (CollisionShape2D, RectangleShape2D 26×40)
└── DebugOverlay (instancia)                      game/debug/debug_overlay.tscn
    └── (CanvasLayer, layer 5) > Panel > Label
```

- `World` deja de mostrar el texto provisorio y el contador: ahora arma la partida con la sala, el personaje y el overlay. Las etiquetas `WORLD_PLACEHOLDER` y `WORLD_ELAPSED` quedan sin uso y se borran de `texts.csv`.
- La sala es su propia escena (una por sala), igual que van a ser las salas de la F004. `World` la instancia; en la F004 va a poder cambiarla.

## Elecciones y por qué

| Tema | Elegido | Descartado | Por qué |
|---|---|---|---|
| Cuerpo del personaje | `CharacterBody2D` | `RigidBody2D` | Con `CharacterBody2D` el código decide la velocidad y `move_and_slide()` resuelve los choques: control exacto. Un `RigidBody2D` lo mueve el motor de física con fuerzas, y el control se vuelve impreciso. |
| Gravedad | Calculada de `jump_height` y `time_to_apex` (spec AC06) | La gravedad global del proyecto (`physics/2d/default_gravity`), que es lo que sugiere la guía de Godot | La spec pide ajustar "qué tan alto" y "en cuánto tiempo". La gravedad global es un número suelto difícil de ajustar, y la usarían también objetos que no son el personaje. |
| Dibujo del rectángulo | `ColorRect` | `Sprite2D` con una textura | Es greybox: un rectángulo de color no necesita imagen. Cuando haya arte se cambia por un sprite sin tocar la lógica. |
| Escenario | `TileMapLayer` con un `TileSet` de una baldosa gris de 20 px con colisión | Dibujar cajas de colisión a mano (`StaticBody2D`) | Es lo que fija `CLAUDE.md`. Además las salas se "pintan" con baldosas en el editor, y cada baldosa ya trae su colisión. |
| `TileSet` | Archivo aparte, `game/levels/tilesets/greybox.tres` | Guardado dentro de la sala | Lo comparten todas las salas de prueba; si se cambia, cambia en todas. |
| Lectura de input | En el nodo `Player`, que arma un `PlayerInput` (dirección + salto recién apretado) | Que `PlayerMotor` lea `Input` directamente | La lógica pura no toca `Input` (convención 1). Así los tests le pasan un input inventado. |
| "Recién apretado" | `Input.is_action_just_pressed("jump")` en el nodo | Guardar el estado anterior del botón en el motor | Godot ya lo resuelve. Mantener apretado no repite el salto (AC05). |
| Salida de la sala | `World` pregunta a `RoomGeometry.is_outside_room(rect)` (debajo, izquierda o derecha) y, si da verdadero, reubica al personaje en `Spawn` | Un `Area2D` "zona de muerte" bajo la sala | La regla (cuándo está afuera) queda en lógica pura y testeable. Además no hay que agregar un área a cada sala. La F005 lo reemplaza por la muerte. |
| Overlay | `CanvasLayer` que cada cuadro pide `get_debug_info()` al personaje | El personaje emitiendo una señal en cada cuadro | Es una herramienta de desarrollo que se consulta cuando está visible. Una señal por cuadro sería ruido sin beneficio. |
| Altura exacta del salto | Al despegar, la velocidad de salto se corrige restando la gravedad de medio paso | Aceptar el error y subir la tolerancia | Godot mueve en pasos de 1/60 s. Sin corregir, el salto mide de más (83,8 px en vez de 80). La corrección de medio paso hace que `jump_height` sea la altura real. |
| Pausa | `Player` hereda `PAUSABLE` de `World` | — | Ya funciona así: al pausar se congela todo lo que está dentro de `World`. El overlay usa `ALWAYS` para poder abrirse con F3 también en pausa. |

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/player/player_movement_config.gd` | Resource | `PlayerMovementConfig`: `run_speed`, `jump_height`, `time_to_apex`, `max_fall_speed` (`@export`). Métodos `get_gravity()` y `get_jump_velocity()` (AC06). |
| `game/systems/player/player_input.gd` | lógica pura | `PlayerInput`: valor con `direction: float` (−1 a 1) y `jump_just_pressed: bool`. Sin lectura de teclado. |
| `game/systems/player/player_motor.gd` | lógica pura | `PlayerMotor.step(velocity, input, on_floor, delta) -> Vector2`: caminar, gravedad con tope, salto solo en el piso (AC01–AC05). |
| `game/systems/rooms/room_geometry.gd` | lógica pura | Constantes de D0002 (`TILE_SIZE = 20`, `COLUMNS = 32`, `ROWS = 18`, tamaño en px) y `is_outside_room(rect)`. |
| `game/entities/player/player.gd` | nodo | `Player` (`CharacterBody2D`): arma `PlayerInput` con `Input.get_axis("move_left", "move_right")` y `is_action_just_pressed("jump")`, llama al motor, `move_and_slide()`. `get_debug_info()` para el overlay; `get_bounds()` da su rectángulo; `reset_to(pos)` lo pone ahí con velocidad cero. |
| `game/world/world.gd` | nodo | Pone al personaje en `Spawn`, le pasa el personaje al overlay y, en `_physics_process`, reubica si sale de la sala. |
| `game/debug/debug_overlay.gd` | nodo | `DebugOverlay`: F3 (`debug_toggle`) muestra u oculta; si está visible, escribe las líneas de `get_debug_info()` más los FPS. |
| `game/data/player_movement.tres` | Resource (instancia) | Valores iniciales de la spec. Después lo edita solo el desarrollador. |
| `game/levels/tilesets/greybox.tres` + `game/art/greybox/block.png` | Resource + imagen | Baldosa gris de 20×20 con borde, para distinguir baldosas, y colisión de cuadrado completo. |
| `game/levels/test/test_room.tscn` | escena | Sala de 32 × 18: paredes con entrada (izquierda, piso 1) y salida (derecha, piso 3), 3 pisos de 6 filas, escaleras de dos escalones de 2 filas, hueco de 3 baldosas en el piso de abajo y `Spawn` junto a la entrada. Se genera con un script temporal que pinta las baldosas (más preciso que a mano); después se puede editar en el editor. |

## Señales

Ninguna nueva. El overlay consulta al personaje (ver "Elecciones") y la reubicación es una llamada directa de `World` a su hijo `Player`. Ambos son nodos de la misma escena: un padre llamando a su hijo es la forma normal en Godot ("llamar hacia abajo, señales hacia arriba").

## Qué se testea con gdUnit4

`test/player/player_motor_test.gd`:
- `test_f003_ac01_walks_at_run_speed`: derecha, izquierda, nada y "las dos" (dirección 0), en el piso y en el aire.
- `test_f003_ac02_gravity_accumulates_and_caps`: en el aire suma `gravity × delta`; nunca pasa de `max_fall_speed`; en el piso no acumula.
- `test_f003_ac03_jump_reaches_jump_height`: simula pasos de 1/60 s hasta el punto más alto; altura = `jump_height` ± 2 px.
- `test_f003_ac04_no_jump_in_air`.
- `test_f003_ac05_held_jump_does_not_repeat`: en el piso con salto no "recién apretado", no salta.

`test/player/player_movement_config_test.gd`:
- `test_f003_ac06_derived_gravity_and_jump_velocity`.

`test/rooms/room_geometry_test.gd`:
- `test_room_size_matches_viewport`: 32 × 20 = 640 y 18 × 20 = 360 (D0002).
- `test_f003_ac10_outside_room`: asomando por un borde no está afuera; entero por debajo, por la izquierda o por la derecha, sí; por arriba nunca.

## Impacto en overlay debug

Se crea el overlay, que hasta ahora no existía. Líneas: `FPS`, `velocidad (x, y)`, `en el piso: sí/no`. Textos en castellano, sin traducir (decisión de la spec).

## Riesgos

- **El personaje se engancha en las uniones entre baldosas** al caminar sobre el piso. Pasa a veces con colisiones por baldosa. Godot 4.5+ une automáticamente las colisiones vecinas de un `TileMapLayer`; si igual aparece, se nota en el playtest y se corrige.
- **Atravesar el piso cayendo rápido**: a 600 px/s se mueve 10 px por cuadro, la mitad de una baldosa, así que no debería pasar. Está en Casos límite.
- **Pantalla completa embebida**: como en la F002, si el juego corre dentro del editor la escala puede verse distinta. AC07 se verifica en ventana propia.
