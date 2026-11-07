## Proyectil visible del prototipo S003.
##
## No es un Area2D: en cada paso de física lanza un rayo desde donde estaba hasta donde
## va a estar. Así no "atraviesa" un blanco fino aunque avance muchos píxeles por paso
## (con un Area2D, a 900 px/s avanza 15 px por paso y podría saltearlo).
extends Node2D

var direction := Vector2.RIGHT
var speed := 900.0
var max_distance := 360.0
var mask := 0
var exclude: Array[RID] = []

var _travelled := 0.0


func _ready() -> void:
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	var step := minf(speed * delta, max_distance - _travelled)
	var to := global_position + direction * step
	var hit := ShotCaster.cast(get_world_2d(), global_position, to, mask, exclude)
	if not hit.is_empty():
		global_position = hit.position
		ShotCaster.apply_hit(hit)
		queue_free()
		return
	global_position = to
	_travelled += step
	if _travelled >= max_distance:
		queue_free()


func _draw() -> void:
	# Dibujado mirando a la derecha; rotation lo orienta según la dirección.
	draw_rect(Rect2(-10, -2, 12, 4), Color(1.0, 0.95, 0.4))
