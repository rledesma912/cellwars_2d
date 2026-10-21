# Test trivial de Fase 0: solo verifica que gdUnit4 corre en headless.
# Se puede borrar cuando exista el primer test real de game/systems/.
extends GdUnitTestSuite


func test_gdunit_runs() -> void:
	assert_int(1 + 1).is_equal(2)
