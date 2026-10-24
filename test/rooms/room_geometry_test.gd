# Tests de RoomGeometry (decisión D0002 y F003-AC10).
extends GdUnitTestSuite


func test_room_size_matches_viewport() -> void:
	assert_int(RoomGeometry.COLUMNS * RoomGeometry.TILE_SIZE).is_equal(640)
	assert_int(RoomGeometry.ROWS * RoomGeometry.TILE_SIZE).is_equal(360)
	assert_that(RoomGeometry.SIZE_PX).is_equal(Vector2(640, 360))
	# El tamaño de la sala tiene que ser el de la pantalla interna del proyecto.
	var viewport := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	assert_that(RoomGeometry.SIZE_PX).is_equal(viewport)


func test_f003_ac10_outside_room() -> void:
	# Rectángulo del personaje (26×40). Cuenta como afuera recién cuando no se ve nada de él.
	var size := Vector2(26, 40)
	# Adentro, o asomando por un borde.
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(100, 300), size))).is_false()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(100, 320), size))).is_false()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(-25, 260), size))).is_false()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(639, 40), size))).is_false()
	# Arriba no cuenta: un salto puede asomar por encima de la pantalla y volver.
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(300, -50), size))).is_false()
	# Entero por debajo (precipicio), por la izquierda (entrada) o por la derecha (salida).
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(100, 360.5), size))).is_true()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(-26.5, 260), size))).is_true()
	assert_bool(RoomGeometry.is_outside_room(Rect2(Vector2(640.5, 40), size))).is_true()
