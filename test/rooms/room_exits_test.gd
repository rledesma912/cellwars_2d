# Tests de RoomExits (F006-AC04, AC05 y AC06).
extends GdUnitTestSuite

const LEFT := RoomGeometry.Edge.LEFT
const RIGHT := RoomGeometry.Edge.RIGHT
const TOP := RoomGeometry.Edge.TOP
const BOTTOM := RoomGeometry.Edge.BOTTOM
const NO_EDGE := RoomGeometry.Edge.NONE


func test_f006_ac04_edge_meaning() -> void:
	var outcome := LevelProgress.Outcome
	# Sala que entra por la izquierda y sale por la derecha.
	assert_int(RoomExits.resolve(RIGHT, LEFT, RIGHT)).is_equal(outcome.NEXT)
	assert_int(RoomExits.resolve(LEFT, LEFT, RIGHT)).is_equal(outcome.PREVIOUS)
	assert_int(RoomExits.resolve(BOTTOM, LEFT, RIGHT)).is_equal(outcome.VOID)
	assert_int(RoomExits.resolve(NO_EDGE, LEFT, RIGHT)).is_equal(outcome.NONE)
	# Sala que sale por abajo: abajo es la sala siguiente, no el vacío.
	assert_int(RoomExits.resolve(BOTTOM, LEFT, BOTTOM)).is_equal(outcome.NEXT)
	# Ahí la derecha no es ni entrada ni salida: tiene pared, no cuenta.
	assert_int(RoomExits.resolve(RIGHT, LEFT, BOTTOM)).is_equal(outcome.NONE)
	# Sala que entra por arriba: los costados no cuentan salvo la salida.
	assert_int(RoomExits.resolve(LEFT, TOP, RIGHT)).is_equal(outcome.NONE)
	assert_int(RoomExits.resolve(RIGHT, TOP, RIGHT)).is_equal(outcome.NEXT)
	assert_int(RoomExits.resolve(BOTTOM, TOP, RIGHT)).is_equal(outcome.VOID)


func test_f006_ac05_arrival_keeps_offset() -> void:
	# Por un costado: x del marcador destino; conserva la altura relativa
	# (salió 30 px por encima de la salida → entra 30 px por encima de la entrada).
	var pos := RoomExits.arrival(RIGHT, Vector2(1310, 400), Vector2(1250, 430), Vector2(30, 500))
	assert_vector(pos).is_equal(Vector2(30, 470))
	# Volviendo por la izquierda, igual pero hacia la salida de la anterior.
	pos = RoomExits.arrival(LEFT, Vector2(-30, 690), Vector2(30, 680), Vector2(1250, 300))
	assert_vector(pos).is_equal(Vector2(1250, 310))
	# Por abajo: y del marcador destino; conserva la distancia horizontal relativa.
	pos = RoomExits.arrival(BOTTOM, Vector2(640, 840), Vector2(600, 760), Vector2(900, 120))
	assert_vector(pos).is_equal(Vector2(940, 120))


func test_f006_ac06_validate_rules() -> void:
	# Válido: izquierda → derecha, izquierda → abajo, arriba → derecha.
	var ok := RoomExits.validate(
		PackedInt32Array([LEFT, LEFT, TOP]), PackedInt32Array([RIGHT, BOTTOM, RIGHT])
	)
	assert_array(Array(ok)).is_empty()
	assert_int(RoomExits.opposite(LEFT)).is_equal(RIGHT)
	assert_int(RoomExits.opposite(TOP)).is_equal(BOTTOM)
	# Una sala puede entrar por la izquierda y salir por abajo (lados distintos).
	var turn := RoomExits.validate(PackedInt32Array([LEFT]), PackedInt32Array([BOTTOM]))
	assert_array(Array(turn)).is_empty()
	# Entrada y salida del mismo lado.
	var bad := RoomExits.validate(PackedInt32Array([LEFT]), PackedInt32Array([LEFT]))
	assert_int(bad.size()).is_equal(1)
	# Vecinas que no encajan: sale por la derecha y la siguiente entra por arriba.
	bad = RoomExits.validate(PackedInt32Array([LEFT, TOP]), PackedInt32Array([RIGHT, BOTTOM]))
	assert_int(bad.size()).is_equal(1)
	# Salida por arriba: no se puede cruzar (arriba no cuenta).
	bad = RoomExits.validate(PackedInt32Array([BOTTOM]), PackedInt32Array([TOP]))
	assert_int(bad.size()).is_equal(1)
	# Entrada por abajo.
	bad = RoomExits.validate(PackedInt32Array([BOTTOM]), PackedInt32Array([RIGHT]))
	assert_int(bad.size()).is_equal(1)
	# Nivel vacío.
	bad = RoomExits.validate(PackedInt32Array(), PackedInt32Array())
	assert_int(bad.size()).is_equal(1)
