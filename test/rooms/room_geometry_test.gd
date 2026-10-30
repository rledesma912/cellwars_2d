# Tests de RoomGeometry (decisión D0004, F005-AC01 y F003-AC10).
extends GdUnitTestSuite


func test_f005_ac01_room_matches_viewport() -> void:
	assert_int(RoomGeometry.TILE_SIZE).is_equal(20)
	assert_int(RoomGeometry.COLUMNS).is_equal(64)
	assert_int(RoomGeometry.ROWS).is_equal(36)
	assert_that(RoomGeometry.SIZE_PX).is_equal(Vector2(1280, 720))
	# El tamaño de la sala tiene que ser el de la pantalla interna del proyecto.
	var viewport := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	assert_that(RoomGeometry.SIZE_PX).is_equal(viewport)


func test_f003_ac10_outside_room() -> void:
	# Rectángulo del personaje (44×106, D0004). Cuenta como afuera recién cuando no se
	# ve nada de él.
	var size := Vector2(44, 106)
	# Adentro, o asomando por un borde.
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(200, 560), size))).is_false()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(200, 650), size))).is_false()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(-43, 500), size))).is_false()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(1279, 80), size))).is_false()
	# Arriba no cuenta: un salto puede asomar por encima de la pantalla y volver.
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(600, -120), size))).is_false()
	# Entero por debajo (precipicio), por la izquierda (entrada) o por la derecha (salida).
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(200, 720.5), size))).is_true()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(-44.5, 500), size))).is_true()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(1280.5, 80), size))).is_true()


func test_f006_ac03_crossed_edge() -> void:
	var size := Vector2(44, 106)
	var edge := func(pos: Vector2) -> RoomGeometry.Edge:
		return RoomGeometry.crossed_edge(Rect2(pos, size))
	# Adentro o asomando: ningún borde.
	assert_int(edge.call(Vector2(200, 560))).is_equal(RoomGeometry.Edge.NONE)
	assert_int(edge.call(Vector2(-43, 500))).is_equal(RoomGeometry.Edge.NONE)
	assert_int(edge.call(Vector2(1279, 80))).is_equal(RoomGeometry.Edge.NONE)
	assert_int(edge.call(Vector2(200, 650))).is_equal(RoomGeometry.Edge.NONE)
	# Arriba no cuenta, ni siquiera entero afuera.
	assert_int(edge.call(Vector2(600, -120))).is_equal(RoomGeometry.Edge.NONE)
	# Entero afuera por cada borde que cuenta.
	assert_int(edge.call(Vector2(-44.5, 500))).is_equal(RoomGeometry.Edge.LEFT)
	assert_int(edge.call(Vector2(1280.5, 80))).is_equal(RoomGeometry.Edge.RIGHT)
	assert_int(edge.call(Vector2(200, 720.5))).is_equal(RoomGeometry.Edge.BOTTOM)
