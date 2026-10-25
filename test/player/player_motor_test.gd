# Tests de PlayerMotor (F004). Se simula en pasos de 1/60 s, como corre la física de Godot.
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
