# gdlint: disable=max-public-methods
# Tests de PlayerMotor (F004). Se simula en pasos de 1/60 s, como corre la física de Godot.
# (Cada test es una función pública; esta suite cubre todo el motor y pasa de 20.)
extends GdUnitTestSuite

const DT := 1.0 / 60.0
const RIGHT := 1.0
const LEFT := -1.0
const NONE := 0.0
## Alto del cuerpo de colisión de Elyon (player.tscn, D0005).
const BODY_HEIGHT := 82.0
## Aire de un piso en una sala de 3 pisos: 12 baldosas menos la del piso (D0004).
const FLOOR_AIR := 220.0

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
		assert_float(_velocity.x).is_equal_approx(speed, 0.001)
		_velocity = _motor.step(_velocity, PlayerInput.new(LEFT, false, true), true, DT)
		prep_steps += 1
	# Al terminar la preparación despega (velocidad hacia arriba) y conserva el impulso.
	assert_int(_motor.state).is_equal(PlayerMotor.State.AIR)
	assert_float(_velocity.y).is_less(0.0)
	assert_float(_velocity.x).is_equal_approx(speed, 0.001)
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
	# Cae con velocidad: sin esto rodaría (F009). Acá se prueba la recuperación.
	_config.roll_time = 0.0
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


func test_f005_ac08_body_plus_jump_fits_floor() -> void:
	# Con el salto más alto, la cabeza no pasa del techo del piso: 113,96 + 106 ≤ 220.
	assert_float(_jump_height(-1) + BODY_HEIGHT).is_less_equal(FLOOR_AIR)


# F009: rodar.


# Toca el piso después de una caída alta, con la velocidad horizontal dada.
func _land_hard_at(speed_x: float) -> void:
	_motor.state = PlayerMotor.State.AIR
	_motor._fall_distance = _config.hard_landing_height
	_velocity = Vector2(speed_x, 400.0)
	_step(NONE, false, false, true)


func _roll_threshold() -> float:
	return _config.roll_min_speed_fraction * _config.run_speed


func test_f009_ac01_hard_landing_with_speed_rolls() -> void:
	_land_hard_at(_roll_threshold() + 1.0)
	assert_int(_motor.state).is_equal(PlayerMotor.State.ROLL)
	# Mirando a la izquierda vale lo mismo con velocidad hacia la izquierda.
	_motor.reset()
	_motor.facing = -1
	_land_hard_at(-_roll_threshold() - 1.0)
	assert_int(_motor.state).is_equal(PlayerMotor.State.ROLL)


func test_f009_ac01_rolls_only_from_threshold() -> void:
	# Vector2 guarda floats de 32 bits: justo en el umbral puede redondear para abajo.
	_land_hard_at(_roll_threshold() + 0.01)
	assert_int(_motor.state).is_equal(PlayerMotor.State.ROLL)
	_motor.reset()
	_land_hard_at(_roll_threshold() - 0.01)
	assert_int(_motor.state).is_equal(PlayerMotor.State.LAND)


func test_f009_ac01_real_fall_while_running_rolls() -> void:
	_run_right_to_full_speed()
	_fall_and_land(_config.hard_landing_height + 20.0, RIGHT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.ROLL)
	# Una caída baja no alcanza.
	_motor.reset()
	_velocity = Vector2.ZERO
	_run_right_to_full_speed()
	_fall_and_land(_config.hard_landing_height / 2.0, RIGHT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.RUN)


func test_f009_ac02_roll_keeps_speed_and_ignores_direction() -> void:
	var speed := _roll_threshold() + 50.0
	_land_hard_at(speed)
	var steps := 1
	while _motor.state == PlayerMotor.State.ROLL and steps < 120:
		assert_float(_velocity.x).is_equal_approx(speed, 0.001)
		assert_float(_velocity.y).is_equal(0.0)
		assert_int(_motor.facing).is_equal(1)
		_step(LEFT, false, false, true)
		steps += 1
	assert_float(absf(steps * DT - _config.roll_time)).is_less_equal(DT + 0.0001)


func test_f009_ac03_slow_or_backward_landing_recovers() -> void:
	# Más lento que el umbral: se recupera y frena.
	_land_hard_at(_roll_threshold() - 1.0)
	assert_int(_motor.state).is_equal(PlayerMotor.State.LAND)
	assert_float(_velocity.x).is_less(_roll_threshold() - 1.0)
	# Rápido, pero en sentido contrario a donde mira: tampoco rueda.
	_motor.reset()
	_land_hard_at(-_config.run_speed)
	assert_int(_motor.state).is_equal(PlayerMotor.State.LAND)
	assert_float(_velocity.x).is_greater(-_config.run_speed)


