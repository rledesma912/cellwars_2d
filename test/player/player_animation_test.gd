# Tests de PlayerAnimation (F004-AC18, AC19).
extends GdUnitTestSuite

const S := PlayerMotor.State
const RUN_SPEED := 100.0


func _pick(state: PlayerMotor.State, velocity: Vector2) -> StringName:
	return PlayerAnimation.pick(state, velocity, RUN_SPEED)


func test_f004_ac18_animation_for_each_state() -> void:
	assert_str(_pick(S.IDLE, Vector2.ZERO)).is_equal("quieto")
	# Correr: "arrancar" por debajo del 70 % de run_speed, "correr" desde ahí (en los dos sentidos).
	assert_str(_pick(S.RUN, Vector2(69.0, 0.0))).is_equal("arrancar")
	assert_str(_pick(S.RUN, Vector2(70.0, 0.0))).is_equal("correr")
	assert_str(_pick(S.RUN, Vector2(-69.0, 0.0))).is_equal("arrancar")
	assert_str(_pick(S.RUN, Vector2(-100.0, 0.0))).is_equal("correr")
	assert_str(_pick(S.BRAKE, Vector2(50.0, 0.0))).is_equal("frenar")
	assert_str(_pick(S.TURN, Vector2.ZERO)).is_equal("girar")
	assert_str(_pick(S.JUMP_PREP, Vector2(80.0, 0.0))).is_equal("preparar")
	# En el aire: sube con velocidad Y negativa (en Godot Y crece hacia abajo).
	assert_str(_pick(S.AIR, Vector2(0.0, -10.0))).is_equal("subir")
	assert_str(_pick(S.AIR, Vector2(0.0, 0.0))).is_equal("caer")
	assert_str(_pick(S.AIR, Vector2(0.0, 10.0))).is_equal("caer")
	assert_str(_pick(S.LAND, Vector2.ZERO)).is_equal("aterrizar")


func test_f004_ac19_speed_stretches_animation_to_duration() -> void:
	# 3 cuadros a 10 fps duran 0,3 s. Para que duren 0,15 s, al doble; para 0,6 s, a la mitad.
	assert_float(PlayerAnimation.speed_for(3, 10.0, 0.15)).is_equal_approx(2.0, 0.0001)
	assert_float(PlayerAnimation.speed_for(3, 10.0, 0.6)).is_equal_approx(0.5, 0.0001)
	# Sin duración pedida (o datos inválidos), velocidad normal.
	assert_float(PlayerAnimation.speed_for(3, 10.0, 0.0)).is_equal(1.0)
	assert_float(PlayerAnimation.speed_for(3, 0.0, 0.2)).is_equal(1.0)


func test_f004_ac19_timed_animations_use_config_times() -> void:
	var config := PlayerMovementConfig.new()
	assert_float(PlayerAnimation.duration_for("girar", config)).is_equal(config.turn_time)
	assert_float(PlayerAnimation.duration_for("preparar", config)).is_equal(config.jump_prep_time)
	assert_float(PlayerAnimation.duration_for("aterrizar", config)).is_equal(
		config.land_recovery_time
	)
	# Las demás se reproducen a su velocidad natural.
	assert_float(PlayerAnimation.duration_for("correr", config)).is_equal(0.0)
