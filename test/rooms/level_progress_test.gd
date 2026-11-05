# Tests de LevelProgress (F006-AC01, AC02 y AC05; F007-AC06).
extends GdUnitTestSuite


# Comprueba un cambio y que la sala actual quedó en el destino.
func _assert_change(
	progress: LevelProgress,
	outcome: LevelProgress.Outcome,
	room: int,
	arrival: LevelProgress.Arrival,
	keep: bool
) -> void:
	var change := progress.apply(outcome)
	assert_object(change).is_not_null()
	if change == null:
		return
	assert_int(change.room_index).is_equal(room)
	assert_int(change.arrival).is_equal(arrival)
	assert_bool(change.keep_motion).is_equal(keep)
	assert_int(progress.index).is_equal(room)


func test_f006_ac01_advance_and_go_back() -> void:
	var progress := LevelProgress.new(3)
	assert_int(progress.index).is_equal(0)
	# Salida: a la siguiente, por su entrada.
	_assert_change(progress, LevelProgress.Outcome.NEXT, 1, LevelProgress.Arrival.ENTRANCE, true)
	_assert_change(progress, LevelProgress.Outcome.NEXT, 2, LevelProgress.Arrival.ENTRANCE, true)
	# Entrada: a la anterior, por su salida.
	_assert_change(progress, LevelProgress.Outcome.PREVIOUS, 1, LevelProgress.Arrival.EXIT, true)
	_assert_change(progress, LevelProgress.Outcome.PREVIOUS, 0, LevelProgress.Arrival.EXIT, true)


func test_f006_ac02_list_edges() -> void:
	# Entrada de la sala 1: no cambia de sala, vuelve quieto a su entrada.
	var progress := LevelProgress.new(3)
	_assert_change(
		progress, LevelProgress.Outcome.PREVIOUS, 0, LevelProgress.Arrival.ENTRANCE, false
	)
	# Salida de la última: a la entrada de la sala 1, quieto (provisorio).
	progress.index = 2
	_assert_change(progress, LevelProgress.Outcome.NEXT, 0, LevelProgress.Arrival.ENTRANCE, false)
	# Nivel de una sola sala: los dos bordes se comportan igual.
	var single := LevelProgress.new(1)
	_assert_change(single, LevelProgress.Outcome.NEXT, 0, LevelProgress.Arrival.ENTRANCE, false)
	_assert_change(single, LevelProgress.Outcome.PREVIOUS, 0, LevelProgress.Arrival.ENTRANCE, false)


func test_f006_ac05_change_keeps_motion() -> void:
	# Pasar a otra sala conserva el movimiento; sin borde no hay cambio. El vacío
	# tampoco cambia de sala por sí solo: mata, y al terminar la muerte se vuelve con
	# checkpoint() (F007).
	var progress := LevelProgress.new(3)
	progress.index = 1
	assert_object(progress.apply(LevelProgress.Outcome.VOID)).is_null()
	assert_int(progress.index).is_equal(1)
	assert_object(progress.apply(LevelProgress.Outcome.NONE)).is_null()
	assert_int(progress.index).is_equal(1)
	_assert_change(progress, LevelProgress.Outcome.NEXT, 2, LevelProgress.Arrival.ENTRANCE, true)


# Comprueba que el checkpoint es la entrada de esa sala, sin movimiento.
func _assert_checkpoint(progress: LevelProgress, room: int) -> void:
	var change := progress.checkpoint()
	assert_int(change.room_index).is_equal(room)
	assert_int(change.arrival).is_equal(LevelProgress.Arrival.ENTRANCE)
	assert_bool(change.keep_motion).is_false()
	assert_int(progress.index).is_equal(room)


func test_f007_ac06_checkpoint_is_current_room_entrance() -> void:
	var progress := LevelProgress.new(3)
	_assert_checkpoint(progress, 0)
	progress.apply(LevelProgress.Outcome.NEXT)
	_assert_checkpoint(progress, 1)


func test_f007_ac06_checkpoint_after_coming_back() -> void:
	# Volvió desde la siguiente: llegó por la salida, pero reaparece en la entrada.
	var progress := LevelProgress.new(3)
	progress.apply(LevelProgress.Outcome.NEXT)
	progress.apply(LevelProgress.Outcome.NEXT)
	progress.apply(LevelProgress.Outcome.PREVIOUS)
	_assert_checkpoint(progress, 1)


func test_f010_ac19_fall_holds_checkpoint_until_landing() -> void:
	var progress := LevelProgress.new(3)
	progress.apply(LevelProgress.Outcome.NEXT)
	# Cruza cayendo: cambia de sala, pero el checkpoint sigue en la que empezó.
	progress.apply(LevelProgress.Outcome.NEXT, true)
	assert_int(progress.index).is_equal(2)
	_assert_checkpoint(progress, 1)


func test_f010_ac19_landing_confirms_checkpoint() -> void:
	var progress := LevelProgress.new(3)
	progress.apply(LevelProgress.Outcome.NEXT, true)
	progress.confirm_checkpoint()
	_assert_checkpoint(progress, 1)


func test_f010_ac19_chained_falls_return_to_first_room() -> void:
	var progress := LevelProgress.new(3)
	progress.apply(LevelProgress.Outcome.NEXT, true)
	progress.apply(LevelProgress.Outcome.NEXT, true)
	_assert_checkpoint(progress, 0)


func test_f010_ac19_crossing_without_falling_moves_checkpoint() -> void:
	# Sigue F007-AC06: cruzar sin caer ya cuenta, sin esperar a aterrizar.
	var progress := LevelProgress.new(3)
	progress.apply(LevelProgress.Outcome.NEXT)
	_assert_checkpoint(progress, 1)
