# Prompts de Elyon en pixel art (ComfyUI + Flux Kontext Dev)

Para ver cómo se vería Elyon a escala de juego (Spike 001). Todo corre local en ComfyUI con la plantilla **Flux Kontext Dev Image Edit**.

## Cómo usarlos

1. **Imagen de entrada**: `comfy/elyon_side_right.png` (la vista de perfil de la hoja de personaje, espejada para que mire a la derecha). Kontext conserva el ángulo de la imagen que recibe: con una imagen de tres cuartos sale de tres cuartos.
2. Pegá **una** orden por vez en el nodo de texto. Kontext no usa prompt negativo.
3. Valores: guidance 2.5, 20 pasos. Cada imagen tarda unos 3 minutos en la RTX 3060.
4. **No le pidas un tamaño en píxeles**: estos modelos no saben contarlos. El tamaño real (40 o 48 px) se lo da `comfy/to_sprite.py` al achicar.
5. Guardá cada resultado con el nombre sugerido.

## Lo que aprendimos probando (2026-10-25)

- Con la vista de perfil sale de perfil; con la de tres cuartos, no.
- Sin nombrar la mochila, la manguera y el arma, las pierde. Nombradas, aparecen; la manguera a veces cuelga en vez de llegar al arma.
- El arma sale como un fusil actual: el diseño del arma de Elyon no está en la hoja de personaje.
- Copiar una pose dándole una segunda imagen (un maniquí en la pose) **no funcionó**: ignoró la pose y dibujó otra. Ver "Poses" abajo.
- Pedir "face hidden behind the visor" deformó la cara: no hace falta, a tamaño real no se ve.

## Uso automático (desde Claude Code)

`comfy/kontext_run.py` encola el workflow (`comfy/kontext_api.json`, sacado del historial de ComfyUI) por la API y baja el resultado; `comfy/to_sprite.py` saca el fondo, lo achica y lo apoya en un lienzo de 64×64.

```
python3 comfy/kontext_run.py --image comfy/elyon_side_right.png --prompt "..." --seed 1 --out salida.png
python3 comfy/to_sprite.py salida.png sprite_40.png --height 40
```

## Órdenes por pose

Todas comparten la misma orden; solo cambia la pose.

### Quieto — `elyon_quieto.png`

```
Convert this character into a simple low-detail 16-bit pixel art game sprite, side view facing right, full body, standing idle, holding the rifle low. He wears a large rectangular armored backpack on his back. A thick black hose comes out of the backpack and connects to a futuristic rifle he holds in both hands. Keep the same white and grey armor plates over the black bodysuit and the same helmet. Chunky large pixels, flat colors, dark outline. Plain white background, no shadow.
```

### Correr — `elyon_correr.png`

```
Convert this character into a simple low-detail 16-bit pixel art game sprite, side view facing right, full body, running mid stride, holding the rifle. He wears a large rectangular armored backpack on his back. A thick black hose comes out of the backpack and connects to a futuristic rifle he holds in both hands. Keep the same white and grey armor plates over the black bodysuit and the same helmet. Chunky large pixels, flat colors, dark outline. Plain white background, no shadow.
```

### Frenar — `elyon_frenar.png`

```
Convert this character into a simple low-detail 16-bit pixel art game sprite, side view facing right, full body, skidding to a stop, torso leaning back, front leg planted forward. He wears a large rectangular armored backpack on his back. A thick black hose comes out of the backpack and connects to a futuristic rifle he holds in both hands. Keep the same white and grey armor plates over the black bodysuit and the same helmet. Chunky large pixels, flat colors, dark outline. Plain white background, no shadow.
```

### Preparar salto — `elyon_preparar_salto.png`

```
Convert this character into a simple low-detail 16-bit pixel art game sprite, side view facing right, full body, crouching before a jump, knees bent, torso leaning forward. He wears a large rectangular armored backpack on his back. A thick black hose comes out of the backpack and connects to a futuristic rifle he holds in both hands. Keep the same white and grey armor plates over the black bodysuit and the same helmet. Chunky large pixels, flat colors, dark outline. Plain white background, no shadow.
```

### Subiendo (en el aire) — `elyon_subiendo.png`

```
Convert this character into a simple low-detail 16-bit pixel art game sprite, side view facing right, full body, jumping upward, knees pulled up. He wears a large rectangular armored backpack on his back. A thick black hose comes out of the backpack and connects to a futuristic rifle he holds in both hands. Keep the same white and grey armor plates over the black bodysuit and the same helmet. Chunky large pixels, flat colors, dark outline. Plain white background, no shadow.
```

### Cayendo — `elyon_cayendo.png`

```
Convert this character into a simple low-detail 16-bit pixel art game sprite, side view facing right, full body, falling, legs extended down, one arm out for balance. He wears a large rectangular armored backpack on his back. A thick black hose comes out of the backpack and connects to a futuristic rifle he holds in both hands. Keep the same white and grey armor plates over the black bodysuit and the same helmet. Chunky large pixels, flat colors, dark outline. Plain white background, no shadow.
```

### Aterrizar — `elyon_aterrizar.png`

```
Convert this character into a simple low-detail 16-bit pixel art game sprite, side view facing right, full body, landing from a high fall, deep crouch. He wears a large rectangular armored backpack on his back. A thick black hose comes out of the backpack and connects to a futuristic rifle he holds in both hands. Keep the same white and grey armor plates over the black bodysuit and the same helmet. Chunky large pixels, flat colors, dark outline. Plain white background, no shadow.
```

### Apuntar — `elyon_apuntar.png`

```
Convert this character into a simple low-detail 16-bit pixel art game sprite, side view facing right, full body, standing and aiming the rifle forward with both hands. He wears a large rectangular armored backpack on his back. A thick black hose comes out of the backpack and connects to a futuristic rifle he holds in both hands. Keep the same white and grey armor plates over the black bodysuit and the same helmet. Chunky large pixels, flat colors, dark outline. Plain white background, no shadow.
```

## Poses

El recurso para fijar poses es **ControlNet OpenPose**: se le da un esqueleto de palitos y el modelo respeta esa postura. Con Kontext no funciona (Kontext no admite ControlNet y la segunda imagen la ignoró). Opciones si hace falta precisión de pose:

- **SDXL + ControlNet OpenPose + IP-Adapter + LoRA Pixel Art XL**: pose exacta; el parecido con Elyon lo da IP-Adapter, menos fiel que Kontext.
- **Dos pasos**: generar la pose con OpenPose y después pasarla por Kontext para que se parezca a Elyon.
