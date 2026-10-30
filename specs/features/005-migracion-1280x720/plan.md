---
id: F005
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0004], spike: S002 }
updated: 2026-10-29
---

# Plan: feature 005

La mayor parte de esta feature es configuración y escalas. Lo único nuevo es la escala del pixel art: un cálculo de lógica pura, un shader con su material compartido y quién lo actualiza.

## Árbol de escenas

No hay escenas nuevas. Cambia el contenido de algunas existentes:

```
Main (Node)                         game/main.tscn: además actualiza la escala del pixel art
├── Screen (Node)
│   └── World (Node2D)              game/world/world.tscn (sin cambios)
│       ├── TestRoom (Node2D)       game/levels/test/test_room.tscn → 64 × 36
│       │   ├── Background (ColorRect)  1280×720
│       │   ├── Tiles (TileMapLayer)    material sharp_pixel + filtro lineal
│       │   └── Spawn (Marker2D)        (80, 680)
│       ├── Player (CharacterBody2D)    game/entities/player/player.tscn
│       │   ├── Sprite (AnimatedSprite2D)  elyon_99_frames, offset (−72, −144), material sharp_pixel
│       │   └── Shape (CollisionShape2D)   44 × 106, en (0, −53)
│       └── DebugOverlay (CanvasLayer)  letra y márgenes al doble
└── PauseMenu (CanvasLayer)          letra, botones y separación al doble
```

