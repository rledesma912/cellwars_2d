## Marco del juego: queda siempre cargado mientras el juego está abierto y cambia
## lo que se ve adentro (menú principal o partida).
##
## No decide el flujo: traduce lo que pasa (botones, tecla de pausa) a eventos
## para ScreenFlow, y cuando ScreenFlow avisa un cambio de estado, lo aplica en pantalla.
extends Node

# preload carga las escenas una sola vez al iniciar; después instantiate() crea
# una copia nueva cada vez que hace falta (por eso la partida empieza de cero).
const MAIN_MENU_SCENE := preload("res://game/ui/main_menu/main_menu.tscn")
const WORLD_SCENE := preload("res://game/world/world.tscn")

var _flow := ScreenFlow.new()
var _current_screen: Node

@onready var _screen: Node = %Screen
@onready var _pause_menu: PauseMenu = %PauseMenu


func _ready() -> void:
	# El marco tiene que seguir funcionando en pausa: es quien escucha Esc para salir de ella.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_flow.state_changed.connect(_on_state_changed)
	# bind() fija el argumento: al apretar el botón se llama _flow.send(Event.RESUME).
	_pause_menu.resume_requested.connect(_flow.send.bind(ScreenFlow.Event.RESUME))
	_pause_menu.menu_requested.connect(_flow.send.bind(ScreenFlow.Event.TO_MENU))
	_pause_menu.close()
	_show_main_menu()


# _unhandled_input recibe solo lo que no usaron antes los menús (p. ej. un botón con foco).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		# Se manda siempre; ScreenFlow lo ignora si no corresponde (en el menú principal).
		_flow.send(ScreenFlow.Event.PAUSE)
		get_viewport().set_input_as_handled()


func _on_state_changed(from: ScreenFlow.State, to: ScreenFlow.State) -> void:
	match to:
		ScreenFlow.State.MENU:
			get_tree().paused = false
			_pause_menu.close()
			_show_main_menu()
		ScreenFlow.State.PLAYING:
			if from == ScreenFlow.State.MENU:
				_show_screen(WORLD_SCENE.instantiate())
			else:
				_pause_menu.close()
				get_tree().paused = false
		ScreenFlow.State.PAUSED:
			# Pausa nativa de Godot: congela todos los nodos "pausables" (la partida).
			get_tree().paused = true
			_pause_menu.open()


func _show_main_menu() -> void:
	var menu: MainMenu = MAIN_MENU_SCENE.instantiate()
	menu.play_requested.connect(_flow.send.bind(ScreenFlow.Event.PLAY))
	menu.quit_requested.connect(get_tree().quit)
	_show_screen(menu)


# Saca la pantalla actual (si hay) y pone la nueva dentro del contenedor Screen.
func _show_screen(screen: Node) -> void:
	if _current_screen:
		# queue_free la borra al final del frame, cuando Godot ya terminó de usarla.
		_current_screen.queue_free()
	_current_screen = screen
	_screen.add_child(screen)
