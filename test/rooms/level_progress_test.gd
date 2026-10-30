# Tests de LevelProgress (F006-AC01, AC02 y AC05).
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
	# Pasar a otra sala conserva el movimiento; el vacío lo devuelve quieto a la
	# entrada de la sala actual; sin borde no hay cambio.
	var progress := LevelProgress.new(3)
	progress.index = 1
	_assert_change(progress, LevelProgress.Outcome.VOID, 1, LevelProgress.Arrival.ENTRANCE, false)
	assert_object(progress.apply(LevelProgress.Outcome.NONE)).is_null()
	assert_int(progress.index).is_equal(1)
	_assert_change(progress, LevelProgress.Outcome.NEXT, 2, LevelProgress.Arrival.ENTRANCE, true)
