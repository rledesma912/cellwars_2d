## Pantalla de opciones: pantalla completa, volumen e idioma.
##
## Igual que los otros menús, no decide nada: muestra los valores que le pasa Main
## (show_settings) y avisa cada cambio con una señal. Main actualiza la
## configuración, la aplica y la guarda.
class_name OptionsMenu
extends Control

signal fullscreen_toggled(enabled: bool)
signal volume_changed(percent: int)
signal language_selected(code: String)
signal back_requested

# Código de idioma y cómo se muestra. Los nombres de idioma no se traducen:
# cada uno aparece en su propio idioma, que es la práctica habitual.
const LANGUAGE_NAMES := {"es": "Español", "en": "English"}

@onready var _fullscreen_check: CheckButton = %FullscreenCheck
@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _volume_value: Label = %VolumeValue
@onready var _language_select: OptionButton = %LanguageSelect
@onready var _back_button: Button = %BackButton
@onready var _test_beep: AudioStreamPlayer = %TestBeep


func _ready() -> void:
	for code: String in PlayerSettings.LANGUAGES:
		_language_select.add_item(LANGUAGE_NAMES[code])
	_fullscreen_check.toggled.connect(fullscreen_toggled.emit)
	_volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	_language_select.item_selected.connect(_on_language_select_item_selected)
	_back_button.pressed.connect(back_requested.emit)
	_update_volume_value()
	_fullscreen_check.grab_focus()


## Muestra la configuración actual sin emitir avisos: los *_no_signal cambian el
## control sin disparar su señal, así abrir la pantalla no "cambia" nada.
func show_settings(settings: PlayerSettings) -> void:
	_fullscreen_check.set_pressed_no_signal(settings.is_fullscreen())
	_volume_slider.set_value_no_signal(settings.get_volume())
	_update_volume_value()
	# select() tampoco emite item_selected.
	_language_select.select(PlayerSettings.LANGUAGES.find(settings.get_language()))


# Esc o el botón B (acción ui_cancel) equivalen a "Volver".
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func _on_volume_slider_value_changed(value: float) -> void:
	_update_volume_value()
	# Primero se avisa (Main aplica el volumen nuevo) y después suena el bip,
	# así se escucha ya con el volumen elegido.
	volume_changed.emit(int(value))
	_test_beep.play()


func _on_language_select_item_selected(index: int) -> void:
	language_selected.emit(PlayerSettings.LANGUAGES[index])


func _update_volume_value() -> void:
	_volume_value.text = "%d %%" % int(_volume_slider.value)
