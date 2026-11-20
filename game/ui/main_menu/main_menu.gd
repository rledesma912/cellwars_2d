## Menú principal: título y botones "Jugar" / "Opciones" / "Salir".
##
## No decide nada: solo avisa qué botón se apretó. Main escucha estas señales
## y le pasa el evento al flujo de pantallas (ScreenFlow).
class_name MainMenu
extends Control

signal play_requested
signal options_requested
signal quit_requested
## Herramienta de desarrollo: se eligió abrir el prototipo de un spike (ruta de su escena).
signal prototype_requested(scene_path: String)

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


## Herramienta temporal de desarrollo: agrega un botón por prototipo de spike, debajo de
## "Salir". Main lo llama solo en builds de debug, así el juego publicado no los muestra.
func show_prototypes(scene_paths: Array[String]) -> void:
	for path in scene_paths:
		var button := Button.new()
		button.custom_minimum_size = _quit_button.custom_minimum_size
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		# tr() traduce la etiqueta; el %s se completa con el número del spike.
		button.text = tr("MENU_PROTOTYPE") % PrototypeCatalog.spike_number(path)
		button.pressed.connect(prototype_requested.emit.bind(path))
		# Se agrega en el mismo contenedor que los otros botones: el teclado y el
		# gamepad llegan a él con las flechas sin configurar nada más.
		_quit_button.get_parent().add_child(button)


## Al volver desde Opciones, Main lo llama para que el foco quede en "Opciones"
## (donde estaba el jugador) en vez de saltar a "Jugar".
func focus_options() -> void:
	_options_button.grab_focus()
