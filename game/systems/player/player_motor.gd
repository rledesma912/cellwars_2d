## Reglas del movimiento del personaje: caminar, caer y saltar.
##
## Lógica pura: recibe la velocidad actual, lo que pidió el jugador y si está en el
## piso, y devuelve la velocidad nueva. No mueve nada: eso lo hace el nodo Player con
## move_and_slide(). Por eso se puede testear sin escenas.
class_name PlayerMotor
extends RefCounted

var _config: PlayerMovementConfig


func _init(config: PlayerMovementConfig) -> void:
	_config = config


## En Godot el eje Y crece hacia abajo: velocidad Y negativa es subir.
func step(velocity: Vector2, input: PlayerInput, on_floor: bool, delta: float) -> Vector2:
	var result := velocity
	# Sin aceleración ni frenado por ahora: arranca y para en seco (el "peso" es para más adelante).
	result.x = input.direction * _config.run_speed

	if on_floor:
		result.y = 0.0
		if input.jump_just_pressed:
			# Godot mueve en pasos (60 por segundo) usando la velocidad de cada paso, y así
			# el salto subiría unos píxeles de más. Restar la gravedad de medio paso al
			# despegar compensa ese error: la altura real queda igual a jump_height.
			result.y = -_config.get_jump_velocity() + _config.get_gravity() * delta * 0.5
	else:
		result.y = minf(result.y + _config.get_gravity() * delta, _config.max_fall_speed)
	return result
