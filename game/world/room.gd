## Raíz de cada sala: dice de qué lado están su entrada y su salida (F006).
##
## Nodo fino, sin reglas: solo datos que se eligen en el inspector y las posiciones
## de sus marcadores. Qué significa cruzar cada borde lo decide RoomExits.
class_name Room
extends Node2D

## Lado de la entrada. Un @export con un enum aparece en el inspector como lista
## desplegable, así no se puede escribir un lado que no existe.
@export var entrance_side: RoomGeometry.Edge = RoomGeometry.Edge.LEFT
## Lado de la salida. Nunca arriba: asomar por arriba no cuenta como salir.
@export var exit_side: RoomGeometry.Edge = RoomGeometry.Edge.RIGHT


## Dónde quedan los pies de Elyon al entrar (y al volver a empezar la sala).
func entrance_position() -> Vector2:
	# get_node y no @onready: así funciona también con la sala fuera del árbol
	# (precargada o en un test), cuando _ready todavía no corrió.
	return (get_node("Entrance") as Marker2D).position


## Dónde quedan los pies de Elyon al llegar volviendo desde la sala siguiente.
func exit_position() -> Vector2:
	return (get_node("Exit") as Marker2D).position