func test_f009_ac03_roll_time_zero_never_rolls() -> void:
	_config.roll_time = 0.0
	_land_hard_at(_config.run_speed)
	assert_int(_motor.state).is_equal(PlayerMotor.State.LAND)


func test_f009_ac04_control_returns_after_roll() -> void:
	_land_hard_at(_config.run_speed)
	for i in 60:
		if _motor.state != PlayerMotor.State.ROLL:
			break
		_step(RIGHT, false, false, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)
	_step(RIGHT, false, false, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.RUN)


func test_roll_off_ledge_falls() -> void:
	_land_hard_at(_config.run_speed)
	_step(NONE, false, false, false)
	assert_int(_motor.state).is_equal(PlayerMotor.State.AIR)


func test_jump_near_end_of_roll_fires_from_buffer() -> void:
	_land_hard_at(_config.run_speed)
	# Aprieta salto faltando menos que jump_buffer_time: al terminar, prepara el salto.
	while _motor.get_state_timer() > _config.jump_buffer_time / 2.0:
		_step(NONE, false, true, true)
	_step(NONE, true, true, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.ROLL)
	for i in 10:
		_step(NONE, false, true, true)
		if _motor.state != PlayerMotor.State.ROLL:
			break
	_step(NONE, false, true, true)
	assert_int(_motor.state).is_equal(PlayerMotor.State.JUMP_PREP)


# Lleva al motor a un estado cualquiera, por el camino que usa el juego.
func _reach_state(target: PlayerMotor.State) -> void:
	match target:
		PlayerMotor.State.RUN:
			_ground_step(RIGHT)
		PlayerMotor.State.BRAKE:
			_run_right_to_full_speed()
			_ground_step(NONE)
		PlayerMotor.State.TURN:
			_ground_step(LEFT)
		PlayerMotor.State.JUMP_PREP:
			_velocity = _motor.step(_velocity, PlayerInput.new(NONE, true, true), true, DT)
		PlayerMotor.State.AIR:
			_velocity = _motor.step(_velocity, PlayerInput.new(NONE, false), false, DT)
		PlayerMotor.State.LAND:
			_velocity = _motor.step(_velocity, PlayerInput.new(NONE, false), false, DT)
			_velocity = Vector2(0.0, _config.max_fall_speed)
			# 15 pasos al tope son 330 px: aterrizaje pesado, pero no mortal (F010).
			for i in 15:
				_velocity = _motor.step(_velocity, PlayerInput.new(NONE, false), false, DT)
			_velocity.x = 0.0
			_velocity = _motor.step(_velocity, PlayerInput.new(NONE, false), true, DT)
		PlayerMotor.State.ROLL:
			_velocity = _motor.step(_velocity, PlayerInput.new(NONE, false), false, DT)
			_velocity = Vector2(_config.run_speed, _config.max_fall_speed)
			# 15 pasos al tope son 330 px: aterrizaje pesado, pero no mortal (F010).
			for i in 15:
				_velocity = _motor.step(_velocity, PlayerInput.new(RIGHT, false), false, DT)
			_velocity = _motor.step(_velocity, PlayerInput.new(RIGHT, false), true, DT)


# Cuenta los pasos hasta que la muerte termina (con tope, para no colgarse).
func _steps_until_death_finished() -> int:
	var steps := 0
	while not _motor.is_death_finished() and steps < 1000:
		_velocity = _motor.step(_velocity, PlayerInput.new(NONE, false), true, DT)
		steps += 1
	return steps


func test_f007_ac01_dies_from_every_state() -> void:
	for state: int in PlayerMotor.State.values():
		if state == PlayerMotor.State.DEAD:
			continue
		before_test()
		_reach_state(state)
		assert_int(_motor.state).is_equal(state)
		_motor.die(PlayerMotor.DeathCause.HAZARD)
		assert_int(_motor.state).is_equal(PlayerMotor.State.DEAD)
		assert_bool(_motor.is_dead()).is_true()


func test_f007_ac01_ignores_input_until_reset() -> void:
	_motor.die(PlayerMotor.DeathCause.HAZARD)
	# Muerto no acelera ni salta, tampoco si se apretó el salto antes de morir.
	for i in 30:
		_velocity = _motor.step(_velocity, PlayerInput.new(RIGHT, true, true), true, DT)
		assert_vector(_velocity).is_equal(Vector2.ZERO)
		assert_int(_motor.state).is_equal(PlayerMotor.State.DEAD)
	assert_float(_motor.get_buffer()).is_equal(0.0)
	# Sigue muerto aunque el tiempo ya haya pasado: solo reset() lo saca.
	_steps_until_death_finished()
	_velocity = _motor.step(_velocity, PlayerInput.new(RIGHT, true, true), true, DT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.DEAD)
	_motor.reset()
	assert_bool(_motor.is_dead()).is_false()
	assert_bool(_motor.is_death_finished()).is_false()
	_ground_step(RIGHT)
	assert_int(_motor.state).is_equal(PlayerMotor.State.RUN)


