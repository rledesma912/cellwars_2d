## Partida en curso: arma el nivel sala por sala, con Elyon pasando de una a otra.
##
## Nodo fino: qué borde cruzó lo dice RoomGeometry, qué significa en esta sala lo
## dice RoomExits, a qué sala va lo dice LevelProgress y dónde aparece lo calcula
## RoomExits. Acá solo se aplica: se cambia la sala y se mueve al personaje.
class_name World
extends Node2D

## El nivel que se juega: la lista ordenada de salas.
@export var level: LevelData

var _progress: LevelProgress
## La sala que está en pantalla.
var _room: Room
## Salas ya instanciadas, por índice: la actual y sus vecinas (precargadas).
var _rooms: Dictionary[int, Room] = {}

@onready var _player: Player = %Player
@onready var _debug_overlay: DebugOverlay = %DebugOverlay


func _ready() -> void:
	# Cada nodo hereda el "modo de proceso" de su padre. Main corre siempre, aun en
	# pausa, para poder escuchar Esc; si World heredara eso, nunca se congelaría.
	# Por eso declara explícitamente que se detiene cuando el juego está en pausa.
	# El personaje y las salas lo heredan de World: también se congelan.
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_progress = LevelProgress.new(level.rooms.size())
	_show_room(0)
	_player.reset_to(_room.entrance_position())
	_debug_overlay.track(_player)
	_debug_overlay.track(self)


# El padre corre su _physics_process antes que sus hijos: acá se mira dónde quedó
# Elyon en el paso anterior, antes de que se mueva en este.
func _physics_process(_delta: float) -> void:
	var edge := RoomGeometry.crossed_edge(_player.get_bounds())
	var outcome := RoomExits.resolve(edge, _room.entrance_side, _room.exit_side)
	var change := _progress.apply(outcome)
	if change == null:
		return
	if not change.keep_motion:
		# Vacío o bordes de la lista: vuelve quieto a una entrada.
		_show_room(change.room_index)
		_player.reset_to(_room.entrance_position())
		return
	# Pasa a una sala vecina. Solo cambia la posición: velocidad, estado del motor y
	# hacia dónde mira siguen igual, así un salto o una carrera siguen del otro lado.
	var crossed := (
		_room.exit_position()
		if outcome == LevelProgress.Outcome.NEXT
		else _room.entrance_position()
	)
	_show_room(change.room_index)
	var target := (
		_room.entrance_position()
		if change.arrival == LevelProgress.Arrival.ENTRANCE
		else _room.exit_position()
	)
	_player.position = RoomExits.arrival(edge, _player.position, crossed, target)


# Al salir de la partida (volver al menú), las salas precargadas que no están en
# pantalla no son hijas de nadie: hay que liberarlas a mano o quedan en memoria.
func _exit_tree() -> void:
	for room: Room in _rooms.values():
		if is_instance_valid(room) and not room.is_inside_tree():
			room.free()
	_rooms.clear()


## Datos para el overlay de debug (F3): en qué sala está y la escala que usa el
## shader de suavizado.
func get_debug_info() -> Dictionary:
	# Godot no deja leer un uniform global fuera del editor: se recalcula con la
	# misma función que usa Main para publicarlo.
	var window := get_window()
	var pixel_scale := PixelScale.for_window(window.size, window.content_scale_size)
	return {
		"sala": "%d / %d" % [_progress.index + 1, _progress.count],
		"escala pixel art": "×%.2f" % pixel_scale,
	}


# Pone en pantalla la sala index y deja precargadas sus vecinas.
func _show_room(index: int) -> void:
	var room := _room_at(index)
	if room != _room:
		# remove_child y no queue_free: la sala sigue viva fuera del árbol, lista
		# para volver a ponerla si Elyon regresa.
		if _room:
			remove_child(_room)
		add_child(room)
		# Primer hijo: se dibuja detrás de Elyon.
		move_child(room, 0)
		_room = room
	_keep_neighbors(index)


# La sala index, instanciada ahora si todavía no estaba precargada.
func _room_at(index: int) -> Room:
	if not _rooms.has(index):
		_rooms[index] = level.rooms[index].instantiate() as Room
	return _rooms[index]


# Precarga la anterior y la siguiente; libera las que dejaron de ser vecinas.
# instantiate() fuera del árbol crea los nodos sin dibujarlos ni darles física:
# cuando Elyon cruce, la sala ya está armada y el cambio es solo sacar y poner.
func _keep_neighbors(index: int) -> void:
	for i: int in _rooms.keys():
		if absi(i - index) > 1:
			_rooms[i].free()
			_rooms.erase(i)
	for i in [index - 1, index + 1]:
		if i >= 0 and i < level.rooms.size():
			_room_at(i)
