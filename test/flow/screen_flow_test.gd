# Tests de ScreenFlow (F001-AC01 a AC07).
extends GdUnitTestSuite

# Transiciones válidas según la spec; todo lo demás debe ignorarse (AC06).
const VALID := {
	[ScreenFlow.State.MENU, ScreenFlow.Event.PLAY]: ScreenFlow.State.PLAYING,
	[ScreenFlow.State.PLAYING, ScreenFlow.Event.PAUSE]: ScreenFlow.State.PAUSED,
	[ScreenFlow.State.PAUSED, ScreenFlow.Event.RESUME]: ScreenFlow.State.PLAYING,
	[ScreenFlow.State.PAUSED, ScreenFlow.Event.PAUSE]: ScreenFlow.State.PLAYING,
	[ScreenFlow.State.PAUSED, ScreenFlow.Event.TO_MENU]: ScreenFlow.State.MENU,
}


# Lleva un flujo nuevo hasta el estado pedido usando solo transiciones válidas.
func _flow_in(state: ScreenFlow.State) -> ScreenFlow:
	var flow := ScreenFlow.new()
	if state == ScreenFlow.State.PLAYING or state == ScreenFlow.State.PAUSED:
		flow.send(ScreenFlow.Event.PLAY)
	if state == ScreenFlow.State.PAUSED:
		flow.send(ScreenFlow.Event.PAUSE)
	return flow


func test_f001_ac01_starts_in_menu() -> void:
	assert_int(ScreenFlow.new().get_state()).is_equal(ScreenFlow.State.MENU)


func test_f001_ac02_play_from_menu_goes_to_playing() -> void:
	var flow := _flow_in(ScreenFlow.State.MENU)
	assert_bool(flow.send(ScreenFlow.Event.PLAY)).is_true()
	assert_int(flow.get_state()).is_equal(ScreenFlow.State.PLAYING)


func test_f001_ac03_pause_from_playing_goes_to_paused() -> void:
	var flow := _flow_in(ScreenFlow.State.PLAYING)
	assert_bool(flow.send(ScreenFlow.Event.PAUSE)).is_true()
	assert_int(flow.get_state()).is_equal(ScreenFlow.State.PAUSED)


func test_f001_ac04_resume_or_pause_from_paused_goes_to_playing() -> void:
	for event: ScreenFlow.Event in [ScreenFlow.Event.RESUME, ScreenFlow.Event.PAUSE]:
		var flow := _flow_in(ScreenFlow.State.PAUSED)
		assert_bool(flow.send(event)).is_true()
		assert_int(flow.get_state()).is_equal(ScreenFlow.State.PLAYING)


func test_f001_ac05_to_menu_from_paused_goes_to_menu() -> void:
	var flow := _flow_in(ScreenFlow.State.PAUSED)
	assert_bool(flow.send(ScreenFlow.Event.TO_MENU)).is_true()
	assert_int(flow.get_state()).is_equal(ScreenFlow.State.MENU)


func test_f001_ac06_invalid_event_keeps_state() -> void:
	for state: ScreenFlow.State in ScreenFlow.State.values():
		for event: ScreenFlow.Event in ScreenFlow.Event.values():
			if VALID.has([state, event]):
				continue
			var flow := _flow_in(state)
			assert_bool(flow.send(event)).is_false()
			assert_int(flow.get_state()).is_equal(state)


func test_f001_ac07_notifies_once_per_change_and_never_on_ignored() -> void:
	var flow := ScreenFlow.new()
	var emitted: Array = []
	flow.state_changed.connect(
		func(from: ScreenFlow.State, to: ScreenFlow.State) -> void: emitted.append([from, to])
	)

	flow.send(ScreenFlow.Event.PAUSE)  # ignorado: en el menú no hay pausa
	flow.send(ScreenFlow.Event.PLAY)
	flow.send(ScreenFlow.Event.TO_MENU)  # ignorado: al menú se vuelve solo desde la pausa
	flow.send(ScreenFlow.Event.PAUSE)
	flow.send(ScreenFlow.Event.TO_MENU)

	(
		assert_array(emitted)
		. is_equal(
			[
				[ScreenFlow.State.MENU, ScreenFlow.State.PLAYING],
				[ScreenFlow.State.PLAYING, ScreenFlow.State.PAUSED],
				[ScreenFlow.State.PAUSED, ScreenFlow.State.MENU],
			]
		)
	)
