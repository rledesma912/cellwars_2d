## Spike 001: motor de movimiento con estados, para comparar variantes.
##
## Lógica pura, como PlayerMotor: recibe velocidad, input y si está en el piso, y
## devuelve la velocidad nueva. Además lleva un estado (enum) que decide qué acciones
## valen en cada momento y que la silueta usa para elegir su animación.
##
## Máquina de estados con enum y no con nodos: son 7 estados con poca lógica de
## entrada/salida, y así sigue siendo lógica pura (sin árbol de escena).
class_name Spike001Motor
extends RefCounted

enum State { IDLE, RUN, BRAKE, TURN, JUMP_PREP, AIR, LAND }

var config: Spike001Config
var state: State = State.IDLE
## 1 = mira a la derecha, -1 = a la izquierda.
var facing: int = 1
## true solo en el paso en que tocó el piso.
var just_landed: bool = false
## true solo en el paso en que despegó.
var just_jumped: bool = false
## Altura de la última caída (desde el punto más alto hasta el piso).
var last_fall_height: float = 0.0

# Tiempo restante del estado actual (giro, preparación o recuperación).
var _timer: float = 0.0
var _coyote: float = 0.0
var _buffer: float = 0.0
var _fall_distance: float = 0.0
# Si está en el aire por un salto (y no por caminar al vacío).
var _jumping: bool = false
# Hacia dónde miraba al despegar (para el aire sin vuelta atrás).
var _air_facing: int = 1


func _init(p_config: Spike001Config) -> void:
	config = p_config


func reset() -> void:
	state = State.IDLE
	_timer = 0.0
	_coyote = 0.0
	_buffer = 0.0
	_jumping = false


func get_timer() -> float:
	return _timer


func get_coyote() -> float:
	return _coyote


func get_buffer() -> float:
	return _buffer


func step(velocity: Vector2, input: Spike001Input, on_floor: bool, delta: float) -> Vector2:
	just_landed = false
	just_jumped = false
	if input.jump_pressed:
		_buffer = config.jump_buffer_time
	# Un salto vale si se apretó ahora o hace menos de jump_buffer_time.
	var wants_jump := input.jump_pressed or _buffer > 0.0
	_buffer = maxf(_buffer - delta, 0.0)

	if on_floor:
		_coyote = config.coyote_time
		if state == State.AIR:
			_land()
	elif state != State.AIR:
		# Se fue del piso sin saltar: caminó al vacío. El coyote sigue corriendo.
		_enter_air(false)
	else:
		_coyote = maxf(_coyote - delta, 0.0)

	match state:
		State.IDLE, State.RUN, State.BRAKE:
			return _ground(velocity, input, wants_jump, delta)
		State.TURN:
			return _turn(velocity, delta)
		State.JUMP_PREP:
			return _prep(velocity, delta)
		State.LAND:
			return _recover(velocity, delta)
		_:
			return _air(velocity, input, wants_jump, delta)


func _ground(v: Vector2, input: Spike001Input, wants_jump: bool, delta: float) -> Vector2:
	v.y = 0.0
	if wants_jump:
		_buffer = 0.0
		if config.jump_prep_time > 0.0:
			# Compromiso: durante la preparación se ignora el input y sigue el impulso.
			state = State.JUMP_PREP
			_timer = config.jump_prep_time
			return v
		return _launch(v, delta)

	var dir := int(signf(input.direction))
	if dir != 0 and dir != facing:
		if config.turn_time <= 0.0:
			facing = dir
		elif absf(v.x) < 1.0:
			state = State.TURN
			_timer = config.turn_time
			v.x = 0.0
			return v
		else:
			# Viene corriendo para el otro lado: primero frena, después gira.
			state = State.BRAKE
			v.x = move_toward(v.x, 0.0, config.rate_for(config.decel_time) * delta)
			return v

	var target := input.direction * config.run_speed if dir != 0 else 0.0
	var speeding_up := dir != 0 and (v.x == 0.0 or signf(v.x) == dir) and absf(target) > absf(v.x)
	var rate := config.rate_for(config.accel_time if speeding_up else config.decel_time)
	v.x = move_toward(v.x, target, rate * delta)

	if dir == 0 or (v.x != 0.0 and signf(v.x) != dir):
		state = State.BRAKE if absf(v.x) > 1.0 else State.IDLE
	else:
		state = State.RUN
	return v


func _turn(v: Vector2, delta: float) -> Vector2:
	v = Vector2.ZERO
	_timer -= delta
	if _timer <= 0.0:
		facing = -facing
		state = State.IDLE
	return v


func _prep(v: Vector2, delta: float) -> Vector2:
	v.y = 0.0
	_timer -= delta
	if _timer <= 0.0:
		return _launch(v, delta)
	return v


func _recover(v: Vector2, delta: float) -> Vector2:
	v.y = 0.0
	v.x = move_toward(v.x, 0.0, config.rate_for(config.decel_time) * delta)
	_timer -= delta
	if _timer <= 0.0:
		state = State.IDLE
	return v


func _air(v: Vector2, input: Spike001Input, wants_jump: bool, delta: float) -> Vector2:
	if wants_jump and _coyote > 0.0 and not _jumping:
		# Coyote time: pisó el vacío hace un instante, todavía puede saltar.
		_buffer = 0.0
		return _launch(v, delta)

	if config.air_control > 0.0:
		var target := input.direction * config.run_speed
		if not config.air_can_reverse:
			# Puede frenar o corregir, pero no ir para atrás de donde saltó.
			target = clampf(target * _air_facing, 0.0, config.run_speed) * _air_facing
		var rate := config.rate_for(config.accel_time) * config.air_control
		v.x = move_toward(v.x, target, rate * delta)
		var dir := int(signf(input.direction))
		if config.air_can_reverse and dir != 0:
			facing = dir

	# Salto variable: al soltar el botón subiendo, se corta la subida.
	if _jumping and not input.jump_held and v.y < -config.get_release_velocity():
		v.y = -config.get_release_velocity()

	var gravity := config.get_gravity() if v.y < 0.0 else config.get_fall_gravity()
	v.y = minf(v.y + gravity * delta, config.max_fall_speed)
	if v.y > 0.0:
		_fall_distance += v.y * delta
	return v


func _launch(v: Vector2, delta: float) -> Vector2:
	# Misma corrección de medio paso que PlayerMotor (F003): la altura real del salto
	# queda igual a jump_height aunque Godot calcule en pasos de 1/60 s.
	v.y = -config.get_jump_velocity() + config.get_gravity() * delta * 0.5
	_enter_air(true)
	_coyote = 0.0
	just_jumped = true
	return v


func _enter_air(jumped: bool) -> void:
	state = State.AIR
	_jumping = jumped
	_fall_distance = 0.0
	_air_facing = facing


func _land() -> void:
	just_landed = true
	last_fall_height = _fall_distance
	_jumping = false
	if config.land_recovery_time > 0.0 and _fall_distance >= config.hard_landing_height:
		state = State.LAND
		_timer = config.land_recovery_time
	else:
		state = State.IDLE
