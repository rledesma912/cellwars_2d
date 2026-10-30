## En qué sala del nivel está Elyon y a cuál va al cruzar un borde (F006).
##
## Lógica pura. El nivel es una lista ordenada de salas: la salida lleva a la
## siguiente y la entrada a la anterior. No sabe nada de escenas ni de nodos.
class_name LevelProgress
extends RefCounted

## Qué significa el borde que cruzó, según la sala (lo decide RoomExits.resolve).
enum Outcome { NONE, NEXT, PREVIOUS, VOID }
## A qué marcador de la sala destino llega.
enum Arrival { ENTRANCE, EXIT }

## Índice de la sala actual, desde 0.
var index: int = 0
## Cantidad de salas del nivel.
var count: int


## Un cambio de sala: a qué sala va, a qué marcador llega y si sigue con el mismo
## movimiento (velocidad y dirección) o vuelve quieto.
class RoomChange:
	var room_index: int
	var arrival: Arrival
	var keep_motion: bool

	func _init(p_room_index: int, p_arrival: Arrival, p_keep_motion: bool) -> void:
		room_index = p_room_index
		arrival = p_arrival
		keep_motion = p_keep_motion


func _init(p_count: int) -> void:
	count = p_count


## Aplica lo que pasó en el borde y devuelve el cambio, o null si no cambia nada.
func apply(outcome: Outcome) -> RoomChange:
	match outcome:
		Outcome.NEXT:
			if index < count - 1:
				index += 1
				return RoomChange.new(index, Arrival.ENTRANCE, true)
			# Salida de la última sala: provisorio hasta que exista el refugio.
			return _restart_at(0)
		Outcome.PREVIOUS:
			if index > 0:
				index -= 1
				return RoomChange.new(index, Arrival.EXIT, true)
			# Entrada de la sala 1: no hay sala anterior.
			return _restart_at(0)
		Outcome.VOID:
			return _restart_at(index)
	return null


# Vuelve quieto a la entrada de una sala.
func _restart_at(room_index: int) -> RoomChange:
	index = room_index
	return RoomChange.new(index, Arrival.ENTRANCE, false)
