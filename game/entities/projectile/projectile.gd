## Proyectil de Elyon (spec F012).
##
## Nodo fino: ProjectileFlight dice qué tramo recorre en cada paso y acá se pregunta a
## la física si hay algo en ese tramo. No es un Area2D: un Area2D solo ve lo que ya se
## superpone, y a 15 px por paso podría saltearse algo fino; el rayo revisa el tramo
## entero. Tampoco es un cuerpo (no usa move_and_slide): se mueve cambiando la posición.
class_name Projectile
extends Node2D

## Capas que frenan el tiro (máscara de bits): la 1, "mundo" (paredes, pisos, techos).
const HIT_MASK := 1
## Tamaño del dibujo (greybox), mirando a la derecha.
const SIZE := Vector2(12, 4)
const COLOR := Color(1.0, 0.95, 0.4)

var _flight: ProjectileFlight
var _exclude: Array[RID] = []


## Lo prepara antes de agregarlo al árbol. shooter: el cuerpo que disparó, para que el
## rayo no choque con él.
func launch(
	config: ShootConfig,
	origin: Vector2,
	direction: Vector2,
	guard_from: Vector2,
	shooter: CollisionObject2D
) -> void:
	_flight = ProjectileFlight.new(
		origin, direction, config.projectile_speed, config.shot_range, guard_from
	)
	position = origin
	# rotation gira el dibujo para que apunte hacia donde vuela.
	rotation = direction.angle()
	_exclude = [shooter.get_rid()]
	# Invisible hasta revisar su primer tramo: pegado a una pared, la boca queda dentro
	# de la pared y se vería un cuadro ahí antes de chocar.
	visible = false


func _physics_process(delta: float) -> void:
	var segment := _flight.advance(delta)
	# Consulta de rayo por código: solo es segura dentro de _physics_process, porque
	# fuera de él el espacio de física está bloqueado. La posición es la del mundo
	# (global): el contenedor de proyectiles está en el origen, así que coincide.
	var query := PhysicsRayQueryParameters2D.create(segment.from, segment.to, HIT_MASK, _exclude)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		queue_free()
		return
	position = segment.to
	visible = true
	if segment.done:
		queue_free()


func _draw() -> void:
	# Termina en el origen del nodo: la punta del proyectil es su posición.
	draw_rect(Rect2(Vector2(-SIZE.x, -SIZE.y / 2.0), SIZE), COLOR)
