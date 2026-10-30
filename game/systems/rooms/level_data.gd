## Un nivel: la lista ordenada de sus salas (F006).
##
## Es contenido, no tuning: cada nivel tiene su .tres en game/levels/. La salida de
## una sala lleva a la siguiente de la lista y la entrada, a la anterior.
class_name LevelData
extends Resource

## Las salas, en orden. Cada una es una escena con el script Room en su raíz.
## Un .tres que referencia escenas las carga junto con él: al abrir el nivel, todas
## sus salas ya están en memoria (falta solo instanciarlas).
@export var rooms: Array[PackedScene] = []
