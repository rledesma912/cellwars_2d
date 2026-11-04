# Tests de PlayerAnimation (F004-AC18, AC19; F008-AC01 a AC03; F009-AC05, AC06).
extends GdUnitTestSuite

const S := PlayerMotor.State
const RUN_SPEED := 100.0


func _pick(state: PlayerMotor.State, velocity: Vector2, blocked := false) -> StringName:
	return PlayerAnimation.pick(state, velocity, RUN_SPEED, blocked)


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


func test_f008_ac01_blocked_run_shows_idle_at_any_speed() -> void:
	assert_str(_pick(S.RUN, Vector2.ZERO, true)).is_equal("quieto")
	assert_str(_pick(S.RUN, Vector2(69.0, 0.0), true)).is_equal("quieto")
	assert_str(_pick(S.RUN, Vector2(-100.0, 0.0), true)).is_equal("quieto")


func test_f008_ac01_blocked_only_when_pressing_toward_the_wall() -> void:
	# La normal de la pared apunta hacia afuera: una pared a la derecha tiene normal X −1.
	assert_bool(PlayerAnimation.is_blocked(true, -1.0, 1.0)).is_true()
	assert_bool(PlayerAnimation.is_blocked(true, 1.0, -1.0)).is_true()
	# Stick a medias: cuenta igual que la tecla.
	assert_bool(PlayerAnimation.is_blocked(true, -1.0, 0.3)).is_true()
	# Pared del lado contrario a la dirección apretada, o sin dirección: no bloquea.
	assert_bool(PlayerAnimation.is_blocked(true, -1.0, -1.0)).is_false()
	assert_bool(PlayerAnimation.is_blocked(true, -1.0, 0.0)).is_false()
	# Sin pared: no bloquea.
	assert_bool(PlayerAnimation.is_blocked(false, 0.0, 1.0)).is_false()


func test_f008_ac02_unblocked_run_keeps_speed_rule() -> void:
	assert_str(_pick(S.RUN, Vector2(69.0, 0.0), false)).is_equal("arrancar")
	assert_str(_pick(S.RUN, Vector2(70.0, 0.0), false)).is_equal("correr")
	assert_str(_pick(S.RUN, Vector2(-69.0, 0.0), false)).is_equal("arrancar")
	assert_str(_pick(S.RUN, Vector2(-100.0, 0.0), false)).is_equal("correr")


func test_f008_ac03_blocked_only_changes_run() -> void:
	assert_str(_pick(S.BRAKE, Vector2(50.0, 0.0), true)).is_equal("frenar")
	assert_str(_pick(S.TURN, Vector2.ZERO, true)).is_equal("girar")
	assert_str(_pick(S.JUMP_PREP, Vector2(80.0, 0.0), true)).is_equal("preparar")
	assert_str(_pick(S.AIR, Vector2(0.0, -10.0), true)).is_equal("subir")
	assert_str(_pick(S.AIR, Vector2(0.0, 10.0), true)).is_equal("caer")
	assert_str(_pick(S.LAND, Vector2.ZERO, true)).is_equal("aterrizar")


func test_f009_ac05_roll_shows_rodar_for_roll_time() -> void:
	assert_str(_pick(S.ROLL, Vector2(100.0, 0.0))).is_equal("rodar")
	assert_str(_pick(S.ROLL, Vector2.ZERO)).is_equal("rodar")
	var config := PlayerMovementConfig.new()
	assert_float(PlayerAnimation.duration_for("rodar", config)).is_equal(config.roll_time)


func test_f009_ac05_recovery_always_shows_aterrizar() -> void:
	assert_str(_pick(S.LAND, Vector2.ZERO)).is_equal("aterrizar")
	assert_str(_pick(S.LAND, Vector2(RUN_SPEED, 0.0))).is_equal("aterrizar")


func test_f009_ac06_frames_have_every_animation() -> void:
	var frames: SpriteFrames = load("res://game/art/elyon/elyon_frames.tres")
	var velocities := [Vector2.ZERO, Vector2(RUN_SPEED, 0.0), Vector2(0.0, -10.0)]
	for state: int in S.values():
		for velocity: Vector2 in velocities:
			for blocked: bool in [false, true]:
				var anim := PlayerAnimation.pick(state, velocity, RUN_SPEED, blocked)
				assert_bool(frames.has_animation(anim)).is_true()
				for i in frames.get_frame_count(anim):
					var size := frames.get_frame_texture(anim, i).get_size()
					assert_vector(size).is_equal(Vector2(144.0, 144.0))
	assert_int(frames.get_animation_names().size()).is_equal(10)
