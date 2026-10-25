# Tests de PlayerMovementConfig (F004-AC17).
extends GdUnitTestSuite


func test_f004_ac17_derived_values() -> void:
	var config := PlayerMovementConfig.new()
	config.jump_height = 80.0
	config.min_jump_height = 20.0
	config.time_to_apex = 0.4
	config.fall_gravity_scale = 1.5
	config.run_speed = 120.0
	config.accel_time = 0.2
	config.decel_time = 0.1
	# gravedad = 2·h / t² = 160 / 0.16 = 1000; velocidad de salto = 2·h / t = 160 / 0.4 = 400.
	assert_float(config.get_gravity()).is_equal_approx(1000.0, 0.001)
	assert_float(config.get_fall_gravity()).is_equal_approx(1500.0, 0.001)
	assert_float(config.get_jump_velocity()).is_equal_approx(400.0, 0.001)
	# velocidad de corte = √(2·g·min_h) = √(2·1000·20) = 200.
	assert_float(config.get_release_velocity()).is_equal_approx(200.0, 0.001)
	assert_float(config.get_accel_rate()).is_equal_approx(600.0, 0.001)
	assert_float(config.get_decel_rate()).is_equal_approx(1200.0, 0.001)


func test_zero_times_mean_instant() -> void:
	var config := PlayerMovementConfig.new()
	config.accel_time = 0.0
	config.decel_time = 0.0
	assert_float(config.get_accel_rate()).is_equal(INF)
	assert_float(config.get_decel_rate()).is_equal(INF)


func test_defaults_match_spec() -> void:
	var config := PlayerMovementConfig.new()
	assert_float(config.run_speed).is_equal(135.0)
	assert_float(config.accel_time).is_equal(0.15)
	assert_float(config.decel_time).is_equal(0.12)
	assert_float(config.turn_time).is_equal(0.08)
	assert_float(config.jump_height).is_equal(52.0)
	assert_float(config.min_jump_height).is_equal(30.0)
	assert_float(config.time_to_apex).is_equal(0.36)
	assert_float(config.fall_gravity_scale).is_equal(1.25)
	assert_float(config.max_fall_speed).is_equal(600.0)
	assert_float(config.jump_prep_time).is_equal(0.07)
	assert_float(config.air_control).is_equal(0.5)
	assert_float(config.hard_landing_height).is_equal(100.0)
	assert_float(config.land_recovery_time).is_equal(0.15)
	assert_float(config.coyote_time).is_equal(0.08)
	assert_float(config.jump_buffer_time).is_equal(0.1)
