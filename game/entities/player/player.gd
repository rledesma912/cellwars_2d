## El protagonista: Elyon, el soldado (48 px, imágenes provisorias).
##
## Nodo fino: lee las teclas, le pide a PlayerMotor la velocidad nueva y se mueve.
## Las reglas (cuánto corre, cómo cae, cuándo puede saltar) están en PlayerMotor, y
## qué animación mostrar está en PlayerAnimation. Acá solo se aplica.
##
## Su origen (posición) está en los pies, al centro: así ponerlo "parado" en un punto
## del piso es darle esa posición, sin sumar la mitad de su alto.
class_name Player
extends CharacterBody2D

## Nombres del estado del motor para el overlay de debug.
const STATE_NAMES := {
	PlayerMotor.State.IDLE: "quieto",
	PlayerMotor.State.RUN: "correr",
	PlayerMotor.State.BRAKE: "frenar",
	PlayerMotor.State.TURN: "girar",
	PlayerMotor.State.JUMP_PREP: "preparar salto",
	PlayerMotor.State.AIR: "en el aire",
	PlayerMotor.State.LAND: "recuperarse",
}

## Parámetros del movimiento. La escena usa game/data/player_movement.tres.
@export var config: PlayerMovementConfig

var _motor: PlayerMotor

@onready var _shape: CollisionShape2D = %Shape
# AnimatedSprite2D pasa los cuadros de una animación de SpriteFrames, como un flipbook.
# Sus cuadros miden 64 × 64 con los pies abajo al centro; el offset los pone en el origen.
@onready var _sprite: AnimatedSprite2D = %Sprite


func _ready() -> void:
	_motor = PlayerMotor.new(config)


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
	_animate()


## Lo pone quieto en un punto (por ejemplo, el inicio de la sala).
func reset_to(feet_position: Vector2) -> void:
	position = feet_position
	velocity = Vector2.ZERO
	_motor.reset()
	_animate()


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
		"coyote / buffer": "%.2f / %.2f s" % [_motor.get_coyote(), _motor.get_buffer()],
	}


func _animate() -> void:
	# Los cuadros miran a la derecha; flip_h los espeja para mirar a la izquierda.
	_sprite.flip_h = _motor.facing < 0
	var anim := PlayerAnimation.pick(_motor.state, velocity, config.run_speed)
	# Si ya está pasando esa animación, se deja seguir: reiniciarla en cada paso la
	# congelaría en el primer cuadro.
	if _sprite.animation == anim and _sprite.is_playing():
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
