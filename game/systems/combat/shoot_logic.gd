## Reglas del disparo de Elyon (D0006, D0007; spec F012): cuándo sale un tiro, hacia
## dónde y desde dónde, y cuánto dura la pose de tiro.
##
## Lógica pura (sin árbol): el nodo Player le pasa el botón ya leído y en qué
## situación está Elyon, y aplica lo que devuelve. Disparar nunca cambia el movimiento.
class_name ShootLogic
extends RefCounted

## En qué situación está Elyon, vista desde el disparo.
enum Stance {
	READY,  ## Quieto en el piso: dispara con la pose de disparo de pie.
	MOVING,  ## Corriendo o frenando: dispara sin frenar.
	AIR,  ## Subiendo o cayendo: dispara sin cambiar el salto.
	BUSY,  ## Girando, preparando el salto, aterrizando, rodando o muerto: no dispara.
}

## Hacia dónde apunta. Cambia de golpe, sin pasar por ángulos intermedios.
enum Aim { FORWARD, UP, DOWN }

var _config: ShootConfig
## Tiempo hasta que se pueda disparar de nuevo. Es el tope de cadencia.
var _cooldown := 0.0
## Tiempo que le queda a la pose de tiro (0 = sin pose).
var _pose := 0.0


func _init(config: ShootConfig) -> void:
	_config = config


## Ángulo según arriba/abajo. Los dos juntos (o ninguno) apuntan adelante.
static func aim_from(up: bool, down: bool) -> Aim:
	if up == down:
		return Aim.FORWARD
	return Aim.UP if up else Aim.DOWN


## La situación del disparo según el estado del motor de movimiento.
static func stance_for(state: PlayerMotor.State) -> Stance:
	match state:
		PlayerMotor.State.IDLE:
			return Stance.READY
		PlayerMotor.State.RUN, PlayerMotor.State.BRAKE:
			return Stance.MOVING
		PlayerMotor.State.AIR:
			return Stance.AIR
		_:
			return Stance.BUSY


## Dirección del tiro (largo 1). facing: 1 derecha, −1 izquierda. En el aire, el tiro
## hacia abajo usa su propio ángulo. El eje y de Godot crece hacia abajo: "arriba" es
## y negativo.
static func direction(aim: Aim, facing: int, config: ShootConfig, in_air: bool) -> Vector2:
	match aim:
		Aim.UP:
			var up := deg_to_rad(config.aim_up_angle)
			return Vector2(cos(up) * facing, -sin(up))
		Aim.DOWN:
			var down := deg_to_rad(config.air_aim_down_angle if in_air else config.aim_down_angle)
			return Vector2(cos(down) * facing, sin(down))
		_:
			return Vector2(facing, 0)


## Boca del arma respecto de los pies, espejada según hacia dónde mira.
static func muzzle(aim: Aim, facing: int, config: ShootConfig) -> Vector2:
	var m := config.muzzle_forward
	match aim:
		Aim.UP:
			m = config.muzzle_up
		Aim.DOWN:
			m = config.muzzle_down
	return Vector2(m.x * facing, m.y)


## Un paso de física. held: el botón sigue apretado; pressed: se apretó en este paso.
## Devuelve true si sale un tiro.
func step(held: bool, pressed: bool, stance: Stance, delta: float) -> bool:
	_cooldown = maxf(_cooldown - delta, 0.0)
	_pose = maxf(_pose - delta, 0.0)
	if stance == Stance.BUSY:
		_pose = 0.0
		return false
	var fired := false
	# Automático: mientras siga apretado dispara cada fire_interval. Volver a apretar
	# no salta el tope, porque también espera a que _cooldown llegue a 0.
	if (held or pressed) and _cooldown <= 0.0:
		_cooldown = _config.fire_interval
		fired = true
	# De pie, mantener apretado sostiene la pose aunque todavía no toque otro tiro.
	if fired or (held and stance == Stance.READY):
		_pose = _config.aim_pose_time
	return fired


## Está en pose de tiro: de pie se muestra la animación de disparo; en movimiento, la
## línea del arma.
func is_in_pose() -> bool:
	return _pose > 0.0


func get_cooldown() -> float:
	return _cooldown


func get_pose_time() -> float:
	return _pose
