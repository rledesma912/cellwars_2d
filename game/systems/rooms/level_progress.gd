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

# Sala a la que se vuelve después de morir.
var _checkpoint: int = 0


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


## true si ese borde termina el nivel: la salida de la última sala es el refugio.
func finishes_level(outcome: Outcome) -> bool:
	return outcome == Outcome.NEXT and index == count - 1


## Aplica lo que pasó en el borde y devuelve el cambio, o null si no cambia de sala.
## "falling": cruzó cayendo. El checkpoint no avanza hasta que confirm_checkpoint() diga
## que aterrizó vivo: si la caída lo mata, vuelve a la sala donde empezó (F010).
func apply(outcome: Outcome, falling := false) -> RoomChange:
	match outcome:
		Outcome.NEXT:
			if index < count - 1:
				index += 1
				if not falling:
					_checkpoint = index
				return RoomChange.new(index, Arrival.ENTRANCE, true)
			# Salida de la última sala: no cambia de sala. Termina el nivel (finishes_level).
			return null
		Outcome.PREVIOUS:
			if index > 0:
				index -= 1
				_checkpoint = index
				return RoomChange.new(index, Arrival.EXIT, true)
			# Entrada de la sala 1: no hay sala anterior.
			return _restart_at(0)
	# El vacío no cambia de sala acá: mata, y al terminar la muerte vuelve con checkpoint().
	return null


## Elyon pisa el suelo en la sala actual: desde ahora es su checkpoint.
func confirm_checkpoint() -> void:
	_checkpoint = index


## Adónde vuelve después de morir: la entrada de la sala del checkpoint, quieto.
func checkpoint() -> RoomChange:
	return _restart_at(_checkpoint)


## Número de sala del checkpoint, para el overlay de debug.
func checkpoint_index() -> int:
	return _checkpoint


# Vuelve quieto a la entrada de una sala.
func _restart_at(room_index: int) -> RoomChange:
	index = room_index
	_checkpoint = room_index
	return RoomChange.new(index, Arrival.ENTRANCE, false)
