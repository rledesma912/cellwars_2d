// "Sharp bilinear": agranda pixel art en una escala no entera (p. ej. ×1,5) sin que
// unos píxeles queden dobles y otros simples. Dentro de cada píxel de origen el color
// es plano; solo la franja del borde entre dos píxeles se mezcla. Necesita que el
// TextureRect use filtro lineal.
shader_type canvas_item;

uniform vec2 src_size = vec2(1280.0, 720.0);
uniform float scale = 1.5;

void fragment() {
	vec2 texel = UV * src_size;
	vec2 texel_floored = floor(texel);
	vec2 center_dist = fract(texel) - 0.5;
	float region_range = 0.5 - 0.5 / scale;
	vec2 f = (center_dist - clamp(center_dist, -region_range, region_range)) * scale + 0.5;
	COLOR = texture(TEXTURE, (texel_floored + f) / src_size);
}
