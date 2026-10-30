## Medidas de una sala (decisión D0004): una sala ocupa exactamente una pantalla.
##
## Lógica pura. Son constantes, no tuning: cambiarlas cambia todas las salas, así que
## solo se tocan con una decisión nueva.
class_name RoomGeometry
extends RefCounted

## Lado de una baldosa, en píxeles.
const TILE_SIZE := 20
## Ancho y alto de una sala, en baldosas.
const COLUMNS := 64
const ROWS := 36
## Tamaño de una sala en píxeles: 1280×720, igual que la pantalla interna del juego.
const SIZE_PX := Vector2(COLUMNS * TILE_SIZE, ROWS * TILE_SIZE)


## true si algo que ocupa el rectángulo bounds salió entero de la sala: por debajo
## (precipicio) o por un costado (entrada o salida). Cuenta recién cuando ya no se ve
## nada de él. Arriba no cuenta: un salto puede asomar por encima de la pantalla.
static func is_outside_room(bounds: Rect2) -> bool:
	return bounds.position.y > SIZE_PX.y or bounds.end.x < 0.0 or bounds.position.x > SIZE_PX.x
