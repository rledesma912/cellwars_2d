## Sala de prueba del spike S003: disparo de pie.
##
## Arma el piso y las plataformas por código (para no editar a mano los datos de
## TileMapLayer), registra el botón de disparo y resuelve cada tiro como rayo o
## proyectil según el .tres.
##
## Teclas del prototipo: J / X / botón X del gamepad disparar, W/S (o ↑/↓) apuntar,
## 1 cambia el modo, 2 rayo/proyectil, 3 la regla al correr, 4 el ángulo de abajo (20/15),
## 5 la altura de la boca al tirar abajo (23/33/43/53 px),
## R vuelve al inicio, F3 datos.
extends Node2D

const PROJECTILE := preload("res://prototypes/spike_003/projectile.gd")
## Capas de física (máscara de bits): 1 = paredes y piso, 2 = blancos.
const SHOT_MASK := 1 | 2
const START := Vector2(150, 600)
## Bloques de baldosas: Rect2i en celdas (x, y, ancho, alto). Sala de 64 × 36.
const BLOCKS: Array[Rect2i] = [
	Rect2i(0, 0, 64, 1),  # techo
	Rect2i(0, 0, 1, 36),  # pared izquierda
	Rect2i(63, 0, 1, 36),  # pared derecha
	Rect2i(0, 34, 64, 2),  # piso
	Rect2i(1, 30, 14, 4),  # balcón de arranque (para tirar 45° abajo)
	Rect2i(42, 25, 8, 1),  # repisa alta (para tirar 45° arriba)
]

@onready var _player: Node = %Player
@onready var _tiles: TileMapLayer = %Tiles
@onready var _debug_overlay: DebugOverlay = %DebugOverlay
@onready var _help: Label = %Help


func _ready() -> void:
	_register_shoot_action()
	for block in BLOCKS:
		for x in range(block.position.x, block.end.x):
			for y in range(block.position.y, block.end.y):
				# Fuente 0, baldosa (0, 0) del atlas: el único bloque del greybox.
				_tiles.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	_player.reset_to(START)
	_player.shot_fired.connect(_on_shot_fired)
	_debug_overlay.track(_player)
	_update_help()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	var config: ShootConfig = _player.shoot_config
	match key.physical_keycode:
		KEY_1:
			config.mode = wrapi(config.mode + 1, 0, ShootConfig.Mode.size()) as ShootConfig.Mode
		KEY_2:
			config.delivery = (
				wrapi(config.delivery + 1, 0, ShootConfig.Delivery.size()) as ShootConfig.Delivery
			)
		KEY_3:
			config.run_rule = (
				wrapi(config.run_rule + 1, 0, ShootConfig.RunRule.size()) as ShootConfig.RunRule
			)
		KEY_4:
			# Solo el ángulo de abajo: 20 → 15 → 20. El de arriba se cambia en el .tres.
			config.aim_down_angle = 15.0 if config.aim_down_angle > 15.0 else 20.0
		KEY_5:
			# Altura de la boca al tirar abajo: 23 → 33 → 43 → 53 px sobre los pies.
			var height := -config.muzzle_down.y
			height = 23.0 if height >= 53.0 else height + 10.0
			config.muzzle_down = Vector2(config.muzzle_down.x, -height)
		KEY_R:
			_player.reset_to(START)
		_:
			return
	_update_help()


## Agrega la acción "shoot" en tiempo de ejecución, sin tocar project.godot: el botón
## definitivo se decide en la spec. Se usa physical_keycode (la posición de la tecla),
## como el resto del input map, así funciona igual con cualquier distribución de teclado.
func _register_shoot_action() -> void:
	if InputMap.has_action("shoot"):
		return
	InputMap.add_action("shoot")
	for code in [KEY_J, KEY_X]:
		var ev := InputEventKey.new()
		ev.physical_keycode = code
		InputMap.action_add_event("shoot", ev)
	var pad := InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_X
	InputMap.action_add_event("shoot", pad)


# La señal shot_fired se emite desde el _physics_process de Elyon, así que esto corre
# dentro del paso de física: es seguro consultar rayos acá.
func _on_shot_fired(origin: Vector2, direction: Vector2) -> void:
	var config: ShootConfig = _player.shoot_config
	var exclude: Array[RID] = [_player.get_rid()]
	if config.delivery == ShootConfig.Delivery.PROJECTILE:
		var p: Node2D = PROJECTILE.new()
		p.position = origin
		p.direction = direction
		p.speed = config.projectile_speed
		p.max_distance = config.shot_range
		p.mask = SHOT_MASK
		p.exclude = exclude
		add_child(p)
		return
	var end := origin + direction * config.shot_range
	var hit := ShotCaster.cast(get_world_2d(), origin, end, SHOT_MASK, exclude)
	if not hit.is_empty():
		end = hit.position
		ShotCaster.apply_hit(hit)
	_flash(origin, end, config.ray_flash_time)


func _flash(from: Vector2, to: Vector2, duration: float) -> void:
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = Color(1.0, 0.95, 0.4)
	line.points = PackedVector2Array([from, to])
	add_child(line)
	# Timer de un solo uso del árbol: al vencer libera la línea.
	get_tree().create_timer(duration, false, true).timeout.connect(line.queue_free)


func _update_help() -> void:
	var c: ShootConfig = _player.shoot_config
	_help.text = (
		(
			"J/X disparar · W/S apuntar · 1 modo: %s · 2 sale: %s · 3 corriendo: %s"
			+ " · 4 ángulo: %.0f°/%.0f° · 5 boca abajo: %.0f px · R · F3"
		)
		% [
			ShootConfig.Mode.keys()[c.mode],
			ShootConfig.Delivery.keys()[c.delivery],
			ShootConfig.RunRule.keys()[c.run_rule],
			c.aim_up_angle,
			c.aim_down_angle,
			-c.muzzle_down.y,
		]
	)
