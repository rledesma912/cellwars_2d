## El protagonista. Por ahora es un rectángulo gris (greybox).
##
## Nodo fino: lee las teclas, le pide a PlayerMotor la velocidad nueva y se mueve.
## Las reglas (cuánto corre, cómo cae, cuándo puede saltar) están en PlayerMotor.
##
## Su origen (posición) está en los pies, al centro: así ponerlo "parado" en un punto
## del piso es darle esa posición, sin sumar la mitad de su alto.
class_name Player
extends CharacterBody2D

## Parámetros del movimiento. La escena usa game/data/player_movement.tres.
@export var config: PlayerMovementConfig

var _motor: PlayerMotor

@onready var _shape: CollisionShape2D = %Shape


func _ready() -> void:
	_motor = PlayerMotor.new(config)


# _physics_process corre 60 veces por segundo, a ritmo fijo: es donde va el movimiento.
func _physics_process(delta: float) -> void:
	# get_axis da −1, 0 o 1 con teclas (o un valor intermedio con el stick) y ya
	# aplica la zona muerta del gamepad. Izquierda y derecha juntas se anulan en 0.
	# is_action_just_pressed es true solo en el paso en que se apretó: mantener no repite.
	var input := PlayerInput.new(
		Input.get_axis("move_left", "move_right"), Input.is_action_just_pressed("jump")
	)
	velocity = _motor.step(velocity, input, is_on_floor(), delta)
	# move_and_slide() mueve según velocity, frena contra paredes y pisos y actualiza
	# is_on_floor() para el próximo paso.
	move_and_slide()


## Lo pone quieto en un punto (por ejemplo, el inicio de la sala).
func reset_to(feet_position: Vector2) -> void:
	position = feet_position
	velocity = Vector2.ZERO


## Altura (en Y) del borde de arriba del personaje.
func get_top_y() -> float:
	return position.y - (_shape.shape as RectangleShape2D).size.y


## Datos para el overlay de debug (F3).
func get_debug_info() -> Dictionary:
	return {
		"velocidad": "(%.0f, %.0f)" % [velocity.x, velocity.y],
		"en el piso": "sí" if is_on_floor() else "no",
	}
