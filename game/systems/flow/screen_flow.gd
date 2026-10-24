## Flujo de pantallas del juego: en qué pantalla estamos y a cuál se puede pasar.
##
## Lógica pura: no toca escenas ni nodos. Main le manda eventos ("apretaron Jugar")
## y escucha state_changed para mostrar la pantalla que corresponde.
class_name ScreenFlow
extends RefCounted

## Se emite una vez por cada cambio real de estado (nunca con eventos ignorados).
signal state_changed(from: State, to: State)

enum State { MENU, PLAYING, PAUSED }
enum Event { PLAY, PAUSE, RESUME, TO_MENU }

# Tabla de transiciones: para cada estado, qué eventos acepta y a dónde lleva cada uno.
# Lo que no está en la tabla se ignora (p. ej. pausar desde el menú).
# PAUSE desde PAUSED vuelve a PLAYING: la misma tecla pausa y despausa.
const _TRANSITIONS := {
	State.MENU: {Event.PLAY: State.PLAYING},
	State.PLAYING: {Event.PAUSE: State.PAUSED},
	State.PAUSED:
	{
		Event.RESUME: State.PLAYING,
		Event.PAUSE: State.PLAYING,
		Event.TO_MENU: State.MENU,
	},
}

var _state: State = State.MENU


func get_state() -> State:
	return _state


## Aplica un evento. Devuelve true si cambió el estado.
func send(event: Event) -> bool:
	var allowed: Dictionary = _TRANSITIONS[_state]
	if not allowed.has(event):
		return false
	var from := _state
	_state = allowed[event]
	state_changed.emit(from, _state)
	return true
