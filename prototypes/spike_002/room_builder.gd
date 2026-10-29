## Arma la sala de prueba del spike 002 para una resolución (código descartable).
##
## La sala es la misma en todas las resoluciones, en proporción: 3 pisos que ocupan un
## tercio del alto cada uno, un precipicio en la planta baja y escalones flotantes para
## subir (a la derecha en la planta baja, a la izquierda en el primer piso).
## Salida: borde derecho del último piso.
class_name RoomBuilder
extends RefCounted

const TILE := 20


## Devuelve un Node2D con el fondo, la prueba de píxeles y el TileMapLayer.
static func build(base: Vector2i, step: int) -> Node2D:
	var root := Node2D.new()
	root.name = "Room"

	# Fondo con un ColorRect (no el color de limpieza): así la luz 2D también lo ilumina.
	var bg := ColorRect.new()
	bg.color = Color(0.16, 0.10, 0.13)
	bg.size = Vector2(base)
	root.add_child(bg)
	root.add_child(_pixel_test())

	var layer := TileMapLayer.new()
	layer.tile_set = _tile_set()
	for cell in _cells(floori(base.x / float(TILE)), floori(base.y / float(TILE)), step):
		layer.set_cell(cell, 0, Vector2i.ZERO)
	root.add_child(layer)
	return root


## Posición de los pies al entrar: planta baja, a la izquierda.
static func spawn(base: Vector2i) -> Vector2:
	return Vector2(TILE * 2, base.y - TILE)


static func _cells(cols: int, rows: int, step: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var floor_h := floori(rows / 3.0)  # baldosas por piso (incluye la del piso)
	var n := ceili(float(floor_h) / step)  # escalones hasta el piso siguiente
	var w := roundi(3.0 * cols / 32.0)  # ancho de cada escalón
	var ground := rows - 1
	var floor2 := ground - floor_h
	var floor3 := floor2 - floor_h

	# Planta baja con un precipicio.
	var gap_from := roundi(0.30 * cols)
	var gap_to := gap_from + roundi(2.0 * cols / 32.0)
	for x in cols:
		if x < gap_from or x >= gap_to:
			cells.append(Vector2i(x, ground))
	# Pared derecha de los dos pisos de abajo: la salida está arriba.
	for y in range(floor2, ground):
		cells.append(Vector2i(cols - 1, y))

	# Escalones flotantes a la derecha, de menor a mayor altura hacia la izquierda.
	# El último escalón ya es el borde del primer piso.
	var right := cols - 1
	for i in range(1, n):
		for x in range(right - i * w, right - (i - 1) * w):
			cells.append(Vector2i(x, ground - i * step))
	var floor2_from := roundi(0.10 * cols)
	for x in range(floor2_from, right - (n - 1) * w):
		cells.append(Vector2i(x, floor2))

	# Escalones a la izquierda del primer piso, subiendo hacia la derecha.
	for i in range(1, n):
		for x in range(floor2_from + (i - 1) * w, floor2_from + i * w):
			cells.append(Vector2i(x, floor2 - i * step))
	for x in range(floor2_from + (n - 1) * w, cols):
		cells.append(Vector2i(x, floor3))
	return cells


# Baldosa de 20 × 20 con detalle de 1 px (borde, brillo arriba y trama): si el
# escalado no es entero, acá se nota que unos píxeles quedan dobles y otros simples.
static func _tile_set() -> TileSet:
	var img := Image.create(TILE, TILE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.42, 0.24, 0.28))
	for i in TILE:
		img.set_pixel(i, 0, Color(0.72, 0.46, 0.48))
		img.set_pixel(i, TILE - 1, Color(0.22, 0.11, 0.14))
		img.set_pixel(TILE - 1, i, Color(0.22, 0.11, 0.14))
	for y in range(4, 16):
		for x in range(4, 16):
			if (x + y) % 2 == 0:
				img.set_pixel(x, y, Color(0.34, 0.18, 0.22))
	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(img)
	source.texture_region_size = Vector2i(TILE, TILE)
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE, TILE)
	tile_set.add_physics_layer()
	tile_set.add_source(source, 0)
	source.create_tile(Vector2i.ZERO)
	var data := source.get_tile_data(Vector2i.ZERO, 0)
	var half := TILE / 2.0
	data.add_collision_polygon(0)
	data.set_collision_polygon_points(
		0,
		0,
		PackedVector2Array(
			[Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)]
		)
	)
	return tile_set


# Franja de prueba arriba a la izquierda: rayas y damero de 1 px. Es la forma más
# rápida de ver si el escalado deforma los píxeles.
static func _pixel_test() -> Sprite2D:
	var img := Image.create(60, 12, false, Image.FORMAT_RGBA8)
	for y in 12:
		for x in 60:
			var on := (x % 2 == 0) if y < 6 else ((x + y) % 2 == 0)
			img.set_pixel(x, y, Color(0.9, 0.9, 0.85) if on else Color(0.1, 0.1, 0.1))
	var sprite := Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.centered = false
	sprite.position = Vector2(4, 4)
	return sprite
