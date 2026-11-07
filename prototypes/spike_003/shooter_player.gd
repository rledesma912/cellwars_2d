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
## Largo de la línea de ayuda que marca hacia dónde apunta.
const GUN_LENGTH := 22.0
## Animaciones de disparo (de cw2d-art): impact, recovery y hold, sin loop.
const SHOT_ANIMS := {
	ShootLogic.Aim.FORWARD: &"disparar_adelante",
	ShootLogic.Aim.UP: &"disparar_arriba",
	ShootLogic.Aim.DOWN: &"disparar_abajo",
}
## Copia de los cuadros de Elyon con las tres animaciones de disparo sumadas. Vive en
## el prototipo para no tocar game/art en el spike.
const SHOOT_FRAMES := preload("res://prototypes/spike_003/art/elyon_disparo_frames.tres")

@export var shoot_config: ShootConfig

var _shoot: ShootLogic
var _aim := ShootLogic.Aim.FORWARD
var _stance := ShootLogic.Stance.READY
var _shots := 0
## Tiempo que le queda a la pose de tiro (0 = animaciones normales).
var _pose_timer := 0.0
## Línea de ayuda sobre el caño (show_aim_line en el .tres).
var _gun: Line2D


func _ready() -> void:
	# super() llama al _ready de Player: sin esto no se crearía el motor.
	super()
	_shoot = ShootLogic.new(shoot_config)
	_sprite.sprite_frames = SHOOT_FRAMES
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
	_stance = _stance_from(_motor.state)
	# Mientras está en pose de tiro no se llama a _animate: si no, cada paso volvería a
	# poner "quieto" y la animación de disparo arrancaría de cero todo el tiempo.
	if not _update_pose(r.fire, delta):
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
	info["pose de tiro"] = "%.2f s" % _pose_timer
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


## Pone la animación de disparo si corresponde. Devuelve true si está en pose de tiro.
func _update_pose(fired: bool, delta: float) -> bool:
	if _stance != ShootLogic.Stance.READY:
		_pose_timer = 0.0
		return false
	if fired or Input.is_action_pressed("shoot"):
		_pose_timer = shoot_config.aim_pose_time
	else:
		_pose_timer = maxf(_pose_timer - delta, 0.0)
	if _pose_timer <= 0.0:
		return false
	_sprite.flip_h = _motor.facing < 0
	var anim: StringName = SHOT_ANIMS[_aim]
	if fired:
		# Cada tiro arranca la animación desde el cuadro del impacto.
		_sprite.play(anim)
		_sprite.set_frame_and_progress(0, 0.0)
	elif _sprite.animation != anim:
		# Cambio de ángulo sin tirar: salta de golpe al mismo cuadro del otro ángulo.
		var frame := _sprite.frame if _is_shot_anim(_sprite.animation) else 2
		var progress := _sprite.frame_progress
		_sprite.play(anim)
		_sprite.set_frame_and_progress(frame, progress)
	return true


func _is_shot_anim(anim: StringName) -> bool:
	return SHOT_ANIMS.values().has(anim)


func _update_gun() -> void:
	_gun.visible = shoot_config.show_aim_line and _stance != ShootLogic.Stance.BUSY
	var tip := _muzzle()
	var dir := ShootLogic.direction(_aim, _motor.facing)
	_gun.points = PackedVector2Array([tip - dir * GUN_LENGTH, tip])
