## Consulta de rayo compartida por el rayo instantáneo y el proyectil (prototipo S003).
class_name ShotCaster
extends RefCounted


## Lanza un rayo de from a to y devuelve el primer choque ({} si no pegó). Solo es
## seguro dentro de _physics_process: fuera de él, el espacio de física está bloqueado.
static func cast(
	world: World2D, from: Vector2, to: Vector2, mask: int, exclude: Array[RID]
) -> Dictionary:
	var query := PhysicsRayQueryParameters2D.create(from, to, mask, exclude)
	return world.direct_space_state.intersect_ray(query)


## Si lo que chocó es un blanco, le avisa.
static func apply_hit(hit: Dictionary) -> void:
	var collider: Object = hit.collider
	if collider != null and collider.has_method("hit"):
		collider.hit()
