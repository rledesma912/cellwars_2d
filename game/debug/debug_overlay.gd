## Panel de debug (F3 o Select/Back): muestra datos del juego mientras se prueba.
##
## Herramienta de desarrollo: sus textos van en castellano, sin traducir. Cada sistema
## que quiera aparecer acá implementa get_debug_info() -> Dictionary y se registra
## con track(). Mientras está visible, el panel pide esos datos en cada cuadro.
class_name DebugOverlay
extends CanvasLayer

var _sources: Array[Node] = []

@onready var _label: Label = %Label


func _ready() -> void:
	# ALWAYS: sigue funcionando en pausa, para poder mirar los datos con el juego quieto.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


## Registra un nodo que tenga get_debug_info().
func track(source: Node) -> void:
	_sources.append(source)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle"):
		visible = not visible
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not visible:
		return
	var lines: PackedStringArray = ["FPS: %d" % Engine.get_frames_per_second()]
	for source in _sources:
		var info: Dictionary = source.get_debug_info()
		for key: String in info:
			lines.append("%s: %s" % [key, info[key]])
	_label.text = "\n".join(lines)
