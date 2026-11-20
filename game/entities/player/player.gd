## El protagonista: Elyon, el soldado (77 px; D0005).
##
## Nodo fino: lee las teclas, le pide a PlayerMotor la velocidad nueva y se mueve.
## Las reglas (cuánto corre, cómo cae, cuándo puede saltar) están en PlayerMotor, qué
## animación mostrar está en PlayerAnimation y cuándo sale un tiro está en ShootLogic
## (F012). Acá solo se aplica. El proyectil no lo crea Elyon: avisa con shot_fired y
## World lo pone en la sala.
##
## Su origen (posición) está en los pies, al centro: así ponerlo "parado" en un punto
## del piso es darle esa posición, sin sumar la mitad de su alto.
class_name Player
extends CharacterBody2D

## Terminó el tiempo de la muerte: ya se puede volver a la entrada de la sala.
signal death_finished
## Salió un tiro. Todo en coordenadas del mundo: origin es la boca del arma, direction
## tiene largo 1 y guard_from es el centro de Elyon a la altura de la boca (el primer
## tramo del proyectil arranca ahí, para que pegado a una pared no la atraviese).
signal shot_fired(origin: Vector2, direction: Vector2, guard_from: Vector2)

## Nombres del estado del motor para el overlay de debug.
const STATE_NAMES := {
	PlayerMotor.State.IDLE: "quieto",
	PlayerMotor.State.RUN: "correr",
	PlayerMotor.State.BRAKE: "frenar",
	PlayerMotor.State.TURN: "girar",
	PlayerMotor.State.JUMP_PREP: "preparar salto",
	PlayerMotor.State.AIR: "en el aire",
	PlayerMotor.State.LAND: "recuperarse",
	PlayerMotor.State.ROLL: "rodar",
	PlayerMotor.State.DEAD: "morir",
}

const AIM_NAMES := {
	ShootLogic.Aim.FORWARD: "adelante",
	ShootLogic.Aim.UP: "arriba",
	ShootLogic.Aim.DOWN: "abajo",
}
## Parámetros del movimiento. La escena usa game/data/player_movement.tres.
@export var config: PlayerMovementConfig
## Parámetros del disparo. La escena usa game/data/shoot.tres.
@export var shoot_config: ShootConfig

var _motor: PlayerMotor
var _shoot: ShootLogic
var _aim := ShootLogic.Aim.FORWARD
var _stance := ShootLogic.Stance.READY
var _shots := 0

@onready var _shape: CollisionShape2D = %Shape
# AnimatedSprite2D pasa los cuadros de una animación de SpriteFrames, como un flipbook.
# Sus cuadros miden 144 × 144 con los pies abajo al centro; el offset los pone en el
# origen. Usa el material de suavizado (sharp_pixel) con filtro lineal: ver player.tscn.
@onready var _sprite: AnimatedSprite2D = %Sprite


func _ready() -> void:
	_motor = PlayerMotor.new(config)
	_shoot = ShootLogic.new(shoot_config)


# _physics_process corre 60 veces por segundo, a ritmo fijo: es donde va el movimiento.
func _physics_process(delta: float) -> void:
	# get_axis da −1, 0 o 1 con teclas (o un valor intermedio con el stick) y ya
	# aplica la zona muerta del gamepad. Izquierda y derecha juntas se anulan en 0.
	# is_action_just_pressed es true solo en el paso en que se apretó: mantener no repite.
	# is_action_pressed es true mientras siga apretado: soltarlo antes corta el salto.
	var input := (
		PlayerInput
		. new(
			Input.get_axis("move_left", "move_right"),
			Input.is_action_just_pressed("jump"),
			Input.is_action_pressed("jump"),
		)
	)
	velocity = _motor.step(velocity, input, is_on_floor(), delta)
	# move_and_slide() mueve según velocity, frena contra paredes y pisos y actualiza
	# is_on_floor() para el próximo paso.
	move_and_slide()
	# El disparo mira dónde quedó Elyon después de moverse: si en este paso empezó a
	# caer, ya tira con el ángulo del aire. Disparar no cambia el movimiento.
	_stance = ShootLogic.stance_for(_motor.state)
	_aim = ShootLogic.aim_from(
		Input.is_action_pressed("move_up"), Input.is_action_pressed("move_down")
	)
	var fired := _shoot.step(
		Input.is_action_pressed("shoot"), Input.is_action_just_pressed("shoot"), _stance, delta
	)
	if fired:
		_shots += 1
		var muzzle := ShootLogic.muzzle(_aim, _motor.facing, shoot_config)
		(
			shot_fired
			. emit(
				global_position + muzzle,
				_direction(),
				global_position + Vector2(0.0, muzzle.y),
			)
		)
	# De pie y en pose se muestra la animación de disparo; si no, la de siempre. Si
	# _animate corriera también, cada paso volvería a poner "quieto" y la animación de
	# disparo arrancaría de cero todo el tiempo.
	if _stance == ShootLogic.Stance.READY and _shoot.is_in_pose():
		_show_shot_pose(fired)
	else:
		_animate(input.direction)
	# Se emite una sola vez: quien la recibe llama a reset_to y deja de estar muerto.
	if _motor.is_death_finished():
		death_finished.emit()


