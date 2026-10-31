---
id: D0005
type: decision
status: draft
superseded_by:
links: { gdd: [], decisions: [D0003, D0004], spike: }
updated: 2026-10-31
---

# 0005: Elyon de 87 px y carrera a 215 px/s

- Origen: arte definitivo de Elyon (repositorio de arte `cw2d-art`) y prueba jugando del 2026-10-31.
- De **D0004** reemplaza solo el alto visible de Elyon, su colisión y la velocidad al correr. La resolución, la baldosa, la sala, el suavizado por sprite, los cuadros de 144 × 144 con los pies en (72, 143), los saltos y las caídas siguen vigentes.
- De **D0003** no cambia nada: el estilo de movimiento híbrido y la regla "el motor manda los tiempos" siguen vigentes.

## Contexto

El arte definitivo de Elyon sale de una referencia de pixel art del personaje dibujada a **87 px** de alto. Llevarla a los 99 px de D0004 obliga a una escala no entera, que deforma el pixel art (D0004 ya pide no escalar sprites). Se eligió ajustar el personaje a su arte y no al revés.

Con Elyon más chico, la velocidad al correr de D0004 (297 px/s) queda rápida en proporción: un soldado de 87 px que representa a una persona de 1,75 m va a unos 6 m/s (22 km/h), casi un sprint. Además, la carrera (6 cuadros a 12 cps) no acompaña esa velocidad: el pie apoyado retrocede 36 px por paso, que a 12 cps son unos 214 px/s, y a 297 px/s el pie patina sobre el piso. El motor no estira la animación `correr` (se reproduce a los cps de `SpriteFrames`), así que velocidad y animación se eligen juntas.

Se probó jugando: una copia local del juego con la carrera nueva y una tecla para alternar entre la vieja y la nueva, y la velocidad cambiada a mano en `player_movement.tres`. El desarrollador eligió la carrera de 87 px a 215 px/s ("Me gusta el resultado. La velocidad de 215 también me gusta").

## Opciones consideradas

Alto de Elyon:

| Opción | Resultado |
|---|---|
| 99 px (D0004) | Obliga a escalar el arte de 87 px por un factor no entero: deforma el pixel art |
| **87 px** | **Elegida**: la escala nativa del arte, sin reescalar |

Velocidad al correr, con la carrera de 6 cuadros:

| Opción | Animación | Resultado |
|---|---|---|
| 297 px/s (D0004) a 12 cps | 0,5 s por ciclo | El pie patina |
| 297 px/s a 17 cps | 0,36 s por ciclo | No patina, pero las piernas van frenéticas |
| **215 px/s a 12 cps** | 0,5 s por ciclo | **Elegida**: trote firme, el pie acompaña al piso |
| 180 px/s a 10 cps | 0,6 s por ciclo | Más pesado y lento |

## Decisión

- **Elyon mide 87 px de alto visible.** Los cuadros siguen en 144 × 144 con los pies en (72, 143).
- **Colisión de 44 × 93 px**: el alto baja en la misma proporción que el personaje (106 × 87/99 ≈ 93) y el ancho se mantiene para no cambiar cómo entra por pasillos y huecos. El desarrollador puede pedir otro ancho al probarlo.
- **Velocidad al correr de 215 px/s**, con la animación `correr` de 6 cuadros a 12 cps.
- **Saltos, caídas y tiempos sin cambios**: dependen de las salas y las baldosas, no del dibujo. Con un Elyon más chico el salto queda proporcionalmente más alto; se revisa jugando.

## Consecuencias (qué se actualiza: GDD, architecture.md, specs)

- `specs/architecture.md`, "Personaje y movimiento": Elyon de 87 px, colisión de 44 × 93 y velocidad al correr de 215 px/s (D0005); el resto de los tamaños sigue en D0004.
- `CLAUDE.md` (tabla Stack): fila "Tile / resolución" → "soldado de 87 px (`D0005`)".
- `specs/decisions/0004-resolucion-1280x720-canvas-items.md` sigue `approved`: solo se reemplazan los valores de arriba. Los documentos vivos los toman de D0005.
- `game/data/player_movement.tres`: el agente no lo edita. El desarrollador pone `run_speed` en 215.
- `game/entities/player/player.tscn`: la colisión pasa a 44 × 93 (con su posición, la mitad del alto sobre los pies).
- `specs/backlog.md`: la línea "reemplazar las imágenes provisorias de Elyon" pasa a decir 87 px. Las animaciones definitivas llegan del repositorio de arte de a una, con su `.json` de origen, a medida que el desarrollador las aprueba.
- Mientras convivan animaciones provisorias de 99 px con definitivas de 87 px, Elyon cambia de tamaño entre ellas. Es transitorio y se resuelve al reemplazar las provisorias.
