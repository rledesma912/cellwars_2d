# Tests de SettingsStore (F002-AC06 a AC08).
# Cada test trabaja en una carpeta temporal de gdUnit4 que se borra al terminar.
extends GdUnitTestSuite

var _dir: String
var _path: String


func before_test() -> void:
	_dir = create_temp_dir("settings")
	_path = _dir.path_join("settings.json")


func after_test() -> void:
	clean_temp_dir()


func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_f002_ac06_save_and_load_round_trip() -> void:
	var store := SettingsStore.new(_path)
	var settings := PlayerSettings.new("en")
	settings.set_fullscreen(true)
	settings.set_volume(30)
	settings.set_language("es")
	assert_int(store.save_settings(settings)).is_equal(OK)

	var loaded := store.load_settings("en")
	assert_bool(loaded.is_fullscreen()).is_true()
	assert_int(loaded.get_volume()).is_equal(30)
	assert_str(loaded.get_language()).is_equal("es")


func test_f002_ac07_missing_or_invalid_file_uses_defaults() -> void:
	var store := SettingsStore.new(_path)

	# Sin archivo: valores de fábrica, con el idioma del sistema.
	var missing := store.load_settings("es_AR")
	assert_bool(missing.is_fullscreen()).is_false()
	assert_int(missing.get_volume()).is_equal(100)
	assert_str(missing.get_language()).is_equal("es")

	# Archivo roto (no es JSON).
	_write(_path, "esto no es json {{{")
	assert_int(store.load_settings("en").get_volume()).is_equal(100)

	# Un valor inválido vuelve al de fábrica; el resto se respeta.
	_write(_path, '{"fullscreen": true, "volume": "abc", "language": "fr"}')
	var partial := store.load_settings("en")
	assert_bool(partial.is_fullscreen()).is_true()
	assert_int(partial.get_volume()).is_equal(100)
	assert_str(partial.get_language()).is_equal("en")

	# Tipos inesperados (listas, objetos, texto en lugar de sí/no) se descartan.
	_write(_path, '{"fullscreen": "true", "volume": [50], "language": {"code": "es"}}')
	var odd := store.load_settings("en")
	assert_bool(odd.is_fullscreen()).is_false()
	assert_int(odd.get_volume()).is_equal(100)
	assert_str(odd.get_language()).is_equal("en")

	# Números fuera de rango o gigantes quedan dentro de 0–100.
	_write(_path, '{"volume": 1e30}')
	assert_int(store.load_settings("en").get_volume()).is_equal(100)
	_write(_path, '{"volume": -1e30}')
	assert_int(store.load_settings("en").get_volume()).is_equal(0)

	# El archivo entero no es un diccionario.
	_write(_path, "[1, 2, 3]")
	assert_int(store.load_settings("en").get_volume()).is_equal(100)


func test_f002_ac08_save_leaves_no_temp_and_ignores_stale_temp() -> void:
	var store := SettingsStore.new(_path)
	var settings := PlayerSettings.new("en")
	settings.set_volume(60)
	store.save_settings(settings)
	settings.set_volume(20)
	store.save_settings(settings)
	assert_bool(FileAccess.file_exists(_path)).is_true()
	assert_array(DirAccess.get_files_at(_dir)).contains_exactly(["settings.json"])

	# Un temporal de un guardado interrumpido no se lee: manda el archivo final.
	_write(_path + ".tmp", '{"volume": 90}')
	assert_int(store.load_settings("en").get_volume()).is_equal(20)
