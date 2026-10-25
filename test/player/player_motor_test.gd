# gdlint: disable=max-public-methods
# Tests de PlayerMotor (F004). Se simula en pasos de 1/60 s, como corre la física de Godot.
# (Cada test es una función pública; esta suite cubre todo el motor y pasa de 20.)
extends GdUnitTestSuite

const DT := 1.0 / 60.0
const RIGHT := 1.0
const LEFT := -1.0
const NONE := 0.0

var _config: PlayerMovementConfig
var _motor: PlayerMotor
var _velocity: Vector2


func before_test() -> void:
	_config = PlayerMovementConfig.new()
	_motor = PlayerMotor.new(_config)
	_velocity = Vector2.ZERO


# Un paso en el piso con la dirección dada y sin tocar el salto.
func _ground_step(direction: float) -> void:
	_velocity = _motor.step(_velocity, PlayerInput.new(direction, false), true, DT)


# Corre hacia la derecha hasta llegar a la velocidad máxima.
func _run_right_to_full_speed() -> void:
	for i in 60:
		_ground_step(RIGHT)
		if _velocity.x >= _config.run_speed:
			return


func test_f004_ac01_accelerates_to_run_speed_in_accel_time() -> void:
	var steps := 0
	var last_x := 0.0
	while _velocity.x < _config.run_speed and steps < 120:
		_ground_step(RIGHT)
		steps += 1
		# Sube de a poco: nunca baja y nunca salta de golpe al máximo (salvo el último paso).
		assert_float(_velocity.x).is_greater(last_x)
		assert_int(_motor.state).is_equal(PlayerMotor.State.RUN)
		last_x = _velocity.x
	assert_float(_velocity.x).is_equal(_config.run_speed)
	assert_bool(steps > 1).is_true()
	assert_float(absf(steps * DT - _config.accel_time)).is_less_equal(DT + 0.0001)


func test_f004_ac02_brakes_to_zero_in_decel_time() -> void:
	_run_right_to_full_speed()
	var steps := 0
	while _velocity.x > 0.0 and steps < 120:
		_ground_step(NONE)
		steps += 1
		if _velocity.x > 0.0:
			assert_int(_motor.state).is_equal(PlayerMotor.State.BRAKE)
	assert_float(_velocity.x).is_equal(0.0)
	assert_float(absf(steps * DT - _config.decel_time)).is_less_equal(DT + 0.0001)
	assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)


func test_f004_ac03_turns_in_place_after_turn_time() -> void:
	assert_int(_motor.facing).is_equal(1)
	_ground_step(LEFT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.TURN)
	var turn_steps := 1
	while _motor.state == PlayerMotor.State.TURN and turn_steps < 60:
		assert_float(_velocity.x).is_equal(0.0)
		assert_int(_motor.facing).is_equal(1)
		_ground_step(LEFT)
		turn_steps += 1
	# El giro termina en el paso en que se acaba turn_time: ya mira a la izquierda.
	assert_float(_velocity.x).is_equal(0.0)
	assert_int(_motor.facing).is_equal(-1)
	assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)
	assert_float(absf(turn_steps * DT - _config.turn_time)).is_less_equal(DT + 0.0001)
	# Con la izquierda sostenida, después arranca hacia ese lado.
	_ground_step(LEFT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.RUN)
	assert_float(_velocity.x).is_less(0.0)


func test_f004_ac04_running_turn_brakes_first() -> void:
	_run_right_to_full_speed()
	var saw_brake := false
	var saw_turn := false
	for i in 120:
		_ground_step(LEFT)
		match _motor.state:
			PlayerMotor.State.BRAKE:
				assert_bool(saw_turn).is_false()
				saw_brake = true
			PlayerMotor.State.TURN:
				assert_bool(saw_brake).is_true()
				assert_float(_velocity.x).is_equal(0.0)
				saw_turn = true
		# Nunca va hacia la izquierda antes de frenar del todo y darse vuelta.
		if _velocity.x < 0.0:
			assert_bool(saw_turn).is_true()
			assert_int(_motor.facing).is_equal(-1)
	assert_bool(saw_brake).is_true()
	assert_bool(saw_turn).is_true()
	assert_float(_velocity.x).is_equal(-_config.run_speed)


