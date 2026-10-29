## Spike 002: compara resoluciones internas, modo de dibujado y escalado a pantalla.
##
## Código descartable. Teclas:
##   1 / 2 / 3  resolución (640×360, 960×540, 1280×720)
##   M          modo de dibujado: viewport (retro) ↔ canvas_items (moderno)
##   E          escalado: entero → fraccional nítido → fraccional suavizado
##   L          luz de prueba sí/no
##   F11        pantalla completa · R vuelve a la entrada · H oculta este cartel
## Moverse y saltar: las mismas teclas del juego.
extends Node

enum Scaling { INTEGER, FRACTIONAL, SHARP }

const SCALING_NAMES := {
	Scaling.INTEGER: "entero",
	Scaling.FRACTIONAL: "fraccional nítido",
	Scaling.SHARP: "fraccional suavizado",
}
const PLAYER_SCENE := preload("res://game/entities/player/player.tscn")
const BASE_CONFIG := preload("res://game/data/player_movement.tres")
const SHARP_SHADER := preload("res://prototypes/spike_002/sharp_bilinear.gdshader")

## Las tres resoluciones; cada .tres se edita en el inspector.
var variants: Array[ResolutionVariant] = [
	preload("res://prototypes/spike_002/variant_640.tres"),
	preload("res://prototypes/spike_002/variant_960.tres"),
	preload("res://prototypes/spike_002/variant_1280.tres"),
]

var _index := 0
var _canvas_items := false
var _scaling := Scaling.INTEGER
var _light_on := true

var _world: Node2D
var _player: Player
var _light: PointLight2D
var _ambient: CanvasModulate
var _base := Vector2i(640, 360)
var _spawn := Vector2.ZERO

# Para el escalado suavizado el mundo se dibuja en un SubViewport (una pantalla
# aparte del tamaño de la resolución interna) y un TextureRect lo muestra con el shader.
var _sub_viewport: SubViewport
var _screen: TextureRect
var _hud: CanvasLayer
var _label: Label
var _time := 0.0


func _ready() -> void:
	_sub_viewport = SubViewport.new()
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_sub_viewport)
	_screen = TextureRect.new()
	_screen.texture = _sub_viewport.get_texture()
	_screen.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Que tome el tamaño que le damos, no el de la textura.
	_screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_screen.stretch_mode = TextureRect.STRETCH_SCALE
	_screen.material = ShaderMaterial.new()
	(_screen.material as ShaderMaterial).shader = SHARP_SHADER
	_screen.visible = false
	add_child(_screen)

	_hud = CanvasLayer.new()
	_hud.layer = 10
	_label = Label.new()
	_label.add_theme_color_override("font_color", Color(1, 1, 0.8))
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 4)
	_hud.add_child(_label)
	add_child(_hud)

	get_window().size_changed.connect(_apply_display)
	_load_variant(0)
	# Prueba automática del agente: recorre todas las combinaciones y captura la ventana.
	var args := OS.get_cmdline_user_args()
	if args.size() >= 2 and args[0] == "--autotest":
		_autotest(args[1])


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_1, KEY_2, KEY_3:
			_load_variant(key.keycode - KEY_1)
		KEY_M:
			_canvas_items = not _canvas_items
			_apply_display()
		KEY_E:
			_scaling = ((_scaling + 1) % 3) as Scaling
			_apply_display()
		KEY_L:
			_light_on = not _light_on
			_light.visible = _light_on
			_ambient.visible = _light_on
		KEY_F11:
			var full := get_window().mode == Window.MODE_FULLSCREEN
			get_window().mode = Window.MODE_WINDOWED if full else Window.MODE_FULLSCREEN
		KEY_R:
			_player.reset_to(_spawn)
		KEY_H:
			_label.visible = not _label.visible


