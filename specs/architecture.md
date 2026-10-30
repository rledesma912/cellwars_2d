---
id: ARCH
type: architecture
status: approved
superseded_by:
links: { gdd: [], decisions: [D0003, D0004], spike: }
updated: 2026-10-30
---

# Arquitectura

> Documento vivo. Decisiones técnicas transversales vigentes. Cuando una decisión de `decisions/` cambia algo de acá, se reescribe esta página (sin dejar la versión anterior).

## Regla central: lógica pura + nodo fino + config en Resource

- **Lógica pura**: las reglas de juego viven en clases `RefCounted` sin dependencia del árbol de escenas, en `game/systems/`. Son las únicas con unit tests (gdUnit4); `test/` es espejo de `game/systems/`.
- **Nodo fino**: los nodos (`CharacterBody2D`, `Area2D`…) en `game/entities/` leen input, llaman a la lógica pura y aplican el resultado. No contienen reglas.
- **Config en Resource**: todo parámetro ajustable es un Resource tipado con `@export` (p. ej. `PlayerMovementConfig`), instanciado como `.tres` en `game/data/`. Lo edita el desarrollador en el inspector. Ojo: al guardar un `.tres`, el editor omite los valores iguales a los valores por defecto del script. El juego se comporta igual, pero el archivo deja de mostrarlos; si se vacía, se restaura con los valores escritos.

Forma esperada (bosquejo):

```gdscript
# game/systems/player/player_motor.gd
class_name PlayerMotor
extends RefCounted

var config: PlayerMovementConfig


func _init(p_config: PlayerMovementConfig) -> void:
	config = p_config


## Devuelve la nueva velocidad. Sin efectos sobre nodos: testeable en aislamiento.
func step(velocity: Vector2, input: PlayerInput, on_floor: bool, delta: float) -> Vector2:
	return velocity
```

```gdscript
# game/entities/player/player.gd
extends CharacterBody2D

@export var config: PlayerMovementConfig
var _motor: PlayerMotor


func _ready() -> void:
	_motor = PlayerMotor.new(config)


func _physics_process(delta: float) -> void:
	velocity = _motor.step(velocity, PlayerInput.from_actions(), is_on_floor(), delta)
	move_and_slide()
```

## Escenas

- `game/main.tscn` (`Main`): raíz persistente. Instancia la pantalla actual (menú o `World`) y tiene el menú de pausa. No se usa `change_scene_to_file()`, para que el flujo de pantallas no necesite un autoload.
- `game/ui/`: menús (principal, pausa). Nodos `Control`; los overlays van en un `CanvasLayer`.
- `game/world/`: la escena activa mientras se juega. Arma la partida: carga salas de `game/levels/` y pone entidades de `game/entities/`.
- Salas: una escena por sala en `game/levels/` (las de prueba en `game/levels/test/`), con un `TileMapLayer` que usa un `TileSet` compartido de `game/levels/tilesets/` (cada baldosa trae su colisión) y la raíz con el script `Room` (`game/world/room.gd`): dice de qué lado están la entrada y la salida (`entrance_side`, `exit_side`) y las marca con los `Marker2D` `Entrance` y `Exit`, un poco hacia adentro del borde. Las medidas (D0004) viven en `RoomGeometry` (`game/systems/rooms/`). Toda sala tiene entrada y salida en lados distintos; la salida nunca está arriba y la entrada nunca abajo.
- Niveles (F006): un nivel es un `LevelData` (`.tres` en `game/levels/`) con la lista ordenada de salas. `World` tiene una sola sala en el árbol y deja la anterior y la siguiente instanciadas fuera de él. En cada paso de física, `RoomGeometry.crossed_edge` dice qué borde cruzó Elyon, `RoomExits.resolve` qué significa en esa sala y `LevelProgress` a qué sala va. El cambio es sacar un nodo y poner otro, y Elyon solo cambia de `position`, así conserva el movimiento. Cruzar por arriba nunca cuenta; abajo es la sala siguiente si la salida está abajo y, si no, el vacío.
- Entidades: el origen de un personaje está en sus pies, al centro.

## Personaje y movimiento (D0003, tamaños de D0004)

- **Movimiento híbrido**: un motor de lógica pura con estados (enum: quieto, correr, frenar, girar, preparar salto, en el aire, recuperarse) decide qué acciones valen en cada momento. Arranque y frenado cortos, preparación corta del salto, salto variable, coyote time y jump buffer, control reducido en el aire sin darse vuelta, recuperación al caer de alto. Máquina de estados con enum y no con nodos: pocos estados con poca lógica de entrada/salida, y así sigue siendo testeable sin escenas.
- **Tamaño** (D0004): el soldado mide 99 px de alto visible (cuerpo de colisión 44 × 106) y salta unos 114 px. Cuerpo + salto entran en los 220 px de aire de un piso en una sala de 3 pisos. Las salas usan escalones de hasta 4 baldosas. Los valores del movimiento son los de D0003 con distancias y velocidades × 2,2 y los mismos tiempos.
- **El motor manda los tiempos y la animación se adapta**: cada tiempo de acción (preparación, giro, recuperación) vive en el `.tres` del movimiento, y la animación correspondiente se estira o acorta para durarlo.
- **Animación**: `AnimatedSprite2D` cuya animación elige el estado del motor. Cuadros de 144 × 144 px, pies abajo al centro (72, 143), mirando a la derecha; la izquierda se obtiene espejando. Toda acción nueva sigue la misma filosofía (anticipación y recuperación cortas) y su sensación se prueba en su propia feature.
- Pausa: `get_tree().paused`. `Main` corre en `PROCESS_MODE_ALWAYS`; `World` declara `PROCESS_MODE_PAUSABLE` explícitamente (si no, heredaría `ALWAYS`).