func test_left_and_right_together_brake_like_no_direction() -> void:
	_run_right_to_full_speed()
	# Input.get_axis ya devuelve 0 con las dos apretadas: el motor recibe dirección 0.
	_ground_step(NONE)
	assert_int(_motor.state).is_equal(PlayerMotor.State.BRAKE)


# --- Salto (T3) ---


# Simula un salto desde el piso (y = 0) hasta volver a tocarlo, como lo haría Godot:
# primero el motor calcula la velocidad, después se mueve con ella (pos += v·dt).
# El botón se aprieta en el paso 0 y se suelta en el paso release_step (−1 = nunca).
# Devuelve la altura máxima alcanzada, en píxeles.
func _jump_height(release_step: int) -> float:
	var pos := Vector2.ZERO
	var on_floor := true
	var top := 0.0
	for i in 300:
		var held := release_step < 0 or i < release_step
		var input := PlayerInput.new(NONE, i == 0, held)
		_velocity = _motor.step(_velocity, input, on_floor, DT)
		pos += _velocity * DT
		top = minf(top, pos.y)
		on_floor = pos.y >= 0.0
		if on_floor:
			pos.y = 0.0
			if i > 0 and top < 0.0:
				break
	return -top


func test_f004_ac05_jump_prep_keeps_momentum_and_ignores_input() -> void:
	_run_right_to_full_speed()
	var speed := _velocity.x
	_velocity = _motor.step(_velocity, PlayerInput.new(RIGHT, true, true), true, DT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.JUMP_PREP)
	var prep_steps := 1
	while _motor.state == PlayerMotor.State.JUMP_PREP and prep_steps < 60:
		# Sigue en el piso, con la misma velocidad, aunque pida ir para el otro lado.
		assert_float(_velocity.y).is_equal(0.0)
		assert_float(_velocity.x).is_equal(speed)
		_velocity = _motor.step(_velocity, PlayerInput.new(LEFT, false, true), true, DT)
		prep_steps += 1
	# Al terminar la preparación despega (velocidad hacia arriba) y conserva el impulso.
	assert_int(_motor.state).is_equal(PlayerMotor.State.AIR)
	assert_float(_velocity.y).is_less(0.0)
	assert_float(_velocity.x).is_equal(speed)
	assert_float(absf(prep_steps * DT - _config.jump_prep_time)).is_less_equal(DT + 0.0001)


func test_f004_ac06_held_jump_reaches_jump_height() -> void:
	assert_float(_jump_height(-1)).is_equal_approx(_config.jump_height, 2.0)


func test_f004_ac07_tap_reaches_min_jump_height() -> void:
	# Soltado en el paso 1: antes de que termine la preparación.
	assert_float(_jump_height(1)).is_equal_approx(_config.min_jump_height, 2.0)


func test_f004_ac08_mid_release_height_between_min_and_max() -> void:
	# La preparación dura unos 4 pasos; se suelta a distintos momentos de la subida.
	for release_step: int in [6, 8, 10, 12]:
		before_test()
		var height := _jump_height(release_step)
		assert_float(height).is_greater_equal(_config.min_jump_height - 2.0)
		assert_float(height).is_less_equal(_config.jump_height + 2.0)


