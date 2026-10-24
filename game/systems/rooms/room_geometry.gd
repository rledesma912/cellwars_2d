## Medidas de una sala (decisión D0002): una sala ocupa exactamente una pantalla.
##
## Lógica pura. Son constantes, no tuning: cambiarlas cambia todas las salas, así que
## solo se tocan con una decisión nueva.
class_name RoomGeometry
extends RefCounted

## Lado de una baldosa, en píxeles.
const TILE_SIZE := 20
## Ancho y alto de una sala, en baldosas.
const COLUMNS := 32
const ROWS := 18
## Tamaño de una sala en píxeles: 640×360, igual que la pantalla interna del juego.
const SIZE_PX := Vector2(COLUMNS * TILE_SIZE, ROWS * TILE_SIZE)


## true si algo cuyo borde de arriba está en top_y quedó entero por debajo de la sala.
## Recibe el borde de arriba (y no el centro) para que cuente como "afuera" recién
## cuando ya no se ve nada.
static func is_below_room(top_y: float) -> bool:
	return top_y > SIZE_PX.y
