## Zona mortal: un rectángulo fijo que mata a Elyon cuando lo toca (F007).
##
## Nodo fino: avisa y nada más. Qué pasa al morir lo decide PlayerMotor.
##
## Area2D detecta lo que entra sin frenarlo: Elyon no choca con la zona, la atraviesa
## y muere. @tool hace correr el script también en el editor, para ver el rectángulo
## al colocarlo en una sala.
@tool
class_name MortalZone
extends Area2D

## Gris rojizo: greybox, hasta que las zonas tengan arte.
const COLOR := Color(0.45, 0.22, 0.22)

## Tamaño en píxeles, desde el origen hacia la derecha y hacia abajo. Así la posición
## de la zona es su esquina y es fácil alinearla con las baldosas de 20 px.
@export var size := Vector2(80.0, 20.0):
	set(value):
		size = value
		queue_redraw()

@onready var _shape: CollisionShape2D = %Shape


func _ready() -> void:
	# Solo en el juego: si lo hiciera en el editor, el shape nuevo quedaría guardado en
	# cada sala. Cada zona crea el suyo; compartirlo obligaría a todas a medir lo mismo.
	if Engine.is_editor_hint():
		return
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	_shape.shape = rectangle
	# Un shape se dibuja centrado en su nodo; la zona empieza en su esquina.
	_shape.position = size / 2.0
	body_entered.connect(_on_body_entered)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COLOR)


func _on_body_entered(body: Node2D) -> void:
	# Las baldosas también son cuerpos en la misma capa: la zona avisa por ellas también.
	if body is Player:
		(body as Player).die(PlayerMotor.DeathCause.HAZARD)
