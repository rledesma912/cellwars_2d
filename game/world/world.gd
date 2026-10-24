## Partida en curso: arma la sala de prueba con el personaje en su punto de inicio.
##
## Nodo fino: la regla de "cayó fuera de la sala" está en RoomGeometry; acá solo se
## aplica. En la F004 va a cargar distintas salas; en la F005, caer va a ser morir.
class_name World
extends Node2D

@onready var _room: Node2D = %TestRoom
@onready var _player: Player = %Player
@onready var _debug_overlay: DebugOverlay = %DebugOverlay
# Spawn está dentro de la escena de la sala: los nombres únicos (%) solo valen dentro
# de su propia escena, así que se busca a través de la sala.
@onready var _spawn: Marker2D = _room.get_node("Spawn")


func _ready() -> void:
	# Cada nodo hereda el "modo de proceso" de su padre. Main corre siempre, aun en
	# pausa, para poder escuchar Esc; si World heredara eso, nunca se congelaría.
	# Por eso declara explícitamente que se detiene cuando el juego está en pausa.
	# El personaje lo hereda de World: también se congela.
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_player.reset_to(_spawn.position)
	_debug_overlay.track(_player)


func _physics_process(_delta: float) -> void:
	# Provisorio (F003-AC10): si sale de la sala (por el precipicio, la entrada o la
	# salida), vuelve al inicio. En la F004, salir por un costado va a llevar a otra sala.
	if RoomGeometry.is_outside_room(_player.get_bounds()):
		_player.reset_to(_spawn.position)