func _physics_process(delta: float) -> void:
	_time += delta
	# La luz recorre la sala despacio, para ver cómo cae sobre Elyon y las baldosas.
	_light.position = Vector2(
		_base.x * (0.5 + 0.4 * sin(_time * 0.4)), _base.y * (0.5 + 0.3 * sin(_time * 0.9))
	)
	# Caer al precipicio o salir por cualquier borde: vuelve a la entrada.
	var p := _player.position
	if p.y > _base.y + 60 or p.x < -40 or p.x > _base.x + 40:
		_player.reset_to(_spawn)


func _load_variant(index: int) -> void:
	_index = index
	var variant := variants[index]
	_base = variant.base_size
	if _world != null:
		_world.queue_free()
	_world = Node2D.new()
	# Entra al árbol ya, así el Player corre su _ready() (crea el motor) al agregarlo.
	# _apply_display() lo mueve al viewport que corresponda.
	add_child(_world)
	_world.add_child(RoomBuilder.build(_base, variant.step_tiles))
	_spawn = RoomBuilder.spawn(_base)

	_player = PLAYER_SCENE.instantiate()
	# config se asigna antes de entrar al árbol: Player crea su motor en _ready().
	_player.config = _scaled_config(variant.elyon_scale)
	_world.add_child(_player)
	_dress_player(variant)
	_player.reset_to(_spawn)

	# CanvasModulate oscurece todo lo que está en su mismo canvas; la PointLight2D
	# suma luz encima. Juntas dan la prueba de "iluminación moderna".
	_ambient = CanvasModulate.new()
	_ambient.color = Color(0.45, 0.42, 0.55)
	_world.add_child(_ambient)
	_light = PointLight2D.new()
	_light.texture = _light_texture()
	_light.texture_scale = _base.y / 360.0
	_light.energy = 1.3
	_light.color = Color(1.0, 0.85, 0.7)
	_world.add_child(_light)
	_light.visible = _light_on
	_ambient.visible = _light_on

	_label.add_theme_font_size_override("font_size", roundi(9 * _base.y / 360.0))
	_apply_display()


# Mismos tiempos que D0003; distancias y velocidades se multiplican por el tamaño.
func _scaled_config(k: float) -> PlayerMovementConfig:
	var c: PlayerMovementConfig = BASE_CONFIG.duplicate()
	c.run_speed *= k
	c.jump_height *= k
	c.min_jump_height *= k
	c.max_fall_speed *= k
	c.hard_landing_height *= k
	return c


func _dress_player(variant: ResolutionVariant) -> void:
	var sprite: AnimatedSprite2D = _player.get_node("%Sprite")
	var meta: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(variant.sheet_path.get_basename() + ".json")
	)
	var cell: int = meta["frame_size"][0]
	sprite.sprite_frames = _frames(load(variant.sheet_path), meta, cell)
	# Pies en la última fila, al centro del cuadro: el origen del Player está en los pies.
	sprite.offset = Vector2(-cell / 2.0, -cell)
	var shape: CollisionShape2D = _player.get_node("%Shape")
	var rect := RectangleShape2D.new()
	rect.size = Vector2(20, 48) * variant.elyon_scale
	shape.shape = rect
	shape.position = Vector2(0, -rect.size.y / 2.0)


func _frames(sheet: Texture2D, meta: Dictionary, cell: int) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for anim: String in meta["animations"]:
		var m: Dictionary = meta["animations"][anim]
		frames.add_animation(anim)
		frames.set_animation_speed(anim, m["fps"])
		frames.set_animation_loop(anim, m["loop"])
		for i in int(m["count"]):
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2((int(m["start"]) + i) * cell, 0, cell, cell)
			frames.add_frame(anim, atlas)
	return frames


func _light_texture() -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 256
	tex.height = 256
	return tex


