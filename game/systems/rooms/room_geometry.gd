## Medidas de una sala (decisión D0004): una sala ocupa exactamente una pantalla.
##
## Lógica pura. Son constantes, no tuning: cambiarlas cambia todas las salas, así que
## solo se tocan con una decisión nueva.
class_name RoomGeometry
extends RefCounted

## Bordes de una sala. Sirve para "por dónde salió" y para "de qué lado está la
## entrada o la salida". NONE: no salió.
enum Edge { NONE, LEFT, RIGHT, TOP, BOTTOM }

## Lado de una baldosa, en píxeles.
const TILE_SIZE := 20
## Ancho y alto de una sala, en baldosas.
const COLUMNS := 64
const ROWS := 36
## Tamaño de una sala en píxeles: 1280×720, igual que la pantalla interna del juego.
const SIZE_PX := Vector2(COLUMNS * TILE_SIZE, ROWS * TILE_SIZE)


## Por qué borde salió entero de la sala algo que ocupa el rectángulo bounds.
## Cuenta recién cuando ya no se ve nada de él. Arriba nunca cuenta (devuelve NONE):
## un salto puede asomar por encima de la pantalla y volver.
static func crossed_edge(bounds: Rect2) -> Edge:
	if bounds.end.x < 0.0:
		return Edge.LEFT
	if bounds.position.x > SIZE_PX.x:
		return Edge.RIGHT
	if bounds.position.y > SIZE_PX.y:
		return Edge.BOTTOM
	return Edge.NONE


## true si algo que ocupa el rectángulo bounds salió entero de la sala por algún
## borde que cuenta (ver crossed_edge).
static func is_outside_room(bounds: Rect2) -> bool:
	return crossed_edge(bounds) != Edge.NONE
