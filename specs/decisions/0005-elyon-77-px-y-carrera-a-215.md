---
id: D0005
type: decision
status: approved
superseded_by:
links: { gdd: [], decisions: [D0003, D0004], spike: }
updated: 2026-11-03
---

# 0005: Elyon de 77 px y carrera a 215 px/s

- Origen: arte de Elyon (repositorio de arte `cw2d-art`) y pruebas jugando del 2026-10-31 y del 2026-11-03.
- De **D0004** reemplaza solo el alto visible de Elyon, su colisión y la velocidad al correr. La resolución, la baldosa, la sala, el suavizado por sprite, los cuadros de 144 × 144 con los pies en (72, 143), los saltos y las caídas siguen vigentes.
- De **D0003** no cambia nada: el estilo de movimiento híbrido y la regla "el motor manda los tiempos" siguen vigentes.

## Contexto

El arte de Elyon se fue ajustando: primero se propuso 87 px y el 2026-11-03 el desarrollador bajó la altura a 77 px. Las animaciones actuales están dibujadas a ese tamaño. Llevarlas a los 99 px de D0004 obliga a una escala no entera, que deforma el pixel art (D0004 ya pide no escalar sprites).

La carrera tiene 6 cuadros a 12 cps y el pie de apoyo retrocede 18 px por cuadro, unos 216 px/s. A los 297 px/s de D0004 el pie patina sobre el piso. El motor no estira la animación `correr`, así que velocidad y animación se eligen juntas.

Se probó jugando en una copia local con la carrera nueva y la velocidad cambiada en `player_movement.tres`. El desarrollador eligió 215 px/s ("Me gusta el resultado. La velocidad de 215 también me gusta"). La copia usó además una colisión de 34 × 82.

## Opciones consideradas

Alto de Elyon:

| Opción | Resultado |
|---|---|
| 99 px (D0004) | Obliga a escalar el arte por un factor no entero: deforma el pixel art |
| 87 px | Tamaño propuesto antes; el arte actual ya no está dibujado así |
| **77 px** | **Elegida**: la escala nativa del arte actual, sin reescalar |

Colisión:

| Opción | Resultado |
|---|---|
| 44 × 106 (D0004) | Mucho más grande que el dibujo: choca con aire |
| **34 × 82** | **Elegida**: la de D0004 reducida en proporción (× 77/99), la que se jugó en la copia |

Velocidad al correr, con la carrera de 6 cuadros:

| Opción | Animación | Resultado |
|---|---|---|
| 297 px/s (D0004) a 12 cps | 0,5 s por ciclo | El pie patina |
| 297 px/s a 17 cps | 0,36 s por ciclo | No patina, pero las piernas van frenéticas |
| **215 px/s a 12 cps** | 0,5 s por ciclo | **Elegida**: trote firme, el pie acompaña al piso |
| 180 px/s a 10 cps | 0,6 s por ciclo | Más pesado y lento |

## Decisión

- **Elyon mide 77 px de alto visible.** Los cuadros siguen en 144 × 144 con los pies en (72, 143).
- **Colisión de 34 × 82 px.**
- **Velocidad al correr de 215 px/s**, con la animación `correr` de 6 cuadros a 12 cps.
- **Saltos, caídas y tiempos sin cambios**: dependen de las salas y las baldosas, no del dibujo. Con un Elyon más chico el salto queda proporcionalmente más alto; se revisa jugando.

## Consecuencias (qué se actualiza: GDD, architecture.md, specs)

- `specs/architecture.md`, "Personaje y movimiento": Elyon de 77 px, colisión de 34 × 82 y velocidad al correr de 215 px/s (D0005); el resto de los tamaños sigue en D0004.
- `CLAUDE.md` (tabla Stack): fila "Tile / resolución" → "soldado de 77 px (`D0005`)".
- `specs/decisions/0004-resolucion-1280x720-canvas-items.md` sigue `approved`: solo se reemplazan los valores de arriba. Los documentos vivos los toman de D0005.
- El arte, la colisión de `player.tscn` y `run_speed` en `game/data/player_movement.tres` se aplican en la feature F009.