func test_f004_ac09_fall_gravity_scaled_and_capped() -> void:
	_motor.state = PlayerMotor.State.AIR
	var idle := PlayerInput.new(NONE, false)
	# Bajando: gravedad de subida × fall_gravity_scale.
	var v := _motor.step(Vector2(0.0, 10.0), idle, false, DT)
	assert_float(v.y).is_equal_approx(10.0 + _config.get_fall_gravity() * DT, 0.001)
	# Subiendo: gravedad de subida sola.
	v = _motor.step(Vector2(0.0, -100.0), idle, false, DT)
	assert_float(v.y).is_equal_approx(-100.0 + _config.get_gravity() * DT, 0.001)
	# Nunca más rápido que max_fall_speed.
	v = _motor.step(Vector2(0.0, _config.max_fall_speed - 1.0), idle, false, DT)
	assert_float(v.y).is_equal(_config.max_fall_speed)


func test_f004_ac10_no_double_jump() -> void:
	_motor.state = PlayerMotor.State.AIR
	var v := _motor.step(Vector2(0.0, 50.0), PlayerInput.new(NONE, true, true), false, DT)
	assert_float(v.y).is_equal_approx(50.0 + _config.get_fall_gravity() * DT, 0.001)
	assert_int(_motor.state).is_equal(PlayerMotor.State.AIR)


func test_f004_ac11_held_jump_does_not_repeat_on_landing() -> void:
	_motor.state = PlayerMotor.State.AIR
	# Toca el piso con el botón todavía apretado desde antes (no es "recién apretado").
	_velocity = _motor.step(Vector2(0.0, 200.0), PlayerInput.new(NONE, false, true), true, DT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)
	for i in 10:
		_velocity = _motor.step(_velocity, PlayerInput.new(NONE, false, true), true, DT)
		assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)
		assert_float(_velocity.y).is_equal(0.0)


# --- Ayudas, aire y aterrizaje (T4) ---


# Un paso con todo explícito.
func _step(direction: float, pressed: bool, held: bool, on_floor: bool) -> void:
	_velocity = _motor.step(_velocity, PlayerInput.new(direction, pressed, held), on_floor, DT)


# Corre a la derecha y pisa el vacío: un paso en el aire sin haber saltado.
func _walk_off_ledge() -> void:
	_run_right_to_full_speed()
	_step(RIGHT, false, false, false)
	assert_int(_motor.state).is_equal(PlayerMotor.State.AIR)
	assert_float(_velocity.y).is_greater_equal(0.0)


# Cae desde "height" px (sin saltar) y toca el piso con la dirección dada.
func _fall_and_land(height: float, direction: float) -> void:
	_motor.state = PlayerMotor.State.AIR
	var y := -height
	for i in 300:
		_step(direction, false, false, false)
		y += _velocity.y * DT
		if y >= 0.0:
			break
	_step(direction, false, false, true)


func test_f004_ac12_coyote_time_allows_late_jump() -> void:
	_walk_off_ledge()
	_step(RIGHT, false, false, false)
	_step(RIGHT, true, true, false)
	# Salta en ese mismo paso, sin preparación.
	assert_int(_motor.state).is_equal(PlayerMotor.State.AIR)
	assert_float(_velocity.y).is_less(-_config.get_release_velocity())


func test_f004_ac12_coyote_time_expires() -> void:
	_walk_off_ledge()
	var steps := int(ceil(_config.coyote_time / DT)) + 1
	for i in steps:
		_step(RIGHT, false, false, false)
	var before := _velocity.y
	_step(RIGHT, true, true, false)
	assert_float(_velocity.y).is_greater(before)


func test_f004_ac13_jump_buffer_starts_prep_on_landing() -> void:
	_motor.state = PlayerMotor.State.AIR
	_velocity = Vector2(0.0, 100.0)
	_step(NONE, true, true, false)
	_step(NONE, false, true, false)
	_step(NONE, false, true, false)
	_step(NONE, false, true, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.JUMP_PREP)


func test_f004_ac13_jump_buffer_expires() -> void:
	_motor.state = PlayerMotor.State.AIR
	_velocity = Vector2(0.0, 100.0)
	_step(NONE, true, true, false)
	for i in int(ceil(_config.jump_buffer_time / DT)) + 1:
		_step(NONE, false, true, false)
	_step(NONE, false, true, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)


