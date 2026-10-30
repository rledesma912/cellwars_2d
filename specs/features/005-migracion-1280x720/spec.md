---
id: F005
type: feature
status: approved
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0004], spike: S002 }
updated: 2026-10-29
---

# Feature 005: Migración a 1280×720

- Origen: decisión 0004 (spike 002).
- Vía: completa (toca render, personaje, salas, menús y overlay de debug; tiene `[feel]`).

## Objetivo

Que el juego que existe hoy (menús, opciones, pausa, sala de prueba y Elyon con su movimiento) pase a la resolución de D0004 y conserve todo lo que hace:

- resolución interna de 1280×720 en `canvas_items`, con escalado fraccional;
- suavizado *sharp bilinear* en todo el pixel art;
- baldosa de 20 px y sala de 64 × 36;
- Elyon de 99 px, con los mismos tiempos de movimiento.

Al jugar se tiene que ver como el "suavizado moderno" del spike 002 y sentirse igual que la F004.

## Fuera de alcance

- Luces, partículas y efectos en el juego: el spike solo los usó para comparar.
- Arte final de Elyon y de las baldosas. Siguen las imágenes provisorias y el greybox.
- Varias salas y el paso entre ellas (F006), muerte y checkpoint (F007).
- Cambiar el estilo o los tiempos del movimiento.
- Opción de resolución o de escalado en el menú de opciones.
- Cámara: las salas siguen siendo de pantalla fija.

## Criterios de aceptación

Render y escala:

- F005-AC01 [unit] `RoomGeometry` mide baldosas de 20 px y salas de 64 × 36. `SIZE_PX` es 1280×720 e igual a la resolución interna del proyecto (`viewport_width` / `viewport_height`).
- F005-AC02 [unit] La escala del pixel art (píxeles de pantalla por píxel del arte) para un tamaño de ventana es el menor de ancho / 1280 y alto / 720:
  - 1920×1080 → 1,5;
  - 1280×720 → 1;
  - 2560×1440 → 2;
  - 3840×2160 → 3;
  - 1366×768 → ≈ 1,067;
  - 2560×1080 → 1,5;
  - 960×540 → 0,75.
- F005-AC03 [manual] En pantalla completa en un monitor de 1920×1080, la sala llena la pantalla sin bordes negros. La configuración es la de D0004: `canvas_items`, aspecto `keep`, escalado fraccional y `snap_2d_transforms_to_pixel` en `false`.
- F005-AC04 [manual] En pantalla completa a 1080p, Elyon y las baldosas se ven con los píxeles parejos, sin filas o columnas dobles alternadas. Se ven como el "suavizado moderno" del spike 002.
- F005-AC05 [manual] En ventana, al cambiar su tamaño a mano, la imagen mantiene 16:9, con bordes si hace falta, y el pixel art sigue parejo. La escala se recalcula sola, sin reiniciar.
- F005-AC06 [manual] Ningún sprite ni baldosa de pixel art del juego se dibuja sin el material de suavizado. Se verifica revisando las escenas: Elyon, las baldosas de la sala de prueba y cualquier otro sprite que exista.

Elyon y movimiento:

- F005-AC07 [unit] Los valores por defecto de `PlayerMovementConfig` son los de D0003 con distancias y velocidades × 2,2 y los mismos tiempos (ver la tabla de tuning).
- F005-AC08 [unit] Con los valores por defecto, el salto máximo más el alto de la colisión (106 px) no pasa de 220 px, el aire de un piso. Simulado en pasos de 1/60 s: 113,96 + 106 = 219,96.
- F005-AC09 [manual] Elyon mide 99 px visibles y su colisión es de 44 × 106. Pasa todas las animaciones de la F004 (quieto, arrancar, correr, frenar, girar, preparar, subir, caer, aterrizar) con los pies apoyados en el piso, sin flotar ni hundirse, mirando a los dos lados.
- F005-AC10 [manual] `game/data/player_movement.tres` tiene los valores × 2,2 de la tabla de tuning, y el overlay F3 muestra velocidades del orden esperado: unos 297 px/s corriendo.

Sala de prueba:

- F005-AC11 [manual] La sala de prueba de `game/levels/test/` mide 64 × 36 baldosas y tiene la misma forma que la de la F003 al doble: cada baldosa vieja ocupa 2 × 2. Quedan 3 pisos, escalones de 4 baldosas, el precipicio, la entrada y la salida.
- F005-AC12 [manual] En esa sala Elyon sube todos los escalones de 4 baldosas y llega del piso de abajo al de arriba. Al caer al precipicio o salir por un costado vuelve al inicio, como en la F003.

Menús y overlay:

- F005-AC13 [manual] El menú principal, la pausa y las opciones se ven con el mismo tamaño en pantalla que antes de la migración: textos, botones y separaciones al doble, centrados. Se navegan con teclado, gamepad y mouse, y los textos siguen traducidos (es / en).
- F005-AC14 [manual] El overlay de debug (F3) se lee con el mismo tamaño en pantalla que antes y muestra los mismos datos.
- F005-AC15 [manual] Las opciones de la F002 siguen funcionando: pantalla completa, volumen e idioma se aplican y se recuerdan entre sesiones.

Sensación:

- F005-AC16 [feel] El movimiento de Elyon se siente igual que en la F004: mismo peso, mismo ritmo y mismo control.
- F005-AC17 [feel] El juego se ve como el pixel art moderno elegido en el spike 002: parejo, nítido y con movimiento fluido.

## Casos límite

- **Ventana más chica que 1280×720** (escala menor a 1): el shader no puede suavizar hacia abajo. Se dibuja achicado con filtro lineal y puede verse algo borroso. Es aceptable: es un tamaño de ventana raro.
- **Escala entera** (720p, 1440p, 4K): el suavizado no cambia nada visible; se ve igual que con escalado entero.
- **Pantallas más anchas que 16:9** (por ejemplo, 2560×1080): bordes a los costados y escala por el alto (1,5).
- **Al cambiar el tamaño de la ventana**, el valor de escala se actualiza antes del cuadro siguiente.
- **Fuentes**: en `canvas_items` el texto se dibuja a la resolución de la pantalla. Los tamaños de letra se duplican en las escenas para conservar el tamaño en pantalla; no se escala la interfaz por código.

## Parámetros de tuning (Resource)

`PlayerMovementConfig` (`game/data/player_movement.tres` y valores por defecto del script). Solo cambian distancias y velocidades; los tiempos quedan como están.

| Parámetro | Tipo | Valor inicial | Rango sugerido |
|---|---|---|---|
| `run_speed` | float (px/s) | 297 (135 × 2,2) | 220–380 |
| `jump_height` | float (px) | 114 (52 × 2,2, redondeado para que cuerpo + salto ≤ 220) | 90–114 |
| `min_jump_height` | float (px) | 66 (30 × 2,2) | 40–90 |
| `max_fall_speed` | float (px/s) | 1320 (600 × 2,2) | 900–1800 |
| `hard_landing_height` | float (px) | 220 (100 × 2,2) | 150–300 |
| Resto (`accel_time`, `decel_time`, `turn_time`, `time_to_apex`, `fall_gravity_scale`, `jump_prep_time`, `air_control`, `land_recovery_time`, `coyote_time`, `jump_buffer_time`) | float | sin cambios | — |

Las medidas de sala (baldosa, columnas, filas) son constantes de `RoomGeometry` y no son tuning: cambian solo con una decisión nueva.

## Preguntas abiertas

Ninguna. El desarrollador autorizó al agente a escribir en `game/data/player_movement.tres` los valores de la tabla de tuning (2026-10-29: "Autorizo y apruebo").
