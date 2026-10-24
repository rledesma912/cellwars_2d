## Configuración que elige el jugador: pantalla completa, volumen e idioma.
##
## Lógica pura: guarda los valores y sus reglas (límites, idioma por defecto,
## conversión del volumen). No aplica nada a Godot ni toca archivos: eso lo hacen
## Main (aplicar) y SettingsStore (guardar).
class_name PlayerSettings
extends RefCounted

## Idiomas con traducción en game/i18n/texts.csv.
const LANGUAGES: Array[String] = ["es", "en"]
## Idioma cuando el de la compu no está traducido: el más universal para itch.io.
const FALLBACK_LANGUAGE := "en"
const MAX_VOLUME := 100

var _fullscreen: bool = false
var _volume: int = MAX_VOLUME
var _language: String


## system_locale es el idioma de la compu, como lo da OS.get_locale() (p. ej. "es_AR").
func _init(system_locale: String) -> void:
	_language = default_language_for(system_locale)


func is_fullscreen() -> bool:
	return _fullscreen


## Volumen en porcentaje, de 0 a 100.
func get_volume() -> int:
	return _volume


## Código del idioma: "es" o "en".
func get_language() -> String:
	return _language


# Los set_* devuelven true solo si el valor cambió: así Main sabe si hay que guardar.


func set_fullscreen(enabled: bool) -> bool:
	if enabled == _fullscreen:
		return false
	_fullscreen = enabled
	return true


func set_volume(percent: int) -> bool:
	var clamped := clampi(percent, 0, MAX_VOLUME)
	if clamped == _volume:
		return false
	_volume = clamped
	return true


## Un idioma sin traducción se ignora (devuelve false y no cambia nada).
func set_language(code: String) -> bool:
	if code == _language or not LANGUAGES.has(code):
		return false
	_language = code
	return true


## Godot maneja el volumen en decibeles: 0 dB es el volumen original y cada
## −6 dB es aproximadamente la mitad. linear_to_db hace la conversión.
## En 0 % no sirve (da menos infinito): para eso está is_muted().
func get_volume_db() -> float:
	return linear_to_db(_volume / float(MAX_VOLUME))


func is_muted() -> bool:
	return _volume == 0


## "es_AR", "ES-mx" o "es" → "es". Un idioma sin traducción → FALLBACK_LANGUAGE.
static func default_language_for(system_locale: String) -> String:
	var code := system_locale.replace("-", "_").get_slice("_", 0).to_lower()
	return code if LANGUAGES.has(code) else FALLBACK_LANGUAGE
