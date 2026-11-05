## Cartel de nivel completado: se muestra al llegar al refugio, encima de la partida
## congelada, con un solo botón para volver al menú.
##
## Igual que los otros menús, no decide nada: avisa qué botón se apretó y Main decide.
## Main lo muestra con open() y lo oculta con close().
class_name LevelCompleteMenu
extends CanvasLayer

signal menu_requested

@onready var _to_menu_button: Button = %ToMenuButton


func _ready() -> void:
	# Aparece con el juego en pausa: tiene que seguir respondiendo aunque todo esté congelado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_to_menu_button.pressed.connect(menu_requested.emit)


func open() -> void:
	show()
	# Con el foco en el botón responden el teclado y el gamepad, no solo el mouse.
	_to_menu_button.grab_focus()


func close() -> void:
	# Al ocultarse, Godot le saca el foco al botón: no queda "apretable" a ciegas.
	hide()
