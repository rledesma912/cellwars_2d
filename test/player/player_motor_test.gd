# Tests de PlayerMotor (F003-AC01 a AC05).
extends GdUnitTestSuite

# Godot calcula la física a 60 pasos por segundo.
const DT := 1.0 / 60.0

var _config: PlayerMovementConfig
var _motor: PlayerMotor


func before_test() -> void:
	_config = PlayerMovementConfig.new()
	_motor = PlayerMotor.new(_config)


func test_f003_ac01_walks_at_run_speed() -> void:
	for on_floor: bool in [true, false]:
		var right := _motor.step(Vector2.ZERO, PlayerInput.new(1.0, false), on_floor, DT)
		assert_float(right.x).is_equal(_config.run_speed)
		var left := _motor.step(Vector2.ZERO, PlayerInput.new(-1.0, false), on_floor, DT)
		assert_float(left.x).is_equal(-_config.run_speed)
		# "Las dos a la vez" llega como dirección 0, igual que no apretar nada.
		var none := _motor.step(Vector2(99.0, 0.0), PlayerInput.new(0.0, false), on_floor, DT)
		assert_float(none.x).is_equal(0.0)


func test_f003_ac02_gravity_accumulates_and_caps() -> void:
	var idle := PlayerInput.new(0.0, false)
	var falling := _motor.step(Vector2.ZERO, idle, false, DT)
	assert_float(falling.y).is_equal_approx(_config.get_gravity() * DT, 0.001)
	falling = _motor.step(falling, idle, false, DT)
	assert_float(falling.y).is_equal_approx(2.0 * _config.get_gravity() * DT, 0.001)
	# Cayendo mucho tiempo, nunca pasa del tope.
	for i in 300:
		falling = _motor.step(falling, idle, false, DT)
	assert_float(falling.y).is_equal(_config.max_fall_speed)
	# En el piso no acumula.
	var standing := _motor.step(Vector2.ZERO, idle, true, DT)
	assert_float(standing.y).is_equal(0.0)


func test_f003_ac03_jump_reaches_jump_height() -> void:
	var velocity := _motor.step(Vector2.ZERO, PlayerInput.new(0.0, true), true, DT)
	assert_float(velocity.y).is_less(0.0)
	# Igual que move_and_slide(): cada paso, la posición avanza velocidad × delta.
	# En Godot Y crece hacia abajo, así que subir es restar.
	var y := 0.0
	var highest := 0.0
	while velocity.y < 0.0:
		y += velocity.y * DT
		highest = minf(highest, y)
		velocity = _motor.step(velocity, PlayerInput.new(0.0, false), false, DT)
	assert_float(-highest).is_equal_approx(_config.jump_height, 2.0)


func test_f003_ac04_no_jump_in_air() -> void:
	var rising := Vector2(0.0, -100.0)
	var after := _motor.step(rising, PlayerInput.new(0.0, true), false, DT)
	# Solo actuó la gravedad: el salto no se repite en el aire.
	assert_float(after.y).is_equal_approx(-100.0 + _config.get_gravity() * DT, 0.001)


func test_f003_ac05_held_jump_does_not_repeat() -> void:
	# Salto mantenido desde antes: PlayerInput llega con jump_just_pressed en false.
	var held := PlayerInput.new(0.0, false)
	var landed := _motor.step(Vector2(0.0, 300.0), held, true, DT)
	assert_float(landed.y).is_equal(0.0)