func test_f007_ac01_buffered_jump_does_not_survive_death() -> void:
	# El salto apretado justo antes de morir no sale al reaparecer.
	_velocity = _motor.step(_velocity, PlayerInput.new(NONE, true, true), false, DT)
	assert_float(_motor.get_buffer()).is_greater(0.0)
	_motor.die(PlayerMotor.DeathCause.HAZARD)
	assert_float(_motor.get_buffer()).is_equal(0.0)


func test_f007_ac02_brakes_on_floor() -> void:
	_run_right_to_full_speed()
	_motor.die(PlayerMotor.DeathCause.HAZARD)
	var travelled := 0.0
	var steps := 0
	while _velocity.x > 0.0 and steps < 60:
		_velocity = _motor.step(_velocity, PlayerInput.new(RIGHT, false), true, DT)
		travelled += _velocity.x * DT
		steps += 1
	# Tarda lo mismo que un frenado normal: decel_time, con margen de un paso.
	assert_float(steps * DT).is_equal_approx(_config.decel_time, DT)
	# Frena de forma pareja: la distancia es velocidad × tiempo / 2, con margen de un
	# paso porque el motor avanza de a pasos. Con los valores del .tres, unos 13 px.
	var expected := _config.run_speed * _config.decel_time / 2.0
	assert_float(travelled).is_equal_approx(expected, _config.run_speed * DT)
	assert_float(_velocity.y).is_equal(0.0)


func test_f007_ac02_falls_in_air_up_to_max() -> void:
	_velocity = Vector2(50.0, -100.0)
	_motor.die(PlayerMotor.DeathCause.HAZARD)
	_velocity = _motor.step(_velocity, PlayerInput.new(LEFT, false), false, DT)
	# Usa la gravedad de caída también si venía subiendo, y no responde a la dirección.
	var expected := -100.0 + _config.get_fall_gravity() * DT
	assert_float(_velocity.y).is_equal_approx(expected, 0.01)
	assert_float(_velocity.x).is_equal(50.0)
	for i in 300:
		_velocity = _motor.step(_velocity, PlayerInput.new(NONE, false), false, DT)
	assert_float(_velocity.y).is_equal_approx(_config.max_fall_speed, 0.01)
	assert_int(_motor.state).is_equal(PlayerMotor.State.DEAD)


func test_f007_ac03_hazard_lasts_death_time() -> void:
	_motor.die(PlayerMotor.DeathCause.HAZARD)
	assert_bool(_motor.is_death_finished()).is_false()
	assert_float(_motor.get_state_timer()).is_equal(_config.death_time)
	var seconds := _steps_until_death_finished() * DT
	assert_float(seconds).is_equal_approx(_config.death_time, DT)


func test_f007_ac03_void_lasts_void_restart_time() -> void:
	_motor.die(PlayerMotor.DeathCause.VOID)
	var seconds := _steps_until_death_finished() * DT
	assert_float(seconds).is_equal_approx(_config.void_restart_time, DT)


func test_f007_ac03_zero_time_finishes_on_first_step() -> void:
	# void_restart_time en 0 queda como antes de F007: vuelve enseguida.
	_config.void_restart_time = 0.0
	_motor.die(PlayerMotor.DeathCause.VOID)
	assert_int(_steps_until_death_finished()).is_less_equal(1)


func test_f007_ac04_dying_again_keeps_remaining_time() -> void:
	_motor.die(PlayerMotor.DeathCause.HAZARD)
	for i in 10:
		_ground_step(NONE)
	var remaining := _motor.get_state_timer()
	_motor.die(PlayerMotor.DeathCause.HAZARD)
	assert_float(_motor.get_state_timer()).is_equal(remaining)
	_motor.die(PlayerMotor.DeathCause.VOID)
	assert_float(_motor.get_state_timer()).is_equal(remaining)


# F010: caída mortal.


# Toca el piso después de una caída de "distance" px, con la velocidad horizontal dada.
func _land_from(distance: float, speed_x: float) -> void:
	_motor.state = PlayerMotor.State.AIR
	_motor._fall_distance = distance
	_velocity = Vector2(speed_x, 400.0)
	_step(NONE, false, false, true)


