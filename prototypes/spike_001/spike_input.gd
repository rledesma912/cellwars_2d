## Spike 001: lo que pidió el jugador en un paso de física.
class_name Spike001Input
extends RefCounted

var direction: float
var jump_pressed: bool
var jump_held: bool


func _init(p_direction: float, p_jump_pressed: bool, p_jump_held: bool) -> void:
	direction = p_direction
	jump_pressed = p_jump_pressed
	jump_held = p_jump_held
