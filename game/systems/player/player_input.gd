## Lo que el jugador pide en un paso de física, ya leído del teclado o gamepad.
##
## Lógica pura: no lee Input. El nodo Player lo arma con lo que apretó el jugador y
## se lo pasa a PlayerMotor; los tests lo arman a mano para simular teclas.
class_name PlayerInput
extends RefCounted

## −1 izquierda, 1 derecha, 0 nada. Con stick puede valer algo intermedio.
var direction: float
## true solo en el paso en que se apretó el salto (mantenerlo apretado no cuenta).
var jump_just_pressed: bool


func _init(p_direction: float, p_jump_just_pressed: bool) -> void:
	direction = p_direction
	jump_just_pressed = p_jump_just_pressed