## Textos e idiomas

- Cada texto visible es una etiqueta (`MENU_PLAY`) en `game/i18n/texts.csv`, con columnas `es` y `en`, registrada en *Localization → Translations*. Idioma de respaldo: `en`.
- Los nodos con `text` fijo se traducen solos; el texto armado por código usa `tr("ETIQUETA")`.
- Excepción: el overlay de debug es una herramienta de desarrollo y sus textos van en castellano, sin traducir.
- Los `.translation` que genera la importación del CSV no se versionan (`.gitignore`).

## Comunicación

- Entre sistemas, por señales. Evitar `get_node()` con rutas largas.
- Autoloads: como máximo un bus de eventos y el estado global del juego.

## Física

- 60 ticks por segundo (default de Godot). El movimiento se calcula en `_physics_process`.

## Render y resolución

D0004, aplicada en la F005.

| Parámetro | Valor | Estado |
|---|---|---|
| Renderer | `gl_compatibility` | Vigente |
| Viewport | 1280×720, ventana inicial 1280×720 | Vigente (D0004) |
| Stretch | `canvas_items`, aspect `keep`, scale `fractional` | Vigente (D0004) |
| Suavizado del pixel art | *sharp bilinear* por sprite y baldosa (ver abajo) | Vigente (D0004) |
| `snap_2d_transforms_to_pixel` | `false`: el movimiento suave entre píxeles es parte del look | Vigente (D0004) |
| Tile | 20 px; una sala = una pantalla = 64 × 36 tiles, 12 por piso | Vigente (D0004) |
| Escala del tema de la interfaz | `gui/theme/default_theme_scale = 2` | Vigente: la interfaz se diseña al doble que a 640×360 |
| Display driver Linux | Wayland (`display_server/driver.linuxbsd`) | Vigente: el entorno del agente no tiene X11 |

Reglas del pixel art en `canvas_items`:

- La escena se dibuja a la resolución de la pantalla, y a 1080p cada píxel del arte ocupa 1,5 píxeles de pantalla. Para que no queden unos píxeles dobles y otros simples, **todo sprite y toda baldosa de pixel art usan un material compartido con el shader *sharp bilinear*** y filtro lineal. Ningún pixel art se dibuja sin él.
- Todo el pixel art usa el material compartido `game/art/shaders/sharp_pixel.tres` (shader `sharp_pixel.gdshader`) con `texture_filter` lineal en el nodo. El filtro por defecto del proyecto sigue en *Nearest*: un sprite sin material se nota enseguida.
- La escala del shader (píxeles de pantalla por píxel del arte) es el uniform global `pixel_scale` (*Shader Globals*). La calcula `PixelScale.for_window()` (`game/systems/render/`) y la publica `Main` al arrancar y en cada `size_changed` de la ventana. Godot no deja leer un uniform global mientras corre el juego: quien necesite el valor lo recalcula con `PixelScale`.
- No escalar ni rotar sprites de pixel art en el juego: mezcla tamaños de píxel. Si hace falta, se dibuja la variante.
- La luz 2D, las partículas y los efectos salen a la resolución de la pantalla.

## Input

Acciones: `move_left`, `move_right`, `move_up`, `move_down`, `jump`, `dash` (reservado), `pause` (Esc, Start), `debug_toggle` (F3). Teclado y gamepad desde el inicio. Los menús usan las acciones `ui_*` que trae Godot.

## Debug overlay

`game/debug/debug_overlay.tscn` (`DebugOverlay`, `CanvasLayer` en `PROCESS_MODE_ALWAYS`), activable con F3 o Select/Back (`debug_toggle`), también en pausa. Muestra FPS y las líneas de cada sistema registrado: un nodo implementa `get_debug_info() -> Dictionary` y `World` lo registra con `track()`. Hoy: la sala actual ("sala: 2 / 3") y la escala del pixel art, y del personaje: velocidad, "en el piso", estado del motor, hacia dónde mira y sus timers (estado, coyote, buffer). Mientras está visible pide los datos en cada cuadro. Es la herramienta principal del playtest.

## Tooling

- Unit tests: gdUnit4 v6.2.2 en `addons/gdUnit4/`, headless:
  `godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test -c`
- Formato y lint: gdtoolkit (`gdformat`, `gdlint`), aplicado por el hook `.claude/hooks/gd-check.sh` en cada Write/Edit de `.gd`.
- Smoke run: MCP `godot` (`@coding-solo/godot-mcp`) corre el proyecto y lee la consola.