func test_f004_ac14_air_control_reduced_and_no_reverse() -> void:
	_motor.state = PlayerMotor.State.AIR
	var air_rate := _config.get_accel_rate() * _config.air_control
	# Mirando a la derecha y quieto en el aire: acelera a la mitad de lo que haría en el piso.
	_step(RIGHT, false, false, false)
	assert_float(_velocity.x).is_equal_approx(air_rate * DT, 0.001)
	# Pidiendo izquierda: frena hasta 0 pero no pasa a negativo, y no se da vuelta.
	_velocity.x = 60.0
	for i in 60:
		_step(LEFT, false, false, false)
		assert_float(_velocity.x).is_greater_equal(0.0)
		assert_int(_motor.facing).is_equal(1)
	assert_float(_velocity.x).is_equal(0.0)


func test_f004_ac15_soft_landing_responds_immediately() -> void:
	_fall_and_land(_config.hard_landing_height / 2.0, RIGHT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.RUN)
	assert_float(_velocity.x).is_greater(0.0)


func test_f004_ac16_hard_landing_recovers_without_control() -> void:
	_fall_and_land(_config.hard_landing_height + 20.0, RIGHT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.LAND)
	var steps := 1
	var last_x := _velocity.x
	while _motor.state == PlayerMotor.State.LAND and steps < 60:
		_step(RIGHT, false, false, true)
		steps += 1
		# Pide derecha, pero no acelera: frena.
		assert_float(_velocity.x).is_less_equal(last_x)
		last_x = _velocity.x
	assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)
	assert_float(absf(steps * DT - _config.land_recovery_time)).is_less_equal(DT + 0.0001)


# Casos límite de la spec.


func test_jump_during_turn_fires_when_turn_ends() -> void:
	_ground_step(LEFT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.TURN)
	_step(LEFT, true, true, true)
	for i in 10:
		if _motor.state != PlayerMotor.State.TURN:
			break
		_step(LEFT, false, true, true)
	_step(LEFT, false, true, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.JUMP_PREP)


func test_jump_early_in_recovery_is_lost() -> void:
	_fall_and_land(_config.hard_landing_height + 20.0, NONE)
	assert_int(_motor.state).is_equal(PlayerMotor.State.LAND)
	# Recién aterrizado: falta más que jump_buffer_time para terminar la recuperación.
	_step(NONE, true, true, true)
	for i in 30:
		_step(NONE, false, true, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)


func test_ledge_during_prep_falls_without_jump_and_coyote_applies() -> void:
	_run_right_to_full_speed()
	_step(RIGHT, true, true, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.JUMP_PREP)
	# El impulso lo saca del borde antes de despegar.
	_step(RIGHT, false, true, false)
	assert_int(_motor.state).is_equal(PlayerMotor.State.AIR)
	assert_float(_velocity.y).is_greater_equal(0.0)
	# Vuelve a apretar dentro del coyote time: salta.
	_step(RIGHT, true, true, false)
	assert_float(_velocity.y).is_less(0.0)


func test_no_coyote_after_jump() -> void:
	_config.jump_prep_time = 0.0
	_step(NONE, true, true, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.AIR)
	_step(NONE, false, false, false)
	var before := _velocity.y
	_step(NONE, true, true, false)
	assert_float(_velocity.y).is_greater(before)


func test_reset_clears_state_and_timers() -> void:
	_ground_step(LEFT)
	_step(LEFT, true, true, false)
	_motor.reset()
	assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)
	assert_int(_motor.facing).is_equal(1)
	assert_float(_motor.get_state_timer()).is_equal(0.0)
	assert_float(_motor.get_coyote()).is_equal(0.0)
	assert_float(_motor.get_buffer()).is_equal(0.0)
