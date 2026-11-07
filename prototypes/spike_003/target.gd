## Blanco quieto del prototipo S003: no tiene vida ni ataca, solo marca los impactos.
##
## StaticBody2D en la capa de física 2 (los tiros la buscan; Elyon, que solo mira la
## capa 1, lo atraviesa). Su origen está abajo al centro, como el de Elyon: se apoya
## en el piso poniéndolo en el borde de las baldosas.
extends StaticBody2D

@export var size := Vector2(30, 80)

var hits := 0

var _rect: ColorRect
var _label: Label


func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -size.y / 2.0)
	add_child(col)
	_rect = ColorRect.new()
	_rect.size = size
	_rect.position = Vector2(-size.x / 2.0, -size.y)
	_rect.color = Color(0.85, 0.35, 0.3)
	add_child(_rect)
	_label = Label.new()
	_label.position = Vector2(-size.x / 2.0, -size.y - 26)
	_label.text = "0"
	add_child(_label)


## Lo llama el disparo al pegarle.
func hit() -> void:
	hits += 1
	_label.text = str(hits)
	# Tween: anima una propiedad en el tiempo. Destello blanco que vuelve al rojo.
	_rect.color = Color.WHITE
	var tween := create_tween()
	tween.tween_property(_rect, "color", Color(0.85, 0.35, 0.3), 0.15)
