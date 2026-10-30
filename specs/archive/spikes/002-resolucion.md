---
id: S002
type: spike
status: done
superseded_by:
links: { gdd: [G001], decisions: [D0002, D0003], spike: }
updated: 2026-10-29
---

# Spike 002: Resolución interna y tamaño de Elyon

- Branch: `spike/002-resolucion`
- Tipo: técnico
- Origen: pedido del desarrollador (pixel art moderno, más definición) · pendiente del Spike 001 ("48 px puede quedarse corto de definición; subirlo implicaría cambiar la resolución del juego")

## Definición (se aprueba antes de empezar)

- Pregunta: ¿qué resolución interna, qué modo de dibujado y qué forma de agrandar la imagen a 1080p dan un pixel art moderno, con Elyon más definido y algo más alto, sin perder los 3 pisos por sala?
- Aprobada por el desarrollador el 2026-10-29 ("Apruebo la definición!"), con los cambios surgidos de la investigación en documentación y foros: se suma el eje del modo de dibujado y una luz de prueba, y 1280×720 queda como referencia del escalado ×1,5.
- Motivo: la resolución fija el tamaño en píxeles de baldosas, salas, Elyon y los valores de movimiento. Cambiarla después de la F005 (varias salas) obligaría a rehacer salas y arte. Hay más de una opción y elegir mal es caro (principio 1).
- Motivo nuevo frente a `discarded.md` ("Soldado de más de 48 px"): esa idea se descartó porque en 640×360 no entraba un soldado más alto con 3 pisos y salto de 52 px. Con una resolución mayor y la baldosa en 20 px, el piso de baldosa ocupa menos proporción de la pantalla y deja aire para un Elyon más alto.
- Contexto medido: los dos monitores del desarrollador son de 1920×1080 (escala 1). Es la pantalla con la que se juzga.
- Alcance:
  - Entra:
    - una sala de prueba por resolución, con 3 pisos, escalones, un hueco y Elyon a escala;
    - las formas de agrandar la imagen a 1080p;
    - los valores de movimiento de D0003 escalados en proporción (distancias y velocidades × factor, tiempos iguales), para confirmar que el feel se conserva;
    - verlo en ventana y en pantalla completa.
  - No entra:
    - juzgar el detalle del arte final: Elyon se agranda desde el sprite de 48 px y se va a ver "en bloques", así que solo sirve para proporciones y escalado;
    - menús y UI;
    - la cámara;
    - el contenido de las salas de la F005.
- Criterios de salida:
  1. El desarrollador vio cada resolución en pantalla completa a 1080p y eligió una.
  2. Para la elegida, eligió el modo de dibujado (`viewport` o `canvas_items`) y la forma de agrandar la imagen.
  3. Aprobó las proporciones: alto de Elyon, alto del salto y 3 pisos por sala.
  4. Reportó si el movimiento escalado se siente igual que el de D0003 `[feel]`.
- Alternativas a evaluar (se cambian en vivo, sin reiniciar):

  | Tecla | Resolución | Baldosa | Sala | Aire por piso | Elyon | Salto | A 1080p |
  |---|---|---|---|---|---|---|---|
  | 1 | 640×360 (hoy) | 20 | 32 × 18 | 100 | 48 | 52 | ×3 exacto |
  | 2 | 960×540 | 20 | 48 × 27 | 160 | ~78 | ~82 | ×2 exacto |
  | 3 | 1280×720 | 20 | 64 × 36 | 220 | ~104 | ~114 | ×1,5, no entero |

  Modo de dibujado (tecla M):
  - **`viewport`** (retro): todo se dibuja a la resolución interna y se agranda la imagen entera.
  - **`canvas_items`** (moderno): el arte sigue siendo pixel art, pero se dibuja a la resolución de la pantalla. El movimiento es más suave y los efectos salen en alta definición.

  Escalado a 1080p (tecla E): entero (con bordes si no entra), fraccional nítido y fraccional suavizado (*sharp bilinear*, con un shader propio). Los dos fraccionales solo importan en 1280×720.

  Luz de prueba (tecla L): una luz 2D que recorre la sala sobre un ambiente oscurecido, para ver cómo se comporta en cada modo.
- Destino del código: descartar. Lo que se traslada son los números (resolución, tamaños, factor de los valores de movimiento) y la forma de escalado elegida.

## Qué se construyó

Prototipo en `prototypes/spike_002/` (escena `spike_002.tscn`), con todo cambiable en vivo:

- **Una sala de prueba por resolución**, armada por código con la misma forma en proporción: 3 pisos de un tercio del alto cada uno, un precipicio en la planta baja, escalones flotantes y salida en el último piso. Baldosa de 20 px con detalle de 1 px y una franja de rayas de 1 px para ver deformaciones del escalado.
- **Elyon dibujado a cada tamaño** (45, 72 y 99 px de alto visible, en cuadros de 64, 104 y 144 px), generado desde las mismas imágenes de origen que la tira del juego. No es Elyon agrandado: cada tamaño tiene su propio detalle.
- **El `Player` real del juego**, con los valores de D0003 multiplicados por el tamaño en distancias y velocidades y los tiempos sin cambiar.
- **Modo de dibujado** (`viewport` o `canvas_items`) y **cuatro escalados**:
  - entero;
  - fraccional nítido;
  - fraccional suavizado, con *sharp bilinear* sobre la imagen terminada;
  - suavizado moderno: `canvas_items` con *sharp bilinear* aplicado a cada sprite y baldosa (`sharp_sprite.gdshader`), sumado durante el spike para combinar lo elegido.
