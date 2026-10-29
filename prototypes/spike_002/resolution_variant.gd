## Una resolución a comparar en el spike 002 (código descartable).
##
## Todo lo que cambia entre resoluciones vive acá, para editarlo en el inspector
## sin tocar código. La baldosa es siempre de 20 px.
class_name ResolutionVariant
extends Resource

## Nombre para el cartel de ayuda.
@export var label: String = "640×360"
## Resolución interna: el tamaño de la "pantalla chica" donde se dibuja todo.
@export var base_size: Vector2i = Vector2i(640, 360)
## Cuánto más grande es Elyon que en 640×360. Multiplica distancias y velocidades
## del movimiento; los tiempos no cambian (así el feel debería ser el mismo).
@export_range(1.0, 3.0, 0.05) var elyon_scale: float = 1.0
## Hoja de sprites de Elyon dibujada a este tamaño (no agrandada), con su .json al lado.
@export_file("*.png") var sheet_path: String = ""
## Alto de cada escalón, en baldosas.
@export_range(1, 8) var step_tiles: int = 2
