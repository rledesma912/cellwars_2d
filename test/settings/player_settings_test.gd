# Tests de PlayerSettings (F002-AC01 a AC05).
extends GdUnitTestSuite


func test_f002_ac01_defaults() -> void:
	var settings := PlayerSettings.new("de_DE")
	assert_bool(settings.is_fullscreen()).is_false()
	assert_int(settings.get_volume()).is_equal(100)
	assert_str(settings.get_language()).is_equal("en")
	assert_str(PlayerSettings.new("es_AR").get_language()).is_equal("es")


func test_f002_ac02_volume_is_clamped() -> void:
	var settings := PlayerSettings.new("en")
	settings.set_volume(130)
	assert_int(settings.get_volume()).is_equal(100)
	settings.set_volume(-5)
	assert_int(settings.get_volume()).is_equal(0)
	settings.set_volume(70)
	assert_int(settings.get_volume()).is_equal(70)


func test_f002_ac03_volume_to_db() -> void:
	var settings := PlayerSettings.new("en")
	assert_float(settings.get_volume_db()).is_equal_approx(0.0, 0.001)
	assert_bool(settings.is_muted()).is_false()
	settings.set_volume(50)
	assert_float(settings.get_volume_db()).is_equal_approx(-6.0, 0.1)
	settings.set_volume(0)
	assert_bool(settings.is_muted()).is_true()


func test_f002_ac04_default_language_from_system() -> void:
	var cases := {
		"es": "es",
		"es_AR": "es",
		"es_ES": "es",
		"ES-mx": "es",
		"en": "en",
		"en_US": "en",
		"fr_FR": "en",
		"ja": "en",
		"": "en",
	}
	for locale: String in cases:
		assert_str(PlayerSettings.default_language_for(locale)).is_equal(cases[locale])


func test_f002_ac05_setting_same_value_reports_no_change() -> void:
	var settings := PlayerSettings.new("es")
	assert_bool(settings.set_fullscreen(false)).is_false()
	assert_bool(settings.set_fullscreen(true)).is_true()
	assert_bool(settings.set_volume(100)).is_false()
	assert_bool(settings.set_volume(150)).is_false()  # se limita a 100: no cambia nada
	assert_bool(settings.set_volume(40)).is_true()
	assert_bool(settings.set_language("es")).is_false()
	assert_bool(settings.set_language("fr")).is_false()  # idioma desconocido: se ignora
	assert_str(settings.get_language()).is_equal("es")
	assert_bool(settings.set_language("en")).is_true()
