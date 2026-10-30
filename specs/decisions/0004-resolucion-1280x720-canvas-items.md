---
id: D0004
type: decision
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0002, D0003], spike: S002 }
updated: 2026-10-29
---

# 0004: Resolución 1280×720 en `canvas_items` con suavizado por sprite

- Origen: spike 002 (resolución interna y tamaño de Elyon).
- Reemplaza a **D0002** completa (baldosa y sala a 640×360).
- De **D0003** reemplaza solo los tamaños: alto de Elyon, salto, colisión, cuadros y valores en píxeles. El estilo de movimiento híbrido y la regla "el motor manda los tiempos" siguen vigentes.

## Contexto

El desarrollador quiere un pixel art moderno, con Elyon más definido y algo más alto, sin perder los 3 pisos por sala. Juega en monitores de 1920×1080.

A 640×360, Elyon (48 px) más su salto (52 px) llenan justo los 100 px de aire de cada piso. Por eso no entraba un soldado más alto, y "soldado de más de 48 px" quedó en `discarded.md`. El motivo nuevo es la resolución: con más píxeles y la baldosa en 20 px, la baldosa pesa la mitad en proporción y deja aire para un Elyon más alto.

## Opciones consideradas

Resoluciones (vistas en pantalla completa a 1080p, con Elyon dibujado a cada tamaño):

| Opción | Elyon / salto | A 1080p | Resultado |
|---|---|---|---|
| 640×360 (D0002) | 45 / 52 px | ×3 exacto | Recomendada por Godot para pixel art, pero con poca definición para lo que busca el desarrollador |
| 960×540 | 72 / 83 px | ×2 exacto | Punto intermedio; no elegida |
| **1280×720** | **99 / 114 px** | ×1,5 | **Elegida** |

Modo de dibujado:

| Opción | Resultado |
|---|---|
| `viewport` (retro) | Todo a la resolución interna: la luz y el movimiento van en escalones |
| **`canvas_items`** (moderno) | **Elegido**: se dibuja a la resolución de la pantalla, con luz suave y movimiento entre píxeles |

Escalado a 1080p (con 1280×720 queda ×1,5):

| Opción | Resultado |
|---|---|
| Entero | Queda ×1, chico y con un marco negro grande |
| Fraccional nítido | Píxeles dobles y simples alternados |
| Suavizado sobre la imagen terminada | Píxeles parejos, pero obliga a dibujar a la resolución interna (anula `canvas_items`) |
| **Suavizado por sprite** (*sharp bilinear* en cada sprite y baldosa, en `canvas_items`) | **Elegido**: "se ven parejos", luz "suave", movimiento "fluido" |

## Decisión

- **Resolución interna de 1280×720**, aspecto 16:9 fijo (`keep`), ventana inicial de 1280×720.
- **Modo `canvas_items` con escalado fraccional**: la escena se dibuja a la resolución de la pantalla.
- **Suavizado *sharp bilinear* en todo el pixel art**: un material compartido con el shader de `prototypes/spike_002/sharp_sprite.gdshader`, filtro lineal en esos nodos y un valor de escala global (píxeles de pantalla por píxel del arte) que se recalcula al cambiar el tamaño de la ventana. Ningún sprite ni baldosa de pixel art se dibuja sin él.
- **`snap_2d_transforms_to_pixel` en `false`**: el movimiento suave entre píxeles es parte del look elegido.
- **Baldosa de 20 px; sala de 64 × 36 baldosas**, una pantalla. Con 3 pisos, cada uno mide 12 baldosas (240 px: 20 de baldosa y 220 de aire).
- **Elyon escalado ×2,2 respecto de D0003**:
  - 99 px de alto visible;
  - colisión de 44 × 106 px;
  - cuadros de 144 × 144 px con los pies en (72, 143), mirando a la derecha.
- **Movimiento**: los valores de D0003 se multiplican por 2,2 en distancias y velocidades (velocidad al correr, alturas de salto, velocidad máxima de caída, altura de caída dura) y los tiempos no cambian. El salto máximo pasa de 52 a unos 114 px.
- **Salas**: escalones de hasta 4 baldosas (80 px).

## Consecuencias (qué se actualiza: GDD, architecture.md, specs)

- `specs/architecture.md`:
  - "Render y resolución": viewport 1280×720, `canvas_items`, aspecto `keep`, escalado fraccional, `snap_2d_transforms_to_pixel` en `false`, baldosa de 20 px y sala de 64 × 36 (D0004);
  - regla nueva: todo el pixel art usa el material de suavizado compartido; la escala global se actualiza con la ventana; no escalar ni rotar sprites de pixel art en el juego;
  - "Personaje y movimiento": Elyon de 99 px, colisión de 44 × 106, cuadros de 144 × 144 con pies en (72, 143).
- `CLAUDE.md` (tabla Stack): fila "Tile / resolución" → 20 px, sala de 64 × 36 · viewport 1280×720, stretch `canvas_items` fraccional con *sharp bilinear* por sprite · soldado de 99 px (D0004).
- `specs/decisions/0002-baldosas-de-20-px.md` → `superseded`, `superseded_by: D0004`, a `specs/archive/decisions/`.
- `specs/decisions/0003-movimiento-hibrido-soldado-48px.md` sigue `approved`: su estilo de movimiento sigue vigente. Los documentos vivos toman los tamaños de D0004.
- `specs/backlog.md`:
  - nueva feature, **antes de la F005**: "Migración a 1280×720". Abarca:
    - configuración de render;
    - material de suavizado;
    - Elyon de 99 px con imágenes provisorias en `game/art/elyon/`;
    - colisión;
    - valores por defecto de `PlayerMovementConfig` y sus tests;
    - sala de prueba de `game/levels/test/` a 64 × 36;
    - menús, opciones y overlay de debug reacomodados;
  - en la F005: escalones de hasta 4 baldosas (hoy dice 2).
- `game/data/player_movement.tres`: el agente no lo edita. En la feature de migración se proponen los valores ×2,2 y el desarrollador los aplica o autoriza el cambio.
- `specs/discarded.md`:
  - 640×360 en `viewport`: poca definición para el pixel art moderno buscado;
  - 960×540: no elegida frente a 1280×720;
  - escalado entero con 1280×720: queda ×1 con marco negro en 1080p;
  - escalado fraccional nítido: píxeles desparejos;
  - suavizado sobre la imagen terminada: obliga a dibujar a la resolución interna, sin luz ni movimiento suaves.
- La línea de `discarded.md` "Soldado de más de 48 px" queda como registro: se reabrió con el motivo nuevo de la resolución (ver Contexto).
- `specs/gdd/world.md` (G002, mergeado como borrador en el PR #16): pasa a `approved` y se suma al índice en el PR de cierre del spike.
