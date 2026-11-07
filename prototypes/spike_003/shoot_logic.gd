## Reglas del disparo del prototipo S003: cuándo sale un tiro y cuándo Elyon tiene
## que quedarse quieto. Lógica pura (sin árbol): el nodo le pasa el gatillo ya leído y
## en qué situación está Elyon, y aplica lo que devuelve.
class_name ShootLogic
extends RefCounted

## En qué situación está Elyon, vista desde el disparo.
enum Stance {
	READY,  ## Quieto en el piso: puede disparar.
	MOVING,  ## Corriendo o frenando: depende de la regla run_rule.
	BUSY,  ## Girando, saltando, en el aire, rodando o muerto: no dispara.
}

enum Aim { FORWARD, UP, DOWN }


## Lo que el nodo tiene que hacer en este paso.
class Result:
	extends RefCounted
	## Sale un disparo.
	var fire := false
	## Anular la dirección y el salto: Elyon se queda plantado (o frena, si corría).
	var hold_still := false
	## Cortar la carrera en seco (regla INSTANT_STOP).
	var stop_now := false


var _config: ShootConfig
var _cooldown := 0.0
var _recovery := 0.0
var _burst_left := 0
var _burst_timer := 0.0
## Un apretón que espera a que Elyon termine de frenar (regla BRAKE_THEN_SHOOT).
var _pending := false


func _init(config: ShootConfig) -> void:
	_config = config


## Ángulo según arriba/abajo. Los dos juntos (o ninguno) apuntan adelante.
static func aim_from(up: bool, down: bool) -> Aim:
	if up == down:
		return Aim.FORWARD
	return Aim.UP if up else Aim.DOWN


## Dirección del disparo. facing: 1 derecha, −1 izquierda. El eje y de Godot crece
## hacia abajo, por eso "arriba" es y negativo.
static func direction(aim: Aim, facing: int) -> Vector2:
	match aim:
		Aim.UP:
			return Vector2(facing, -1).normalized()
		Aim.DOWN:
			return Vector2(facing, 1).normalized()
		_:
			return Vector2(facing, 0)


func step(held: bool, pressed: bool, stance: Stance, delta: float) -> Result:
	var r := Result.new()
	_cooldown = maxf(_cooldown - delta, 0.0)
	_recovery = maxf(_recovery - delta, 0.0)
	_burst_timer = maxf(_burst_timer - delta, 0.0)
	if stance == Stance.BUSY:
		_pending = false
		_burst_left = 0
		return r
	var trigger := pressed or _pending
	var wants := trigger or (_config.mode == ShootConfig.Mode.AUTO and held)
	if stance == Stance.MOVING and _burst_left == 0:
		match _config.run_rule:
			ShootConfig.RunRule.FORBID:
				_pending = false
				return r
			ShootConfig.RunRule.BRAKE_THEN_SHOOT:
				if wants:
					# Automático no necesita recordar: mientras siga apretado, sigue queriendo.
					_pending = _config.mode != ShootConfig.Mode.AUTO
					r.hold_still = true
				return r
			ShootConfig.RunRule.INSTANT_STOP:
				if not wants:
					return r
				r.stop_now = true
	r.fire = _try_fire(held, trigger)
	_pending = false
	r.hold_still = _recovery > 0.0 or _burst_left > 0
	return r


func get_cooldown() -> float:
	return maxf(_cooldown, _burst_timer if _burst_left > 0 else 0.0)


func get_recovery() -> float:
	return _recovery


func get_burst_left() -> int:
	return _burst_left


func is_pending() -> bool:
	return _pending


func _try_fire(held: bool, trigger: bool) -> bool:
	match _config.mode:
		ShootConfig.Mode.SEMI:
			if trigger and _cooldown <= 0.0:
				_cooldown = _config.semi_interval
				return _shot()
		ShootConfig.Mode.AUTO:
			if (held or trigger) and _cooldown <= 0.0:
				_cooldown = _config.auto_interval
				return _shot()
		ShootConfig.Mode.BURST:
			if _burst_left > 0:
				return _burst_shot() if _burst_timer <= 0.0 else false
			if trigger and _cooldown <= 0.0:
				_burst_left = _config.burst_count
				return _burst_shot()
	return false


func _burst_shot() -> bool:
	_burst_left -= 1
	_burst_timer = _config.burst_spacing
	if _burst_left == 0:
		_cooldown = _config.burst_pause
	return _shot()


func _shot() -> bool:
	_recovery = _config.shot_recovery
	return true
