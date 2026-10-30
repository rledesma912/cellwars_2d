# Tests de PixelScale (decisión D0004, F005-AC02).
extends GdUnitTestSuite

const BASE := Vector2i(1280, 720)


func test_f005_ac02_pixel_scale_for_window() -> void:
	# Pantallas 16:9: la escala es exacta.
	assert_float(PixelScale.for_window(Vector2i(1920, 1080), BASE)).is_equal_approx(1.5, 0.0001)
	assert_float(PixelScale.for_window(Vector2i(1280, 720), BASE)).is_equal_approx(1.0, 0.0001)
	assert_float(PixelScale.for_window(Vector2i(2560, 1440), BASE)).is_equal_approx(2.0, 0.0001)
	assert_float(PixelScale.for_window(Vector2i(3840, 2160), BASE)).is_equal_approx(3.0, 0.0001)
	# Laptop común: 1366 / 1280 ≈ 1,067 y 768 / 720 ≈ 1,067; manda el menor.
	assert_float(PixelScale.for_window(Vector2i(1366, 768), BASE)).is_equal_approx(1.0667, 0.0001)
	# Más ancha que 16:9: manda el alto (bordes a los costados).
	assert_float(PixelScale.for_window(Vector2i(2560, 1080), BASE)).is_equal_approx(1.5, 0.0001)
	# Ventana más chica que la resolución interna: escala menor a 1.
	assert_float(PixelScale.for_window(Vector2i(960, 540), BASE)).is_equal_approx(0.75, 0.0001)
