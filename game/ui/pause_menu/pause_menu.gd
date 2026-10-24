## Menú de pausa: cartel semitransparente encima de la partida con "Continuar"
## y "Volver al menú".
##
## Igual que el menú principal, no decide nada: avisa qué botón se apretó y Main
## decide. Main lo muestra con open() y lo oculta con close().
class_name PauseMenu
extends CanvasLayer

signal resume_requested
signal menu_requested

@onready var _resume_button: Button = %ResumeButton
@onready var _to_menu_button: Button = %ToMenuButton


func _ready() -> void:
	# Este menú aparece justamente cuando el juego está en pausa, así que tiene que
	# seguir respondiendo a teclas y clics aunque todo lo demás esté congelado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume_button.pressed.connect(resume_requested.emit)
	_to_menu_button.pressed.connect(menu_requested.emit)
	# Main lo instancia oculto; si se abre la escena sola (F6) arranca visible.
	if visible:
		_resume_button.grab_focus()


func open() -> void:
	show()
	_resume_button.grab_focus()


func close() -> void:
	# Al ocultarse, Godot le saca el foco a sus botones: no quedan "apretables" a ciegas.
	hide()
