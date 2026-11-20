## Vuelo de un proyectil (spec F012): dónde está, cuánto recorrió y qué tramo hay que
## revisar en cada paso.
##
## Lógica pura (sin árbol): no sabe de paredes. El nodo Projectile le pide el tramo de
## cada paso, lanza un rayo por ese tramo y, si choca, se libera. Revisar el tramo
## entero (y no solo el punto final) es lo que evita que atraviese algo fino.
class_name ProjectileFlight
extends RefCounted


## El tramo de un paso: el rayo va de from a to.
class Segment:
	extends RefCounted
	var from: Vector2
	var to: Vector2
	## Con este tramo llega a su alcance: después de revisarlo, el proyectil termina.
	var done := false


var _position: Vector2
var _direction: Vector2
var _speed: float
var _range: float
var _travelled := 0.0
## Punto de resguardo: el primer tramo arranca acá (el centro de Elyon a la altura de
## la boca), así un tiro con la boca metida en una pared choca en el acto.
var _guard: Vector2
var _first := true


## origin: boca del arma. direction: largo 1. range: distancia máxima desde la boca.
func _init(
	origin: Vector2, direction: Vector2, speed: float, max_range: float, guard: Vector2
) -> void:
	_position = origin
	_direction = direction
	_speed = speed
	_range = max_range
	_guard = guard


func advance(delta: float) -> Segment:
	var segment := Segment.new()
	segment.from = _guard if _first else _position
	_first = false
	# El último paso se recorta para terminar justo en el alcance.
	var step := minf(_speed * delta, _range - _travelled)
	_position += _direction * step
	_travelled += step
	segment.to = _position
	segment.done = _travelled >= _range
	return segment


func get_travelled() -> float:
	return _travelled


func get_position() -> Vector2:
	return _position
