## Spike 001: escena del prototipo. Cambia variante, sala y snap a píxel con teclas.
##
## Teclas (solo del prototipo, leídas directo y no desde el Input Map):
## 1/2/3 variante A/B/C · Tab cambia de sala · R vuelve al inicio · P snap a píxel.
extends Node2D

const VARIANTS: Array[Spike001Config] = [
	preload("res://prototypes/spike_001/variant_a.tres"),
	preload("res://prototypes/spike_001/variant_b.tres"),
	preload("res://prototypes/spike_001/variant_c.tres"),
]
const ROOMS: Array[PackedScene] = [
	preload("res://game/levels/test/test_room.tscn"),
	preload("res://prototypes/spike_001/challenge_room.tscn"),
]

var _room_index := 0
var _room: Node2D
var _hint: Label

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
		KEY_1, KEY_2, KEY_3:
			_soldier.set_config(VARIANTS[key.keycode - KEY_1])
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
		"Variante %s  ·  1/2/3 variante · Tab sala · R reinicia · P snap · F3 datos"
		% _soldier.motor.config.variant_name
	)


func _respawn() -> void:
	_soldier.reset_to(_room.get_node("Spawn").position)


func get_debug_info() -> Dictionary:
	return {
		"sala": "prueba F003" if _room_index == 0 else "desafíos",
		"snap a píxel": "sí" if get_viewport().snap_2d_transforms_to_pixel else "no",
	}