`game/ui/main_menu` y `game/ui/options_menu` también pasan al doble.

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/render/pixel_scale.gd` (`PixelScale`) | lógica pura | `for_window(window_size, base_size) -> float`: el menor de ancho / base y alto / base. Es la escala con la que `canvas_items` en aspecto `keep` agranda la escena (F005-AC02). |
| `game/art/shaders/sharp_pixel.gdshader` | shader | *Sharp bilinear* por sprite, el del spike 002. Lee la escala de un **uniform global** `pixel_scale`; con escala menor a 1 hace un filtro lineal común. |
| `game/art/shaders/sharp_pixel.tres` | Resource (`ShaderMaterial`) | El único material de pixel art. Lo comparten todos los sprites y baldosas. |
| `game/main.gd` | nodo | Al arrancar y en cada `size_changed` de la ventana, calcula `PixelScale.for_window()` y la publica con `RenderingServer.global_shader_parameter_set("pixel_scale", …)`. |
| `game/systems/rooms/room_geometry.gd` | lógica pura | `COLUMNS = 64`, `ROWS = 36`; `SIZE_PX` = 1280×720 (D0004). |
| `game/systems/player/player_movement_config.gd` | Resource | Valores por defecto × 2,2 en distancias y velocidades (tabla de la spec). |
| `game/data/player_movement.tres` | `.tres` | Los mismos valores. Lo escribe el agente con la autorización registrada en la spec. |
| `game/entities/player/player.tscn` | escena | Sprite de 99 px, colisión de 44 × 106 y material. `player.gd` solo cambia sus comentarios de tamaño. |
| `game/art/elyon/elyon_99.png` + `elyon_99_frames.tres` | arte | Imágenes provisorias del spike 002 en cuadros de 144 × 144, con pies en (72, 143). Reemplazan a `elyon_48`. |
| `game/levels/test/test_room.tscn` | sala de prueba | Cada baldosa pasa a 2 × 2, el fondo a 1280×720 y el `Spawn` a (80, 680). La genera un script de un solo uso que no se commitea. |
| `project.godot` | config | viewport 1280×720; sin el override de ventana a 1280×720 porque ya coincide; `stretch/mode = canvas_items`, `scale_mode = fractional`, `aspect = keep`; `snap_2d_transforms_to_pixel = false`; `[shader_globals] pixel_scale` (float, 1.0). |
| `game/ui/*/*.tscn`, `game/debug/debug_overlay.tscn` | escenas | Tamaños de letra, `custom_minimum_size`, separaciones y márgenes al doble. |

Elecciones no obvias:

- **Uniform global en vez de un parámetro por material.** Un *global shader uniform* es un valor que Godot comparte con todos los shaders que lo declaran. Basta un `set` para que cambie en todo el juego. Con un parámetro por material habría que encontrar y actualizar cada material, y es fácil olvidarse de uno. Se declara en *Project Settings → Shader Globals*.
- **Un `ShaderMaterial` compartido (`.tres`) en vez de uno por nodo.** Así, "todo el pixel art usa el material" (D0004) es simplemente asignar el mismo archivo, y se revisa buscando ese archivo en las escenas (F005-AC06).
- **Quién actualiza la escala: `Main`.** Es la raíz persistente y ya es dueña de la configuración global (pantalla completa, volumen, idioma). Lo descartado:
  - un autoload nuevo: la arquitectura permite como máximo un bus de eventos y el estado global;
  - que cada sala o personaje lo calcule: se repetiría y podría desincronizarse.
- **Filtro de textura lineal solo en los nodos con el material**: el shader necesita leer la mezcla de los bordes. El filtro por defecto del proyecto sigue en *Nearest*. Así un sprite que se quede sin material se nota enseguida, con píxeles desparejos, en lugar de verse borroso sin que nadie lo note.
- **Interfaz al doble en las escenas, no por código.** En `canvas_items` las letras se dibujan a la resolución de la pantalla y quedan nítidas. Duplicar los tamaños en cada escena es más simple que ajustar el `content_scale_factor` y no cambia cómo se arma la interfaz.

## Señales

Ninguna nueva. `Main` usa la señal propia de Godot `Window.size_changed` (sin payload) para recalcular la escala.

## Qué se testea con gdUnit4

- F005-AC01 → `test/rooms/room_geometry_test.gd`: `test_f005_ac01_room_matches_viewport`. Reemplaza a `test_room_size_matches_viewport`. Además, `test_f003_ac10_outside_room` se reescribe con las medidas nuevas: el criterio de la F003 sigue valiendo con otros números.
- F005-AC02 → `test/render/pixel_scale_test.gd`: `test_f005_ac02_pixel_scale_for_window`, con los 7 tamaños de la spec.
- F005-AC07 → `test/player/player_movement_config_test.gd`: `test_f005_ac07_defaults_scaled`. Reemplaza a `test_defaults_match_spec`.
- F005-AC08 → `test/player/player_motor_test.gd`: `test_f005_ac08_body_plus_jump_fits_floor`, con el `_jump_height(-1)` que ya existe y el alto de colisión de 106 px.
- Los tests de la F004 usan los valores por defecto del config. Tienen que seguir pasando con los valores nuevos, porque comparan contra `_config` y no contra números fijos.

## Impacto en overlay debug

Una línea nueva: **"escala pixel art"** con el valor actual (por ejemplo, "×1.50"). Sirve para verificar F005-AC03 y AC05 jugando.

La agrega `World`: implementa `get_debug_info()` y se registra con `track(self)`. Recalcula con la misma `PixelScale.for_window()` que usa `Main` para publicar el uniform.

Cambio respecto de la primera versión del plan: no se lee el uniform global porque Godot no deja leerlo fuera del editor. `RenderingServer.global_shader_parameter_get()` da error en el juego.

## Riesgos

- **Sprites sin material.** Hoy son pocos: Elyon y las baldosas. Las features futuras tienen que acordarse; queda escrito en `architecture.md` y AC06 lo revisa.
- **La sala de prueba se regenera por script.** Hay que verificar que quede idéntica al doble: misma forma, `Spawn` y fondo.
- **Interfaz:** un tamaño que se escape del doble se ve chico. Se revisa en el playtest (AC13 y AC14).
- **`size_changed` al pasar a pantalla completa:** Godot lo emite, pero hay que confirmarlo en el smoke run con el valor del overlay.
- **Uniform global:** si el `.gdshader` lo declara y `project.godot` no, Godot da error al compilar el shader. Las dos cosas van en la misma task.
