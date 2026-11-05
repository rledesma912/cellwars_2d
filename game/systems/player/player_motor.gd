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

enum State { IDLE, RUN, BRAKE, TURN, JUMP_PREP, AIR, LAND, ROLL, DEAD }
## Por qué murió: decide cuánto dura la muerte.
enum DeathCause { HAZARD, VOID, FALL }
## Qué tan grave es la caída contada: decide la animación y si aterrizar mata.
enum FallSeverity { NORMAL, LONG, LETHAL }

## Estado actual. Solo lectura desde afuera.
var state: State = State.IDLE
## 1 = mira a la derecha, −1 = a la izquierda.
var facing: int = 1

var _config: PlayerMovementConfig
# Tiempo restante del estado actual (giro, preparación, recuperación o rodar).
var _state_timer: float = 0.0
# Tiempo que queda para saltar después de pisar el vacío (coyote time).
var _coyote: float = 0.0
# Tiempo que queda para que un salto apretado antes de tiempo todavía valga (jump buffer).
var _buffer: float = 0.0
# Si está en el aire por un salto (y no por caminar al vacío): solo así vale el corte
# del salto variable, y no hay coyote time.
var _jumping: bool = false
# Cuánto bajó desde el punto más alto, para saber si el aterrizaje es pesado.
var _fall_distance: float = 0.0


func _init(config: PlayerMovementConfig) -> void:
	_config = config


## Vuelve a quieto, mirando a la derecha y con los timers en cero.
func reset() -> void:
	state = State.IDLE
	facing = 1
	_state_timer = 0.0
	_coyote = 0.0
	_buffer = 0.0
	_jumping = false
	_fall_distance = 0.0


## Mata a Elyon: pierde el control hasta que algo llame a reset(). Morir estando ya
## muerto no cambia nada, así tocar otra zona mortal no alarga la espera.
func die(cause: DeathCause) -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	_state_timer = _config.void_restart_time if cause == DeathCause.VOID else _config.death_time
	# Lo que estuviera en curso se corta: un salto apretado no sale al reaparecer.
	_buffer = 0.0
	_coyote = 0.0
	_jumping = false


## true desde que murió hasta que se reinicia.
func is_dead() -> bool:
	return state == State.DEAD


## true cuando pasó el tiempo de la muerte: ya se puede volver a la entrada de la sala.
func is_death_finished() -> bool:
	return state == State.DEAD and _state_timer <= 0.0


## Píxeles que bajó desde el punto más alto. Después de aterrizar conserva la última
## caída hasta volver al aire: el overlay la muestra y sirve para medir.
func get_fall_distance() -> float:
	return _fall_distance


## Gravedad de la caída contada. Si un límite se ajusta por encima del otro, manda el mortal.
func get_fall_severity() -> FallSeverity:
	if _fall_distance >= _config.lethal_fall_height:
		return FallSeverity.LETHAL
	if _fall_distance >= _config.long_fall_height:
		return FallSeverity.LONG
	return FallSeverity.NORMAL


## Vuelve a contar la caída desde 0, sin tocar nada más: al entrar a otra sala, una caída
## no suma lo que bajó en la anterior, porque moriría al llegar a un lugar que recién ve.
func reset_fall() -> void:
	_fall_distance = 0.0


## Segundos que le quedan al giro, la preparación, la recuperación o rodar.
func get_state_timer() -> float:
	return _state_timer


## Segundos que quedan de coyote time.
func get_coyote() -> float:
	return _coyote


## Segundos que quedan de jump buffer.
func get_buffer() -> float:
	return _buffer


## En Godot el eje Y crece hacia abajo: velocidad Y negativa es subir.
func step(velocity: Vector2, input: PlayerInput, on_floor: bool, delta: float) -> Vector2:
	# Primero que nada: muerto no se mira el input, ni siquiera para el jump buffer.
	if state == State.DEAD:
		return _dead(velocity, on_floor, delta)
	return _alive(velocity, input, on_floor, delta)


func _alive(velocity: Vector2, input: PlayerInput, on_floor: bool, delta: float) -> Vector2:
	# Jump buffer: un salto vale si se apretó ahora o hace menos de jump_buffer_time.
	if input.jump_just_pressed:
		_buffer = _config.jump_buffer_time
	var wants_jump := input.jump_just_pressed or _buffer > 0.0
	_buffer = maxf(_buffer - delta, 0.0)

	if on_floor:
		_coyote = _config.coyote_time
		if state == State.AIR:
			_land(velocity)
	elif state != State.AIR:
		# Se fue del piso sin saltar (caminó al vacío, o el impulso lo sacó del borde
		# durante la preparación): cae sin saltar. El coyote time sigue corriendo.
		_enter_air(false)

	# Aterrizar pudo matarlo: desde este mismo paso ya no se mira el input.
	if state == State.DEAD:
		return _dead(velocity, on_floor, delta)
	return _act(velocity, input, wants_jump, delta)


