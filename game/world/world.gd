## Partida en curso. Por ahora es provisoria: muestra un texto y un contador de
## segundos. El contador sirve para ver en el playtest que la pausa congela la
## partida y que volver a jugar la empieza de cero. En F003 pasa a cargar las salas.
class_name World
extends Node2D

var _elapsed: float = 0.0

@onready var _elapsed_label: Label = %ElapsedLabel


func _ready() -> void:
	# Cada nodo hereda el "modo de proceso" de su padre. Main corre siempre, aun en
	# pausa, para poder escuchar Esc; si World heredara eso, nunca se congelaría.
	# Por eso declara explícitamente que se detiene cuando el juego está en pausa.
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_update_label()


func _process(delta: float) -> void:
	_elapsed += delta
	_update_label()


func _update_label() -> void:
	# tr() busca la etiqueta en la tabla de traducciones (game/i18n/texts.csv) y
	# devuelve el texto en el idioma activo. Los botones y textos fijos se traducen
	# solos; este se arma por código, así que se traduce a mano.
	_elapsed_label.text = tr("WORLD_ELAPSED") % _elapsed
