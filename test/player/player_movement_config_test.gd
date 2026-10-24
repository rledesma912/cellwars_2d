# Tests de PlayerMovementConfig (F003-AC06).
extends GdUnitTestSuite


func test_f003_ac06_derived_gravity_and_jump_velocity() -> void:
	var config := PlayerMovementConfig.new()
	config.jump_height = 80.0
	config.time_to_apex = 0.4
	# gravity = 2·h / t² = 160 / 0.16 = 1000; jump_velocity = 2·h / t = 160 / 0.4 = 400.
	assert_float(config.get_gravity()).is_equal_approx(1000.0, 0.001)
	assert_float(config.get_jump_velocity()).is_equal_approx(400.0, 0.001)


func test_defaults_match_spec() -> void:
	var config := PlayerMovementConfig.new()
	assert_float(config.run_speed).is_equal(140.0)
	assert_float(config.jump_height).is_equal(60.0)
	assert_float(config.time_to_apex).is_equal(0.35)
	assert_float(config.max_fall_speed).is_equal(600.0)
