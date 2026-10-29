---
id: S002
type: spike
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0002, D0003], spike: }
updated: 2026-10-29
---

# Spike 002: Resolución interna y tamaño de Elyon

- Branch: `spike/002-resolucion`
- Tipo: técnico
- Origen: pedido del desarrollador (pixel art moderno, más definición) · pendiente del Spike 001 ("48 px puede quedarse corto de definición; subirlo implicaría cambiar la resolución del juego")

## Definición (se aprueba antes de empezar)

- Pregunta: ¿qué resolución interna, con qué forma de agrandar la imagen a 1080p, le da a Elyon más definición y algo más de altura sin perder los 3 pisos por sala?
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
  2. Para la elegida, eligió la forma de agrandar la imagen, o confirmó que la irregularidad de píxeles del escalado no entero es aceptable.
  3. Aprobó las proporciones: alto de Elyon, alto del salto y 3 pisos por sala.
  4. Reportó si el movimiento escalado se siente igual que el de D0003 `[feel]`.
- Alternativas a evaluar (se cambian en vivo, sin reiniciar):

  | Tecla | Resolución | Baldosa | Sala | Aire por piso | Elyon | Salto | A 1080p |
  |---|---|---|---|---|---|---|---|
  | 1 | 640×360 (hoy) | 20 | 32 × 18 | 100 | 48 | 52 | ×3 exacto |
  | 2 | 960×540 | 20 | 48 × 27 | 160 | ~78 | ~82 | ×2 exacto |
  | 3 | 1280×720 | 20 | 64 × 36 | 220 | ~104 | ~114 | ×1,5, no entero |

  Formas de agrandar a 1080p (se prueban sobre todo con la 3):
  - **Entero con bordes**: solo múltiplos enteros. En 1280×720 queda ×1 con un marco negro grande. Sirve de referencia de "píxel perfecto".
  - **Fraccional nítido**: estira a pantalla completa sin suavizar. Algunos píxeles quedan dobles y otros simples.
  - **Fraccional suavizado** (tipo *sharp bilinear*): agranda primero con múltiplos enteros y después achica suavizando hasta la pantalla. Los píxeles quedan parejos, con un borde apenas blando.
- Destino del código: descartar. Lo que se traslada son los números (resolución, tamaños, factor de los valores de movimiento) y la forma de escalado elegida.