## Lo pone quieto en un punto (por ejemplo, el inicio de la sala).
func reset_to(feet_position: Vector2) -> void:
	position = feet_position
	velocity = Vector2.ZERO
	_motor.reset()
	_animate(0.0)


## Lo mata. Morir estando ya muerto no cambia nada.
func die(cause: PlayerMotor.DeathCause) -> void:
	_motor.die(cause)


func is_dead() -> bool:
	return _motor.is_dead()


func is_grounded() -> bool:
	return _motor.is_grounded()


## Rectángulo que ocupa el personaje, en coordenadas de la sala.
func get_bounds() -> Rect2:
	var size := (_shape.shape as RectangleShape2D).size
	# El origen está en los pies: el rectángulo empieza medio ancho a la izquierda y
	# un alto entero más arriba.
	return Rect2(position - Vector2(size.x / 2.0, size.y), size)


## Datos para el overlay de debug (F3).
func get_debug_info() -> Dictionary:
	return {
		"velocidad": "(%.0f, %.0f)" % [velocity.x, velocity.y],
		"en el piso": "sí" if is_on_floor() else "no",
		"estado": STATE_NAMES[_motor.state],
		"mira": "derecha" if _motor.facing > 0 else "izquierda",
		"timer estado": "%.2f s" % _motor.get_state_timer(),
		"caída": "%.0f px" % _motor.get_fall_distance(),
		"coyote / buffer": "%.2f / %.2f s" % [_motor.get_coyote(), _motor.get_buffer()],
		"— disparo —": "",
		"apunta": AIM_NAMES[_aim],
		"puede disparar": "no" if _stance == ShootLogic.Stance.BUSY else "sí",
		"próximo tiro en": "%.2f s" % _shoot.get_cooldown(),
		"pose de tiro": "%.2f s" % _shoot.get_pose_time(),
		"disparos": str(_shots),
	}


func _animate(direction: float) -> void:
	# Los cuadros miran a la derecha; flip_h los espeja para mirar a la izquierda.
	_sprite.flip_h = _motor.facing < 0
	# is_on_wall() vale lo que midió el último move_and_slide(), y solo da true si el
	# cuerpo intentó moverse contra la pared. Por eso el motor sigue acelerando contra
	# ella: si lo frenáramos, en el paso siguiente no la detectaría y la animación alternaría.
	var blocked := PlayerAnimation.is_blocked(is_on_wall(), get_wall_normal().x, direction)
	var anim := (
		PlayerAnimation
		. pick(
			_motor.state,
			velocity,
			config.run_speed,
			blocked,
			_motor.get_fall_severity(),
			is_on_floor(),
		)
	)
	# Si ya está pasando esa animación, se deja seguir: reiniciarla en cada paso la
	# congelaría en el primer cuadro. Las muertes tampoco se reinician al terminar: se
	# quedan en el último cuadro, Elyon en el piso, hasta volver a la entrada.
	var keep := _sprite.is_playing() or PlayerAnimation.holds_last_frame(anim)
	if _sprite.animation == anim and keep:
		return
	var frames := _sprite.sprite_frames
	var speed := (
		PlayerAnimation
		. speed_for(
			frames.get_frame_count(anim),
			frames.get_animation_speed(anim),
			PlayerAnimation.duration_for(anim, config),
		)
	)
	# play() con velocidad: la animación dura lo que pide el .tres (el motor manda).
	_sprite.play(anim, speed)


func _direction() -> Vector2:
	return ShootLogic.direction(_aim, _motor.facing, shoot_config, _stance == ShootLogic.Stance.AIR)


# Pose de disparo de pie: cada tiro arranca la animación desde el cuadro del impacto;
# cambiar de ángulo sin tirar salta al mismo cuadro del otro ángulo, de golpe.
func _show_shot_pose(fired: bool) -> void:
	_sprite.flip_h = _motor.facing < 0
	var anim := PlayerAnimation.shot_animation(_aim)
	if fired:
		_sprite.play(anim)
		_sprite.set_frame_and_progress(0, 0.0)
	elif _sprite.animation != anim:
		# Si venía de otra animación (no de disparo), entra por el último cuadro: la
		# pose sostenida.
		var from_shot := PlayerAnimation.is_shot_animation(_sprite.animation)
		var frame := _sprite.frame if from_shot else _sprite.sprite_frames.get_frame_count(anim) - 1
		var progress := _sprite.frame_progress if from_shot else 0.0
		_sprite.play(anim)
		_sprite.set_frame_and_progress(frame, progress)
