## Qué significa cada borde en una sala y dónde aparece Elyon en la sala nueva (F006).
##
## Lógica pura, solo funciones estáticas. Cada sala tiene su entrada y su salida en
## lados distintos; las salas no conocen a sus vecinas.
class_name RoomExits
extends RefCounted


## Qué significa haber cruzado edge en una sala con esa entrada y esa salida:
## la salida lleva a la siguiente, la entrada a la anterior y abajo (si no es la
## salida) es el vacío. Cualquier otro borde no cuenta: las salas tienen pared ahí.
static func resolve(
	edge: RoomGeometry.Edge, entrance_side: RoomGeometry.Edge, exit_side: RoomGeometry.Edge
) -> LevelProgress.Outcome:
	if edge == RoomGeometry.Edge.NONE:
		return LevelProgress.Outcome.NONE
	if edge == exit_side:
		return LevelProgress.Outcome.NEXT
	if edge == entrance_side:
		return LevelProgress.Outcome.PREVIOUS
	if edge == RoomGeometry.Edge.BOTTOM:
		return LevelProgress.Outcome.VOID
	return LevelProgress.Outcome.NONE


## Dónde quedan los pies de Elyon en la sala nueva. Aparece en el marcador destino
## y conserva su desplazamiento respecto del marcador que cruzó: la altura en un
## paso por un costado, la distancia horizontal en un paso por abajo.
static func arrival(
	edge: RoomGeometry.Edge, feet: Vector2, crossed_marker: Vector2, target_marker: Vector2
) -> Vector2:
	var offset := feet - crossed_marker
	if edge == RoomGeometry.Edge.BOTTOM or edge == RoomGeometry.Edge.TOP:
		return Vector2(target_marker.x + offset.x, target_marker.y)
	return Vector2(target_marker.x, target_marker.y + offset.y)


## El lado opuesto: izquierda ↔ derecha, arriba ↔ abajo.
static func opposite(side: RoomGeometry.Edge) -> RoomGeometry.Edge:
	match side:
		RoomGeometry.Edge.LEFT:
			return RoomGeometry.Edge.RIGHT
		RoomGeometry.Edge.RIGHT:
			return RoomGeometry.Edge.LEFT
		RoomGeometry.Edge.TOP:
			return RoomGeometry.Edge.BOTTOM
		RoomGeometry.Edge.BOTTOM:
			return RoomGeometry.Edge.TOP
	return RoomGeometry.Edge.NONE


## Revisa un nivel a partir de la entrada y la salida de cada sala, en orden.
## En cada sala, entrada y salida en lados distintos, la salida no arriba y la
## entrada no abajo. Entre vecinas, la siguiente entra por el lado opuesto a la
## salida de la anterior.
## Devuelve un texto por cada problema; vacío si está bien.
static func validate(entrances: PackedInt32Array, exits: PackedInt32Array) -> PackedStringArray:
	var errors := PackedStringArray()
	if entrances.is_empty() or entrances.size() != exits.size():
		errors.append("el nivel necesita al menos una sala, con entrada y salida cada una")
		return errors
	for i in entrances.size():
		var entrance := entrances[i] as RoomGeometry.Edge
		var exit := exits[i] as RoomGeometry.Edge
		if exit == RoomGeometry.Edge.TOP or exit == RoomGeometry.Edge.NONE:
			# Arriba no cuenta como salir (un salto puede asomar): no se puede usar.
			errors.append("sala %d: la salida no puede estar arriba ni faltar" % (i + 1))
		elif entrance == RoomGeometry.Edge.BOTTOM:
			# Para entrar por abajo, la anterior tendría que salir por arriba.
			errors.append("sala %d: la entrada no puede estar abajo" % (i + 1))
		elif entrance == exit or entrance == RoomGeometry.Edge.NONE:
			errors.append("sala %d: entrada y salida tienen que estar en lados distintos" % (i + 1))
		elif i + 1 < entrances.size() and entrances[i + 1] != opposite(exit):
			errors.append("salas %d y %d: no encajan" % [i + 1, i + 2])
	return errors