- **Luz de prueba**: una `PointLight2D` que recorre la sala sobre un ambiente oscurecido con `CanvasModulate`.
- **Prueba automática** (`-- --autotest <carpeta>`): recorre las 18 combinaciones en pantalla completa y captura la ventana. Sirvió para revisar cada una antes del playtest.

## Evidencia y findings

- **Pantalla de referencia**: los dos monitores del desarrollador son de 1920×1080 (medido con `xrandr`).
- **Investigación previa** (documentación de Godot, GDQuest, foros de Godot y GDevelop):
  - Godot recomienda 640×360 con escalado entero para pixel art;
  - una base de 1280×720 en 1080p queda ×1,5 y se deforma;
  - Godot no trae *sharp bilinear*: hay que escribirlo como shader;
  - lo "moderno" del pixel art actual (*hi-bit*) viene de la luz, los efectos y el movimiento suave, no de la resolución.
- **Playtest del desarrollador** (2026-10-29):
  1. Resolución: **1280×720**.
  2. Escalado: **suavizado**.
  3. Modo: **`canvas_items`**.
  4. Movimiento escalado: "es igual" que el de D0003 `[feel]`.
- **Conflicto detectado y resuelto**: en la primera versión del prototipo el suavizado dibujaba a la resolución interna, así que no se combinaba con `canvas_items`. Se sumó el "suavizado moderno". Playtest del desarrollador:
  - Elyon y las baldosas "se ven parejos";
  - la luz "se ve suave";
  - el movimiento "se ve fluido";
  - "la combinación está bien".
- Capturas propias a 1920×1080:
  - el nítido muestra píxeles dobles y simples alternados;
  - el suavizado y el suavizado moderno los dejan parejos, con un borde apenas blando;
  - en `viewport` la luz se ve en escalones de la resolución interna; en `canvas_items` se ve continua.
- **Proporciones a 1280×720**: piso de 240 px (20 de baldosa + 220 de aire); Elyon de 99 px visibles + salto de 114 px = 213 px; escalones de 4 baldosas (80 px) cómodos.

## Valores de tuning que funcionaron

| Parámetro | Valor | Nota |
|---|---|---|
| Resolución interna | 1280×720 | `variant_1280.tres` |
| Modo de dibujado | `canvas_items`, aspecto `keep`, escalado fraccional | — |
| Suavizado | *sharp bilinear* por sprite, `scale` = píxeles de pantalla por píxel del arte (×1,5 en 1080p) | `sharp_sprite.gdshader` |
| Baldosa / sala | 20 px / 64 × 36 baldosas, 12 por piso | — |
| Factor de tamaño de Elyon | ×2,2 respecto de D0003 | `elyon_scale` en `variant_1280.tres` |
| Elyon | 99 px visibles, cuadro de 144 × 144 con pies en (72, 143), colisión 44 × 106 | `elyon_99.png` (imágenes provisorias) |
| Movimiento | distancias y velocidades de `game/data/player_movement.tres` × 2,2; tiempos iguales | p. ej. salto de 52 → 114 px |
| Escalón máximo usado | 4 baldosas (80 px) | `step_tiles` en `variant_1280.tres` |

## Riesgos y limitaciones

- **Todo el pixel art necesita el shader.** Un sprite o una baldosa sin el material se ve con píxeles desparejos. Hay que resolverlo con una regla de arquitectura (un material compartido y un valor de escala global que se actualice al cambiar el tamaño de la ventana), no nodo por nodo.
- **Escalar o rotar sprites dentro del juego** mezcla tamaños de píxel. En `canvas_items` se nota más: conviene evitarlo o dibujar esas variantes.
- **Costo de arte**: cada cuadro de Elyon pasa de unos 2.000 a unos 10.000 píxeles, y una sala de 576 a 2.304 baldosas.
- **Interfaz**: los menús, las opciones y el overlay de debug están pensados para 640×360 y hay que reacomodarlos al nuevo tamaño.
- **No probado**: otras pantallas (1440p, 4K, ventanas de tamaños raros) y el rendimiento en equipos modestos. El shader es barato, pero no se midió.
- **Sprites provisorios**: los de 99 px salen del mismo proceso provisorio que los de 48. El arte final lo dibuja el desarrollador.

## Recomendación

Adoptar 1280×720 en `canvas_items`, con escalado fraccional y *sharp bilinear* por sprite, baldosa de 20 px (sala de 64 × 36) y Elyon escalado ×2,2 con los mismos tiempos de movimiento. Se registra en la decisión D0004.

## Siguiente paso

- [x] Decisión D0004 → actualizar arquitectura, `CLAUDE.md`, backlog y descartes; después, una feature que migre el juego a la nueva resolución antes de la F005.
