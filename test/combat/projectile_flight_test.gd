# Tests de ProjectileFlight (F012). Pasos de 1/60 s, como corre la física de Godot.
extends GdUnitTestSuite

const DT := 1.0 / 60.0
const ORIGIN := Vector2(100, 200)
const GUARD := Vector2(70, 200)


func _flight() -> ProjectileFlight:
	return ProjectileFlight.new(ORIGIN, Vector2.RIGHT, 900.0, 360.0, GUARD)


func test_f012_ac07_flight_ends_at_range_in_24_steps() -> void:
	var flight := _flight()
	var steps := 0
	var segment: ProjectileFlight.Segment
	while steps < 100:
		segment = flight.advance(DT)
		steps += 1
		if steps > 1:
			# Desde el segundo paso, cada tramo mide 15 px (900 px/s ÷ 60).
			assert_float(segment.from.distance_to(segment.to)).is_equal_approx(15.0, 0.001)
		if segment.done:
			break
	assert_int(steps).is_equal(24)
	assert_float(flight.get_travelled()).is_equal_approx(360.0, 0.001)
	assert_vector(segment.to).is_equal_approx(ORIGIN + Vector2(360, 0), Vector2(0.001, 0.001))


func test_f012_ac07_first_segment_starts_at_guard() -> void:
	var segment := _flight().advance(DT)
	assert_vector(segment.from).is_equal(GUARD)
	assert_vector(segment.to).is_equal_approx(ORIGIN + Vector2(15, 0), Vector2(0.001, 0.001))
	assert_bool(segment.done).is_false()


func test_position_follows_segments() -> void:
	var flight := _flight()
	flight.advance(DT)
	var second := flight.advance(DT)
	assert_vector(second.from).is_equal_approx(ORIGIN + Vector2(15, 0), Vector2(0.001, 0.001))
	assert_vector(flight.get_position()).is_equal_approx(second.to, Vector2(0.001, 0.001))
