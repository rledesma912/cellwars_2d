## Elyon con arma, solo para el prototipo S003.
##
## "extends Player" hereda todo el nodo del juego (motor, animación, muerte) y acá se
## reemplaza solo _physics_process para meter el disparo en el medio. Así game/ no se
## toca: el spike no cambia código de producción.
extends Player

## Salió un disparo: origen en coordenadas de la sala y dirección (largo 1).
signal shot_fired(origin: Vector2, direction: Vector2)

const STANCE_NAMES := {
	ShootLogic.Stance.READY: "listo",
	ShootLogic.Stance.MOVING: "en movimiento",
	ShootLogic.Stance.BUSY: "ocupado",
}
const AIM_NAMES := {
	ShootLogic.Aim.FORWARD: "adelante",
	ShootLogic.Aim.UP: "45° arriba",
	ShootLogic.Aim.DOWN: "45° abajo",
}
## Largo del caño greybox que marca hacia dónde apunta.
const GUN_LENGTH := 22.0

@export var shoot_config: ShootConfig

var _shoot: ShootLogic
var _aim := ShootLogic.Aim.FORWARD
var _stance := ShootLogic.Stance.READY
var _shots := 0
## Línea greybox que hace de arma hasta tener el arte (CLAUDE.md: greybox hasta el [feel]).
var _gun: Line2D


func _ready() -> void:
	# super() llama al _ready de Player: sin esto no se crearía el motor.
	super()
	_shoot = ShootLogic.new(shoot_config)
	_gun = Line2D.new()
	_gun.width = 5.0
	_gun.default_color = Color(0.35, 0.95, 1.0)
	add_child(_gun)


func _physics_process(delta: float) -> void:
	_aim = ShootLogic.aim_from(
		Input.is_action_pressed("move_up"), Input.is_action_pressed("move_down")
	)
	_stance = _stance_from(_motor.state)
	var r := (
		_shoot
		. step(
			Input.is_action_pressed("shoot"),
			Input.is_action_just_pressed("shoot"),
			_stance,
			delta,
		)
	)
	if r.stop_now:
		# Regla INSTANT_STOP: se corta la carrera sin pasar por frenar.
		velocity.x = 0.0
		_motor.state = PlayerMotor.State.IDLE
	# Plantado: se le esconde al motor la dirección y el salto, como si no se apretaran.
	var input := (
		PlayerInput
		. new(
			0.0 if r.hold_still else Input.get_axis("move_left", "move_right"),
			Input.is_action_just_pressed("jump") and not r.hold_still,
			Input.is_action_pressed("jump") and not r.hold_still,
		)
	)
	velocity = _motor.step(velocity, input, is_on_floor(), delta)
	move_and_slide()
	_animate(input.direction)
	_update_gun()
	if r.fire:
		_shots += 1
		shot_fired.emit(global_position + _muzzle(), ShootLogic.direction(_aim, _motor.facing))
	if _motor.is_death_finished():
		death_finished.emit()


func get_debug_info() -> Dictionary:
	var info := super()
	info["— disparo —"] = ""
	info["modo / sale"] = (
		"%s / %s"
		% [
			ShootConfig.Mode.keys()[shoot_config.mode],
			ShootConfig.Delivery.keys()[shoot_config.delivery],
		]
	)
	info["corriendo"] = ShootConfig.RunRule.keys()[shoot_config.run_rule]
	info["apunta"] = AIM_NAMES[_aim]
	info["situación"] = STANCE_NAMES[_stance]
	info["próximo tiro en"] = "%.2f s" % _shoot.get_cooldown()
	info["plantado"] = "%.2f s" % _shoot.get_recovery()
	info["ráfaga restante / en espera"] = (
		"%d / %s" % [_shoot.get_burst_left(), "sí" if _shoot.is_pending() else "no"]
	)
	info["disparos"] = str(_shots)
	return info


func _stance_from(state: PlayerMotor.State) -> ShootLogic.Stance:
	match state:
		PlayerMotor.State.IDLE:
			return ShootLogic.Stance.READY
		PlayerMotor.State.RUN, PlayerMotor.State.BRAKE:
			return ShootLogic.Stance.MOVING
		_:
			return ShootLogic.Stance.BUSY


## Boca del arma relativa a los pies, espejada según hacia dónde mira.
func _muzzle() -> Vector2:
	var m: Vector2 = shoot_config.muzzle_forward
	match _aim:
		ShootLogic.Aim.UP:
			m = shoot_config.muzzle_up
		ShootLogic.Aim.DOWN:
			m = shoot_config.muzzle_down
	return Vector2(m.x * _motor.facing, m.y)


func _update_gun() -> void:
	# El caño se ve solo cuando puede disparar o está por hacerlo, para no confundir.
	_gun.visible = _stance != ShootLogic.Stance.BUSY
	var tip := _muzzle()
	var dir := ShootLogic.direction(_aim, _motor.facing)
	_gun.points = PackedVector2Array([tip - dir * GUN_LENGTH, tip])
