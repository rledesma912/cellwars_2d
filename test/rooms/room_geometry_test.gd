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


func test_f003_ac10_below_room() -> void:
	# Se mide el borde de arriba del personaje: afuera es cuando ya no se ve nada de él.
	assert_bool(RoomGeometry.is_below_room(100.0)).is_false()
	assert_bool(RoomGeometry.is_below_room(360.0)).is_false()
	assert_bool(RoomGeometry.is_below_room(360.5)).is_true()
	assert_bool(RoomGeometry.is_below_room(1000.0)).is_true()