func _act(velocity: Vector2, input: PlayerInput, wants_jump: bool, delta: float) -> Vector2:
	match state:
		State.IDLE, State.RUN, State.BRAKE:
			return _ground(velocity, input, wants_jump, delta)
		State.TURN:
			return _turn(delta)
		State.JUMP_PREP:
			return _prep(velocity, input, delta)
		State.LAND:
			return _recover(velocity, delta)
		State.ROLL:
			return _roll(velocity, delta)
		_:
			return _air(velocity, input, wants_jump, delta)


func _ground(v: Vector2, input: PlayerInput, wants_jump: bool, delta: float) -> Vector2:
	v.y = 0.0
	if wants_jump:
		_buffer = 0.0
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


# Entra en un estado que dura "duration" (giro, preparación). El paso en que entra
# ya cuenta como parte de esa duración; si no, duraría un paso de más.
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


func _recover(v: Vector2, delta: float) -> Vector2:
	# Sin control: ignora la dirección y frena.
	v.y = 0.0
	v.x = move_toward(v.x, 0.0, _config.get_decel_rate() * delta)
	_state_timer -= delta
	if _state_timer <= 0.0:
		_state_timer = 0.0
		state = State.IDLE
	return v


func _roll(v: Vector2, delta: float) -> Vector2:
	# Sin control, como la recuperación, pero conserva la velocidad en vez de frenar.
	v.y = 0.0
	_state_timer -= delta
	if _state_timer <= 0.0:
		_state_timer = 0.0
		state = State.IDLE
	return v


# La altura no se sigue contando: queda la del momento de morir. Si no, una muerte por
# zona mortal en el aire cambiaría de animación a mitad de camino al pasar el límite.
func _dead(v: Vector2, on_floor: bool, delta: float) -> Vector2:
	_state_timer = maxf(_state_timer - delta, 0.0)
	if on_floor:
		v.y = 0.0
		v.x = move_toward(v.x, 0.0, _config.get_decel_rate() * delta)
	else:
		# Siempre la gravedad de caída, también si venía subiendo. La velocidad horizontal
		# se mantiene: en el aire no hay rozamiento y sigue la trayectoria que traía.
		v.y = minf(v.y + _config.get_fall_gravity() * delta, _config.max_fall_speed)
	return v


func _air(v: Vector2, input: PlayerInput, wants_jump: bool, delta: float) -> Vector2:
	# Coyote time: pisó el vacío hace un instante, todavía puede saltar (sin preparación).
	if wants_jump and _coyote > 0.0 and not _jumping:
		_buffer = 0.0
		return _launch(v, input, delta)
	_coyote = maxf(_coyote - delta, 0.0)

	if _config.air_control > 0.0:
		# Puede frenar o corregir, pero no ir para el lado contrario al que mira: el
		# objetivo se recorta entre 0 y run_speed en esa dirección. No se da vuelta.
		var target := input.direction * _config.run_speed
		target = clampf(target * facing, 0.0, _config.run_speed) * facing
		var rate := _config.get_accel_rate() * _config.air_control
		v.x = move_toward(v.x, target, rate * delta)

	# Salto variable: si suelta el botón mientras sube rápido, la subida se corta a la
	# velocidad que todavía llega a min_jump_height.
	var release := _config.get_release_velocity()
	if _jumping and not input.jump_held and v.y < -release:
		v.y = -release

	var gravity := _config.get_gravity() if v.y < 0.0 else _config.get_fall_gravity()
	v.y = minf(v.y + gravity * delta, _config.max_fall_speed)
	if v.y > 0.0:
		_fall_distance += v.y * delta
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
	_enter_air(true)
	_coyote = 0.0
	return v


func _enter_air(jumped: bool) -> void:
	state = State.AIR
	_jumping = jumped
	_fall_distance = 0.0


func _land(v: Vector2) -> void:
	_jumping = false
	if get_fall_severity() == FallSeverity.LETHAL:
		die(DeathCause.FALL)
	elif _fall_distance < _config.hard_landing_height:
		state = State.IDLE
	elif _can_roll(v):
		# Los timers arrancan enteros: _roll y _recover los descuentan en este mismo paso.
		state = State.ROLL
		_state_timer = _config.roll_time
	elif _config.land_recovery_time > 0.0:
		state = State.LAND
		_state_timer = _config.land_recovery_time
	else:
		state = State.IDLE


# Rueda si llega con velocidad suficiente y hacia donde mira.
func _can_roll(v: Vector2) -> bool:
	if _config.roll_time <= 0.0 or int(signf(v.x)) != facing:
		return false
	return absf(v.x) >= _config.roll_min_speed_fraction * _config.run_speed