## Aplica resolución, modo de dibujado y escalado a la ventana.
func _apply_display() -> void:
	var win := get_window()
	var sharp := _scaling == Scaling.SHARP
	var target: Node = self
	if sharp:
		target = _sub_viewport
	if _world.get_parent() != target:
		# Mover el mundo de viewport cambia su espacio de física, pero va entero
		# (sala y Elyon juntos), así que todo sigue funcionando.
		if _world.get_parent() != null:
			_world.get_parent().remove_child(_world)
		target.add_child(_world)
		if not sharp:
			move_child(_world, 0)
	_screen.visible = sharp

	var fit := minf(float(win.size.x) / _base.x, float(win.size.y) / _base.y)
	var factor := fit
	if sharp:
		# Sin escalado de Godot: el TextureRect llena la pantalla y el shader agranda.
		win.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		_sub_viewport.size = _base
		_sub_viewport.snap_2d_transforms_to_pixel = true
		var size := Vector2(_base) * fit
		_screen.size = size
		_screen.position = (Vector2(win.size) - size) / 2.0
		var mat := _screen.material as ShaderMaterial
		mat.set_shader_parameter("src_size", Vector2(_base))
		mat.set_shader_parameter("scale", fit)
	else:
		# viewport: dibuja todo a la resolución interna y agranda la imagen.
		# canvas_items: dibuja a la resolución de la pantalla; el arte se agranda por
		# separado y el movimiento puede caer entre píxeles (más suave).
		win.content_scale_mode = (
			Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
			if _canvas_items
			else Window.CONTENT_SCALE_MODE_VIEWPORT
		)
		win.content_scale_size = _base
		win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		win.content_scale_stretch = (
			Window.CONTENT_SCALE_STRETCH_INTEGER
			if _scaling == Scaling.INTEGER
			else Window.CONTENT_SCALE_STRETCH_FRACTIONAL
		)
		# Ajustar a píxel solo tiene sentido en el modo retro.
		win.snap_2d_transforms_to_pixel = not _canvas_items
		if _scaling == Scaling.INTEGER:
			factor = maxf(1.0, floorf(fit))
	_update_label(factor)


func _update_label(factor: float) -> void:
	var mode := (
		"(se dibuja a la resolución interna)"
		if _scaling == Scaling.SHARP
		else ("canvas_items (moderno)" if _canvas_items else "viewport (retro)")
	)
	var elyon_px := roundi(45 * variants[_index].elyon_scale)
	_label.text = (
		(
			"%s · Elyon %d px · %s · %s ×%.2f · luz %s · ventana %d×%d\n"
			% [
				variants[_index].label,
				elyon_px,
				mode,
				SCALING_NAMES[_scaling],
				factor,
				"sí" if _light_on else "no",
				get_window().size.x,
				get_window().size.y,
			]
		)
		+ "1/2/3 resolución · M modo · E escalado · L luz · F11 pantalla completa · R entrada · H ocultar"
	)
	_label.position = Vector2(6, 22 * _base.y / 360.0)


# Pantalla completa, y para cada resolución: viewport entero/fraccional, canvas_items
# entero/fraccional y suavizado. Captura solo la ventana del juego con spectacle.
func _autotest(out_dir: String) -> void:
	get_window().mode = Window.MODE_FULLSCREEN
	await get_tree().create_timer(1.5).timeout
	for i in variants.size():
		_load_variant(i)
		for combo: Array in [
			[false, Scaling.INTEGER],
			[false, Scaling.FRACTIONAL],
			[true, Scaling.INTEGER],
			[true, Scaling.FRACTIONAL],
			[false, Scaling.SHARP],
		]:
			_canvas_items = combo[0]
			_scaling = combo[1]
			_apply_display()
			await get_tree().create_timer(1.0).timeout
			var name := (
				"%d_%s_%s"
				% [
					variants[i].base_size.y,
					"canvas" if _canvas_items else "viewport",
					["entero", "fraccional", "suavizado"][_scaling],
				]
			)
			OS.execute("spectacle", ["-b", "-n", "-a", "-o", out_dir.path_join(name + ".png")])
			print("captura ", name, " ventana ", get_window().size)
	get_tree().quit()
