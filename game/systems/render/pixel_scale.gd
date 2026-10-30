## Escala del pixel art (decisión D0004): cuántos píxeles de pantalla ocupa cada
## píxel del arte.
##
## Lógica pura. Con stretch "canvas_items" y aspecto "keep", Godot agranda la escena
## lo justo para que entre entera en la ventana: el menor de los dos cocientes. El
## shader de suavizado necesita ese mismo número.
class_name PixelScale
extends RefCounted


## Escala para una ventana de window_size con resolución interna base_size.
static func for_window(window_size: Vector2i, base_size: Vector2i) -> float:
	return minf(float(window_size.x) / base_size.x, float(window_size.y) / base_size.y)
