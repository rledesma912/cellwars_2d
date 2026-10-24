---
id: ARCH
type: architecture
status: approved
superseded_by:
links: { gdd: [], decisions: [], spike: }
updated: 2026-10-24
---

# Arquitectura

> Documento vivo. Decisiones técnicas transversales vigentes. Cuando una decisión de `decisions/` cambia algo de acá, se reescribe esta página (sin dejar la versión anterior).

## Regla central: lógica pura + nodo fino + config en Resource

- **Lógica pura**: las reglas de juego viven en clases `RefCounted` sin dependencia del árbol de escenas, en `game/systems/`. Son las únicas con unit tests (gdUnit4); `test/` es espejo de `game/systems/`.
- **Nodo fino**: los nodos (`CharacterBody2D`, `Area2D`…) en `game/entities/` leen input, llaman a la lógica pura y aplican el resultado. No contienen reglas.
- **Config en Resource**: todo parámetro ajustable es un Resource tipado con `@export` (p. ej. `PlayerMovementConfig`), instanciado como `.tres` en `game/data/`. Lo edita el desarrollador en el inspector.

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
- Pausa: `get_tree().paused`. `Main` corre en `PROCESS_MODE_ALWAYS`; `World` declara `PROCESS_MODE_PAUSABLE` explícitamente (si no, heredaría `ALWAYS`).

## Textos e idiomas

- Cada texto visible es una etiqueta (`MENU_PLAY`) en `game/i18n/texts.csv`, con columnas `es` y `en`, registrada en *Localization → Translations*. Idioma de respaldo: `en`.
- Los nodos con `text` fijo se traducen solos; el texto armado por código usa `tr("ETIQUETA")`.
- Los `.translation` que genera la importación del CSV no se versionan (`.gitignore`).

## Comunicación

- Entre sistemas, por señales. Evitar `get_node()` con rutas largas.
- Autoloads: como máximo un bus de eventos y el estado global del juego.

## Física

- 60 ticks por segundo (default de Godot). El movimiento se calcula en `_physics_process`.

## Render y resolución

| Parámetro | Valor | Estado |
|---|---|---|
| Renderer | `gl_compatibility` | Vigente |
| Viewport | 640×360, ventana 1280×720 | A validar en Spike 001 (alternativa: 960×540) |
| Stretch | `viewport`, aspect `keep`, scale `integer` | Vigente |
| Filtro de texturas | Nearest | Vigente |
| `snap_2d_transforms_to_pixel` | `true` | A validar en Spike 001 (posible jitter con `Camera2D` suavizada) |
| Tile | 32 px | Vigente |
| Display driver Linux | Wayland (`display_server/driver.linuxbsd`) | Vigente: el entorno del agente no tiene X11 |

## Input

Acciones: `move_left`, `move_right`, `move_up`, `move_down`, `jump`, `dash` (reservado), `pause` (Esc, Start), `debug_toggle` (F3). Teclado y gamepad desde el inicio. Los menús usan las acciones `ui_*` que trae Godot.

## Debug overlay

`game/debug/debug_overlay.tscn`, activable con F3 (`debug_toggle`). Muestra estado del jugador, velocidad, `is_on_floor`, timers (coyote, buffer) y FPS. Cada sistema nuevo agrega sus líneas. Es la herramienta principal del playtest.

## Tooling

- Unit tests: gdUnit4 v6.2.2 en `addons/gdUnit4/`, headless:
  `godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test -c`
- Formato y lint: gdtoolkit (`gdformat`, `gdlint`), aplicado por el hook `.claude/hooks/gd-check.sh` en cada Write/Edit de `.gd`.
- Smoke run: MCP `godot` (`@coding-solo/godot-mcp`) corre el proyecto y lee la consola.
