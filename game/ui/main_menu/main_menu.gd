## Menú principal: título y botones "Jugar" / "Opciones" / "Salir".
##
## No decide nada: solo avisa qué botón se apretó. Main escucha estas señales
## y le pasa el evento al flujo de pantallas (ScreenFlow).
class_name MainMenu
extends Control

signal play_requested
signal options_requested
signal quit_requested

# El "%" busca el nodo por nombre único dentro de esta escena (Unique Name en el
# editor), así el script no depende de la ruta exacta dentro de los contenedores.
@onready var _play_button: Button = %PlayButton
@onready var _options_button: Button = %OptionsButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	_play_button.pressed.connect(play_requested.emit)
	_options_button.pressed.connect(options_requested.emit)
	_quit_button.pressed.connect(quit_requested.emit)
	# El foco marca qué botón responde al teclado o gamepad (flechas para moverse,
	# Enter / A para apretar). Sin foco inicial, el menú solo se podría usar con mouse.
	_play_button.grab_focus()


## Al volver desde Opciones, Main lo llama para que el foco quede en "Opciones"
## (donde estaba el jugador) en vez de saltar a "Jugar".
func focus_options() -> void:
	_options_button.grab_focus()