func test_f010_ac01_lethal_landing_dies_with_death_time() -> void:
	for speed: float in [0.0, _config.run_speed, -_config.run_speed]:
		before_test()
		_land_from(_config.lethal_fall_height, speed)
		assert_int(_motor.state).is_equal(PlayerMotor.State.DEAD)
		var seconds := (_steps_until_death_finished() + 1) * DT
		assert_float(seconds).is_equal_approx(_config.death_time, DT)


func test_f010_ac01_real_fall_kills_on_landing() -> void:
	_fall_and_land(_config.lethal_fall_height + 20.0, NONE)
	assert_int(_motor.state).is_equal(PlayerMotor.State.DEAD)


func test_f010_ac02_just_below_lethal_rolls_or_recovers() -> void:
	_land_from(_config.lethal_fall_height - 1.0, _config.run_speed)
	assert_int(_motor.state).is_equal(PlayerMotor.State.ROLL)
	_motor.reset()
	_land_from(_config.lethal_fall_height - 1.0, 0.0)
	assert_int(_motor.state).is_equal(PlayerMotor.State.LAND)


func test_f010_ac03_fall_death_ignores_input_and_finishes() -> void:
	_land_from(_config.lethal_fall_height, 100.0)
	var facing := _motor.facing
	for i in 20:
		_step(LEFT, true, true, true)
		assert_int(_motor.state).is_equal(PlayerMotor.State.DEAD)
		assert_int(_motor.facing).is_equal(facing)
		assert_float(_velocity.y).is_equal(0.0)
		assert_float(_velocity.x).is_greater_equal(0.0)
	_steps_until_death_finished()
	assert_bool(_motor.is_death_finished()).is_true()
	_motor.reset()
	assert_int(_motor.state).is_equal(PlayerMotor.State.IDLE)
	# El salto apretado durante la muerte no sale al reaparecer.
	_step(NONE, false, false, true)
	assert_float(_velocity.y).is_equal(0.0)


func test_f010_ac04_fall_counts_from_highest_point() -> void:
	_config.jump_prep_time = 0.0
	# Salta y baja un piso: se cuenta desde el punto más alto, no desde donde despegó.
	var y := 0.0
	var top := 0.0
	_step(NONE, true, true, true)
	assert_float(_motor.get_fall_distance()).is_equal(0.0)
	y += _velocity.y * DT
	for i in 300:
		_step(NONE, false, true, false)
		y += _velocity.y * DT
		top = minf(top, y)
		if _velocity.y < 0.0:
			assert_float(_motor.get_fall_distance()).is_equal(0.0)
		if y >= 240.0:
			break
	assert_float(_motor.get_fall_distance()).is_equal_approx(y - top, 1.0)
	assert_float(_motor.get_fall_distance()).is_greater(240.0)


func test_f010_ac05_severity_follows_heights() -> void:
	_motor.state = PlayerMotor.State.AIR
	_motor._fall_distance = _config.long_fall_height - 1.0
	assert_int(_motor.get_fall_severity()).is_equal(PlayerMotor.FallSeverity.NORMAL)
	_motor._fall_distance = _config.long_fall_height
	assert_int(_motor.get_fall_severity()).is_equal(PlayerMotor.FallSeverity.LONG)
	_motor._fall_distance = _config.lethal_fall_height - 1.0
	assert_int(_motor.get_fall_severity()).is_equal(PlayerMotor.FallSeverity.LONG)
	_motor._fall_distance = _config.lethal_fall_height
	assert_int(_motor.get_fall_severity()).is_equal(PlayerMotor.FallSeverity.LETHAL)


func test_f010_ac06_fall_distance_freezes_at_death() -> void:
	# Muere en el aire por debajo del límite: sigue cayendo, pero la altura queda fija y
	# la animación que empezó no cambia a mitad de camino.
	_motor.state = PlayerMotor.State.AIR
	_motor._fall_distance = 100.0
	_motor.die(PlayerMotor.DeathCause.HAZARD)
	for i in 60:
		_step(NONE, false, false, false)
	assert_float(_velocity.y).is_greater(0.0)
	assert_float(_motor.get_fall_distance()).is_equal(100.0)


func test_f010_ac19_grounded_only_after_landing_alive() -> void:
	assert_bool(_motor.is_grounded()).is_true()
	_motor.state = PlayerMotor.State.AIR
	assert_bool(_motor.is_grounded()).is_false()
	# Aterriza vivo.
	_land_from(_config.hard_landing_height, 0.0)
	assert_bool(_motor.is_grounded()).is_true()
	# Aterriza con una caída mortal: nunca cuenta.
	_land_from(_config.lethal_fall_height, 0.0)
	assert_bool(_motor.is_grounded()).is_false()


func test_f010_reset_clears_fall_distance() -> void:
	_motor._fall_distance = 300.0
	_motor.reset()
	assert_float(_motor.get_fall_distance()).is_equal(0.0)
