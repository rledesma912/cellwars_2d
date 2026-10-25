## Spike 001: escena del prototipo. Cambia variante, sala y snap a píxel con teclas.
##
## Teclas (solo del prototipo, leídas directo y no desde el Input Map):
## 1/2/3/4 variante A/B/C/C48 · S aspecto (silueta, Elyon 40, Elyon 48) · Tab sala ·
## R vuelve al inicio · P snap a píxel.
extends Node2D

const VARIANTS: Array[Spike001Config] = [
	preload("res://prototypes/spike_001/variant_a.tres"),
	preload("res://prototypes/spike_001/variant_b.tres"),
	preload("res://prototypes/spike_001/variant_c.tres"),
	preload("res://prototypes/spike_001/variant_c48.tres"),
]
# Aspectos: cuadros, pies dentro del cuadro y alto del cuerpo. Elyon sale de las imágenes
# generadas con ComfyUI (prototypes/spike_001/comfy/).
const LOOKS := [
	["silueta", "res://prototypes/spike_001/silhouette_frames.tres", Vector2(16, 47), 40.0],
	["Elyon 40", "res://prototypes/spike_001/elyon_40_frames.tres", Vector2(32, 63), 40.0],
	["Elyon 48", "res://prototypes/spike_001/elyon_48_frames.tres", Vector2(32, 63), 48.0],
]
const ROOMS: Array[PackedScene] = [
	preload("res://game/levels/test/test_room.tscn"),
	preload("res://prototypes/spike_001/challenge_room.tscn"),
]

var _room_index := 0
var _room: Node2D
var _hint: Label
var _look_index := 0

@onready var _soldier: Spike001Soldier = %Soldier
@onready var _debug_overlay: DebugOverlay = %DebugOverlay
@onready var _rooms: Node2D = %Rooms


func _ready() -> void:
	_soldier.set_config(VARIANTS[0])
	_load_room(0)
	_debug_overlay.track(_soldier)
	_debug_overlay.track(self)
	_add_hint()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_1, KEY_2, KEY_3, KEY_4:
			_soldier.set_config(VARIANTS[key.keycode - KEY_1])
			_update_hint()
		KEY_S:
			_look_index = (_look_index + 1) % LOOKS.size()
			var look: Array = LOOKS[_look_index]
			_soldier.set_look(load(look[1]), look[2], look[3])
			_respawn()
			_update_hint()
		KEY_TAB:
			_load_room((_room_index + 1) % ROOMS.size())
		KEY_R:
			_respawn()
		KEY_P:
			var viewport := get_viewport()
			viewport.snap_2d_transforms_to_pixel = not viewport.snap_2d_transforms_to_pixel


func _physics_process(_delta: float) -> void:
	if RoomGeometry.is_outside_room(_soldier.get_bounds()):
		_respawn()


func _load_room(index: int) -> void:
	if _room:
		_room.queue_free()
	_room_index = index
	_room = ROOMS[index].instantiate()
	_rooms.add_child(_room)
	_respawn()


# Línea fija abajo con la variante y las teclas. El overlay F3 tapa la entrada de la
# sala de desafíos, así que arranca cerrado y esto queda siempre a la vista.
func _add_hint() -> void:
	var layer := CanvasLayer.new()
	_hint = Label.new()
	_hint.position = Vector2(4, 344)
	_hint.add_theme_font_size_override("font_size", 10)
	_hint.add_theme_constant_override("outline_size", 4)
	_hint.add_theme_color_override("font_outline_color", Color.BLACK)
	layer.add_child(_hint)
	add_child(layer)
	_update_hint()


func _update_hint() -> void:
	_hint.text = (
		"%s · variante %s  ·  S aspecto · 1-4 variante · Tab sala · R reinicia · F3 datos"
		% [LOOKS[_look_index][0], _soldier.motor.config.variant_name]
	)


func _respawn() -> void:
	_soldier.reset_to(_room.get_node("Spawn").position)


func get_debug_info() -> Dictionary:
	return {
		"sala": "prueba F003" if _room_index == 0 else "desafíos",
		"snap a píxel": "sí" if get_viewport().snap_2d_transforms_to_pixel else "no",
	}
