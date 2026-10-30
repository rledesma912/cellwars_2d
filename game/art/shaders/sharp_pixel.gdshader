// Suavizado "sharp bilinear" del pixel art (decisión D0004).
//
// El juego se dibuja en canvas_items: a 1080p cada píxel del arte ocupa 1,5 píxeles
// de pantalla. Sin esto, unos píxeles quedarían dobles y otros simples. Dentro de
// cada píxel del arte el color es plano y solo se mezcla la franja del borde entre
// dos píxeles. Lo usan todos los sprites y baldosas, con filtro de textura lineal.
// Sin render_mode unshaded: las luces 2D siguen funcionando.
shader_type canvas_item;

// "global": el valor es uno solo para todos los shaders del juego. Lo declara
// project.godot (Shader Globals) y lo actualiza Main cuando cambia la ventana.
global uniform float pixel_scale;

void fragment() {
	if (pixel_scale <= 1.0) {
		// Escala 1 o ventana más chica que 1280×720: filtro lineal común.
		COLOR = texture(TEXTURE, UV);
	} else {
		vec2 src_size = 1.0 / TEXTURE_PIXEL_SIZE;
		vec2 texel = UV * src_size;
		vec2 center_dist = fract(texel) - 0.5;
		float region_range = 0.5 - 0.5 / pixel_scale;
		vec2 f = (center_dist - clamp(center_dist, -region_range, region_range)) * pixel_scale + 0.5;
		COLOR = texture(TEXTURE, (floor(texel) + f) / src_size);
	}
}
