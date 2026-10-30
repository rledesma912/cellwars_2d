// Suavizado "sharp bilinear" aplicado a cada sprite o baldosa, para el modo
// canvas_items: la escena se dibuja a la resolución de la pantalla y cada imagen
// de pixel art se agranda acá, con píxeles parejos aunque la escala no sea entera.
// El nodo tiene que usar filtro lineal. Sin render_mode unshaded: la luz 2D sigue.
shader_type canvas_item;

// Píxeles de pantalla por píxel del arte (×1,5 de 1280×720 a 1080p).
uniform float scale = 1.5;

void fragment() {
	vec2 src_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 texel = UV * src_size;
	vec2 texel_floored = floor(texel);
	vec2 center_dist = fract(texel) - 0.5;
	float region_range = 0.5 - 0.5 / scale;
	vec2 f = (center_dist - clamp(center_dist, -region_range, region_range)) * scale + 0.5;
	COLOR = texture(TEXTURE, (texel_floored + f) / src_size);
}
