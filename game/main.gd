## Marco del juego: queda siempre cargado mientras el juego está abierto y cambia
## lo que se ve adentro (menú principal, opciones o partida).
##
## No decide el flujo: traduce lo que pasa (botones, tecla de pausa) a eventos
## para ScreenFlow, y cuando ScreenFlow avisa un cambio de estado, lo aplica en pantalla.
## También es dueño de la configuración del jugador: la carga al arrancar, la aplica
## y la guarda cuando cambia. Y publica la escala del pixel art para el shader de
## suavizado (D0004), que depende del tamaño de la ventana.
extends Node

# preload carga las escenas una sola vez al iniciar; después instantiate() crea
# una copia nueva cada vez que hace falta (por eso la partida empieza de cero).
const MAIN_MENU_SCENE := preload("res://game/ui/main_menu/main_menu.tscn")
const OPTIONS_MENU_SCENE := preload("res://game/ui/options_menu/options_menu.tscn")
const WORLD_SCENE := preload("res://game/world/world.tscn")

## "user://" es la carpeta que Godot reserva para este juego en la compu del jugador.
const SETTINGS_PATH := "user://settings.json"

var _flow := ScreenFlow.new()
var _store := SettingsStore.new(SETTINGS_PATH)
var _settings: PlayerSettings
var _current_screen: Node

@onready var _screen: Node = %Screen
@onready var _pause_menu: PauseMenu = %PauseMenu


func _ready() -> void:
	# El marco tiene que seguir funcionando en pausa: es quien escucha Esc para salir de ella.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Primero la configuración, así el menú ya aparece en el idioma y modo elegidos.
	# OS.get_locale() da el idioma de la compu (p. ej. "es_AR"), para la primera vez.
	_settings = _store.load_settings(OS.get_locale())
	_apply_fullscreen()
	_apply_volume()
	_apply_language()
	# size_changed avisa cada vez que cambia el tamaño de la ventana: al pasar a
	# pantalla completa o al arrastrar un borde. La escala se recalcula ahí mismo.
	get_window().size_changed.connect(_update_pixel_scale)
	_update_pixel_scale()

	_flow.state_changed.connect(_on_state_changed)
	# bind() fija el argumento: al apretar el botón se llama _flow.send(Event.RESUME).
	_pause_menu.resume_requested.connect(_flow.send.bind(ScreenFlow.Event.RESUME))
	_pause_menu.menu_requested.connect(_flow.send.bind(ScreenFlow.Event.TO_MENU))
	_pause_menu.close()
	_show_main_menu()


# _unhandled_input recibe solo lo que no usaron antes los menús (p. ej. un botón con foco).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		# Se manda siempre; ScreenFlow lo ignora si no corresponde (menú u opciones).
		_flow.send(ScreenFlow.Event.PAUSE)
		get_viewport().set_input_as_handled()


func _on_state_changed(from: ScreenFlow.State, to: ScreenFlow.State) -> void:
	match to:
		ScreenFlow.State.MENU:
			get_tree().paused = false
			_pause_menu.close()
			_show_main_menu(from == ScreenFlow.State.OPTIONS)
		ScreenFlow.State.OPTIONS:
			_show_options()
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


## focus_options: true al volver desde Opciones, para que el foco quede ahí.
func _show_main_menu(focus_options: bool = false) -> void:
	var menu: MainMenu = MAIN_MENU_SCENE.instantiate()
	menu.play_requested.connect(_flow.send.bind(ScreenFlow.Event.PLAY))
	menu.options_requested.connect(_flow.send.bind(ScreenFlow.Event.OPEN_OPTIONS))
	menu.quit_requested.connect(get_tree().quit)
	_show_screen(menu)
	if focus_options:
		menu.focus_options()


func _show_options() -> void:
	var options: OptionsMenu = OPTIONS_MENU_SCENE.instantiate()
	options.fullscreen_toggled.connect(_on_fullscreen_toggled)
	options.volume_changed.connect(_on_volume_changed)
	options.language_selected.connect(_on_language_selected)
	options.back_requested.connect(_flow.send.bind(ScreenFlow.Event.BACK))
	_show_screen(options)
	# Después de agregarla: recién dentro del árbol tiene sus nodos listos.
	options.show_settings(_settings)


# Saca la pantalla actual (si hay) y pone la nueva dentro del contenedor Screen.
func _show_screen(screen: Node) -> void:
	if _current_screen:
		# queue_free la borra al final del frame, cuando Godot ya terminó de usarla.
		_current_screen.queue_free()
	_current_screen = screen
	_screen.add_child(screen)


# Cada cambio: PlayerSettings dice si cambió algo; solo entonces se aplica y se guarda.


func _on_fullscreen_toggled(enabled: bool) -> void:
	if _settings.set_fullscreen(enabled):
		_apply_fullscreen()
		_save_settings()


func _on_volume_changed(percent: int) -> void:
	if _settings.set_volume(percent):
		_apply_volume()
		_save_settings()


func _on_language_selected(code: String) -> void:
	if _settings.set_language(code):
		_apply_language()
		_save_settings()


func _apply_fullscreen() -> void:
	# FULLSCREEN es pantalla completa "sin bordes": cambia rápido y sin parpadeos.
	var mode := (
		DisplayServer.WINDOW_MODE_FULLSCREEN
		if _settings.is_fullscreen()
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
	DisplayServer.window_set_mode(mode)


func _update_pixel_scale() -> void:
	var window := get_window()
	# content_scale_size es la resolución interna (1280×720 en project.godot).
	var scale := PixelScale.for_window(window.size, window.content_scale_size)
	# Cambia el uniform global "pixel_scale": lo leen a la vez todos los shaders que
	# lo declaran, sin tener que buscar cada material.
	RenderingServer.global_shader_parameter_set("pixel_scale", scale)


func _apply_volume() -> void:
	# "Master" es el canal de audio general de Godot: todo el sonido pasa por ahí.
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus, _settings.is_muted())
	if not _settings.is_muted():
		AudioServer.set_bus_volume_db(bus, _settings.get_volume_db())


func _apply_language() -> void:
	# Cambiar el idioma actualiza al instante todos los textos que usan etiquetas.
	TranslationServer.set_locale(_settings.get_language())


func _save_settings() -> void:
	var error := _store.save_settings(_settings)
	if error != OK:
		# No se corta el juego: la opción ya está aplicada, solo no se pudo recordar.
		push_warning("No se pudo guardar la configuración (error %d)" % error)
