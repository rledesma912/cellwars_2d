# Tests de ScreenFlow (F001-AC01 a AC07, F002-AC09, F011-AC03 y AC04).
extends GdUnitTestSuite

# Transiciones válidas según la spec; todo lo demás debe ignorarse (AC06).
const VALID := {
	[ScreenFlow.State.MENU, ScreenFlow.Event.PLAY]: ScreenFlow.State.PLAYING,
	[ScreenFlow.State.PLAYING, ScreenFlow.Event.PAUSE]: ScreenFlow.State.PAUSED,
	[ScreenFlow.State.PAUSED, ScreenFlow.Event.RESUME]: ScreenFlow.State.PLAYING,
	[ScreenFlow.State.PAUSED, ScreenFlow.Event.PAUSE]: ScreenFlow.State.PLAYING,
	[ScreenFlow.State.PAUSED, ScreenFlow.Event.TO_MENU]: ScreenFlow.State.MENU,
	[ScreenFlow.State.MENU, ScreenFlow.Event.OPEN_OPTIONS]: ScreenFlow.State.OPTIONS,
	[ScreenFlow.State.OPTIONS, ScreenFlow.Event.BACK]: ScreenFlow.State.MENU,
	[ScreenFlow.State.PLAYING, ScreenFlow.Event.LEVEL_COMPLETED]: ScreenFlow.State.LEVEL_COMPLETE,
	[ScreenFlow.State.LEVEL_COMPLETE, ScreenFlow.Event.TO_MENU]: ScreenFlow.State.MENU,
}


# Lleva un flujo nuevo hasta el estado pedido usando solo transiciones válidas.
func _flow_in(state: ScreenFlow.State) -> ScreenFlow:
	var flow := ScreenFlow.new()
	if (
		state
		in [ScreenFlow.State.PLAYING, ScreenFlow.State.PAUSED, ScreenFlow.State.LEVEL_COMPLETE]
	):
		flow.send(ScreenFlow.Event.PLAY)
	if state == ScreenFlow.State.LEVEL_COMPLETE:
		flow.send(ScreenFlow.Event.LEVEL_COMPLETED)
	if state == ScreenFlow.State.PAUSED:
		flow.send(ScreenFlow.Event.PAUSE)
	if state == ScreenFlow.State.OPTIONS:
		flow.send(ScreenFlow.Event.OPEN_OPTIONS)
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


func test_f002_ac09_options_from_menu_and_back() -> void:
	var flow := _flow_in(ScreenFlow.State.MENU)
	assert_bool(flow.send(ScreenFlow.Event.OPEN_OPTIONS)).is_true()
	assert_int(flow.get_state()).is_equal(ScreenFlow.State.OPTIONS)
	for ignored: ScreenFlow.Event in [ScreenFlow.Event.PLAY, ScreenFlow.Event.PAUSE]:
		assert_bool(flow.send(ignored)).is_false()
		assert_int(flow.get_state()).is_equal(ScreenFlow.State.OPTIONS)
	assert_bool(flow.send(ScreenFlow.Event.BACK)).is_true()
	assert_int(flow.get_state()).is_equal(ScreenFlow.State.MENU)


func test_f011_ac03_level_complete_flow() -> void:
	var flow := _flow_in(ScreenFlow.State.PLAYING)
	assert_bool(flow.send(ScreenFlow.Event.LEVEL_COMPLETED)).is_true()
	assert_int(flow.get_state()).is_equal(ScreenFlow.State.LEVEL_COMPLETE)
	assert_bool(flow.send(ScreenFlow.Event.TO_MENU)).is_true()
	assert_int(flow.get_state()).is_equal(ScreenFlow.State.MENU)


func test_f011_ac04_level_complete_ignores_other_events() -> void:
	var flow := _flow_in(ScreenFlow.State.LEVEL_COMPLETE)
	for event: ScreenFlow.Event in [
		ScreenFlow.Event.PAUSE,
		ScreenFlow.Event.RESUME,
		ScreenFlow.Event.PLAY,
		ScreenFlow.Event.OPEN_OPTIONS,
		ScreenFlow.Event.BACK,
		ScreenFlow.Event.LEVEL_COMPLETED,
	]:
		assert_bool(flow.send(event)).is_false()
		assert_int(flow.get_state()).is_equal(ScreenFlow.State.LEVEL_COMPLETE)


func test_f011_ac04_level_completed_only_while_playing() -> void:
	for state: ScreenFlow.State in [
		ScreenFlow.State.MENU, ScreenFlow.State.PAUSED, ScreenFlow.State.OPTIONS
	]:
		var flow := _flow_in(state)
		assert_bool(flow.send(ScreenFlow.Event.LEVEL_COMPLETED)).is_false()
		assert_int(flow.get_state()).is_equal(state)
