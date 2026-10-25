## Reglas del movimiento del soldado: correr, frenar, girar, saltar y caer (D0003).
##
## Lógica pura: recibe la velocidad actual, lo que pidió el jugador y si está en el
## piso, y devuelve la velocidad nueva. No mueve nada: eso lo hace el nodo Player con
## move_and_slide(). Por eso se puede testear sin escenas.
##
## Lleva un estado (enum) que decide qué acciones valen en cada momento; el nodo lo
## usa además para elegir la animación. Máquina de estados con enum y no con nodos:
## son pocos estados con poca lógica de entrada y salida, y así sigue siendo lógica pura.
class_name PlayerMotor
extends RefCounted

enum State { IDLE, RUN, BRAKE, TURN, JUMP_PREP, AIR, LAND }

## Estado actual. Solo lectura desde afuera.
var state: State = State.IDLE
## 1 = mira a la derecha, −1 = a la izquierda.
var facing: int = 1

var _config: PlayerMovementConfig
# Tiempo restante del estado actual (giro, preparación o recuperación).
var _state_timer: float = 0.0
# Si está en el aire por un salto (y no por caminar al vacío): solo así vale el corte.
var _jumping: bool = false


func _init(config: PlayerMovementConfig) -> void:
	_config = config


## Vuelve a quieto, mirando a la derecha y con los timers en cero.
func reset() -> void:
	state = State.IDLE
	facing = 1
	_state_timer = 0.0
	_jumping = false


## Segundos que le quedan al giro, la preparación o la recuperación.
func get_state_timer() -> float:
	return _state_timer


## En Godot el eje Y crece hacia abajo: velocidad Y negativa es subir.
func step(velocity: Vector2, input: PlayerInput, on_floor: bool, delta: float) -> Vector2:
	if on_floor:
		if state == State.AIR:
			state = State.IDLE
			_jumping = false
	elif state != State.AIR:
		# Se fue del piso sin saltar (caminó al vacío, o el impulso lo sacó del borde
		# durante la preparación): cae sin saltar.
		state = State.AIR
		_jumping = false

	match state:
		State.IDLE, State.RUN, State.BRAKE:
			return _ground(velocity, input, delta)
		State.TURN:
			return _turn(delta)
		State.JUMP_PREP:
			return _prep(velocity, input, delta)
		_:
			return _air(velocity, input, delta)


func _ground(v: Vector2, input: PlayerInput, delta: float) -> Vector2:
	v.y = 0.0
	if input.jump_just_pressed:
		if _config.jump_prep_time > 0.0:
			# Compromiso: durante la preparación se ignora la dirección y sigue el impulso.
			_enter_timed(State.JUMP_PREP, _config.jump_prep_time, delta)
			if _state_timer > 0.0:
				return v
		return _launch(v, input, delta)

	var dir := int(signf(input.direction))
	if dir != 0 and dir != facing:
		if _config.turn_time <= 0.0:
			facing = dir
		elif absf(v.x) < 1.0:
			# Quieto (o casi): se da vuelta en el lugar.
			_enter_timed(State.TURN, _config.turn_time, delta)
			v.x = 0.0
			return v
		else:
			# Viene corriendo para el otro lado: primero frena, después gira.
			state = State.BRAKE
			v.x = move_toward(v.x, 0.0, _config.get_decel_rate() * delta)
			return v

	# Con stick a medias, la velocidad objetivo se escala con la inclinación.
	var target := input.direction * _config.run_speed if dir != 0 else 0.0
	var speeding_up := dir != 0 and absf(target) > absf(v.x)
	var rate := _config.get_accel_rate() if speeding_up else _config.get_decel_rate()
	# move_toward avanza hacia target sin pasarse: nunca frena de más ni acelera de más.
	v.x = move_toward(v.x, target, rate * delta)

	if dir == 0:
		state = State.BRAKE if absf(v.x) > 0.0 else State.IDLE
	else:
		state = State.RUN
	return v


# Entra en un estado que dura "duration" (giro, preparación, recuperación). El paso en
# que entra ya cuenta como parte de esa duración; si no, duraría un paso de más.
func _enter_timed(new_state: State, duration: float, delta: float) -> void:
	state = new_state
	_state_timer = duration - delta


func _turn(delta: float) -> Vector2:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_state_timer = 0.0
		facing = -facing
		state = State.IDLE
	return Vector2.ZERO


func _prep(v: Vector2, input: PlayerInput, delta: float) -> Vector2:
	v.y = 0.0
	_state_timer -= delta
	if _state_timer <= 0.0:
		_state_timer = 0.0
		return _launch(v, input, delta)
	return v


# Provisorio hasta la T4: sin control horizontal ni ayudas en el aire.
func _air(v: Vector2, input: PlayerInput, delta: float) -> Vector2:
	# Salto variable: si suelta el botón mientras sube rápido, la subida se corta a la
	# velocidad que todavía llega a min_jump_height.
	var release := _config.get_release_velocity()
	if _jumping and not input.jump_held and v.y < -release:
		v.y = -release

	var gravity := _config.get_gravity() if v.y < 0.0 else _config.get_fall_gravity()
	v.y = minf(v.y + gravity * delta, _config.max_fall_speed)
	return v


func _launch(v: Vector2, input: PlayerInput, delta: float) -> Vector2:
	# Si ya soltó el botón (toque corto durante la preparación), despega directo con
	# la velocidad de corte: así llega justo a min_jump_height.
	var speed := _config.get_jump_velocity()
	if not input.jump_held:
		speed = minf(speed, _config.get_release_velocity())
	# Godot mueve en pasos (60 por segundo) usando la velocidad de cada paso, y así
	# el salto subiría unos píxeles de más. Restar la gravedad de medio paso al
	# despegar compensa ese error: la altura real queda igual a la buscada.
	v.y = -speed + _config.get_gravity() * delta * 0.5
	state = State.AIR
	_jumping = true
	return v
