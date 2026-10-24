## Lee y guarda la configuración del jugador en un archivo JSON.
##
## Seguro por diseño:
## - JSON solo puede contener datos simples; al leer se acepta únicamente el tipo
##   esperado de cada valor y todo lo demás se descarta (queda el valor de fábrica).
## - Se guarda en dos pasos: primero un archivo temporal y después se renombra.
##   Renombrar es instantáneo, así que nunca queda un archivo a medio escribir.
##
## No usa escenas ni nodos; recibe la ruta por parámetro para poder probarlo
## con archivos temporales.
class_name SettingsStore
extends RefCounted

## Versión del formato del archivo, por si en el futuro cambia y hay que migrar.
const FORMAT_VERSION := 1

var _path: String
var _temp_path: String


## path: dónde vive el archivo, p. ej. "user://settings.json".
## "user://" es la carpeta que Godot reserva para cada juego en la compu del jugador.
func _init(path: String) -> void:
	_path = path
	_temp_path = path + ".tmp"


## Siempre devuelve una configuración válida: si el archivo falta o está roto,
## los valores que no se pueden leer quedan en su valor de fábrica.
func load_settings(system_locale: String) -> PlayerSettings:
	var settings := PlayerSettings.new(system_locale)
	if not FileAccess.file_exists(_path):
		return settings

	# JSON.new().parse() (en vez de JSON.parse_string) no escribe errores en la
	# consola cuando el archivo está roto: para nosotros es un caso esperado.
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(_path)) != OK:
		return settings
	var data: Variant = json.data
	if not data is Dictionary:
		return settings

	var fullscreen: Variant = data.get("fullscreen")
	if fullscreen is bool:
		settings.set_fullscreen(fullscreen)
	# En JSON todos los números se leen como float. Se limita antes de pasarlo a
	# entero para que un número gigante (p. ej. 1e30) no se desborde.
	var volume: Variant = data.get("volume")
	if volume is float or volume is int:
		settings.set_volume(roundi(clampf(volume, 0.0, PlayerSettings.MAX_VOLUME)))
	var language: Variant = data.get("language")
	if language is String:
		settings.set_language(language)
	return settings


## Devuelve OK o el error de Godot si no se pudo escribir.
func save_settings(settings: PlayerSettings) -> Error:
	var data := {
		"version": FORMAT_VERSION,
		"fullscreen": settings.is_fullscreen(),
		"volume": settings.get_volume(),
		"language": settings.get_language(),
	}
	DirAccess.make_dir_recursive_absolute(_path.get_base_dir())

	# Paso 1: escribir el temporal completo y cerrarlo.
	var file := FileAccess.open(_temp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	# Paso 2: reemplazar el archivo anterior por el temporal.
	var error := DirAccess.rename_absolute(_temp_path, _path)
	if error != OK and FileAccess.file_exists(_path):
		# Algunos sistemas no dejan renombrar encima de un archivo existente:
		# se borra el viejo y se reintenta.
		DirAccess.remove_absolute(_path)
		error = DirAccess.rename_absolute(_temp_path, _path)
	return error
