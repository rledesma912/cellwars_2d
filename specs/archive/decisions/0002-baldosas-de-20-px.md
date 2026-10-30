---
id: D0002
type: decision
status: superseded
superseded_by: D0004
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-29
---

# 0002: Baldosas de 20 px y salas de 32 × 18

- Origen: feature 003 (antes de su spec). Elegida por el desarrollador en la conversación del 2026-10-24 ("Opción C"). Aprobada el mismo día ("Apruebo la D0002").

## Contexto

El juego se dibuja en una pantalla interna de 640×360 que se agranda en múltiplos enteros (×2 a 720p, ×3 a 1080p, ×4 a 1440p). Cada sala ocupa exactamente una pantalla (G001: pantallas fijas, sin scroll).

Con la baldosa prevista de 32 px, el alto no entra justo: 360 ÷ 32 = 11,25 filas. Además el desarrollador quiere salas de dos y tres **pisos** (plataformas a distintas alturas, como en Prince of Persia y Flashback), así que conviene que el alto se reparta en partes iguales: 3 pisos de 120 px o 2 pisos de 180 px.

## Opciones consideradas

| Baldosa | Sala | 3 pisos | 2 pisos |
|---|---|---|---|
| 32 px | 20 × 11 (sobran 8 px) | 4 + 4 + 3 filas, desparejo | 5,5 filas, no entra |
| 40 px | 16 × 9 | 3 filas cada uno | 4,5 filas, no entra |
| **20 px** | **32 × 18** | **6 filas cada uno** | **9 filas cada uno** |

Cambiar la resolución interna para salvar los 32 px (p. ej. 640×384) se descartó: rompe la escala entera a 1080p.

## Decisión

- Baldosa de **20 × 20 px**. Una sala mide **32 × 18 baldosas** y llena la pantalla de 640×360 sin sobrantes.
- Guía de diseño (no regla): una sala de 3 pisos usa 6 filas por piso (1 de piso + 5 de aire = 100 px de alto libre); una de 2 pisos, 9 filas por piso.
- El personaje greybox mide aproximadamente 2 × 3 baldosas (40 × 60 px); su tamaño final lo fija su spec.
- La resolución interna 640×360 no cambia.

## Consecuencias (qué se actualiza: GDD, architecture.md, specs)

- `CLAUDE.md` (tabla Stack) y `specs/architecture.md` (tabla de render): tile 20 px, sala 32 × 18.
- `specs/backlog.md`: se quita la nota de la grilla de la feature de salas.
- El arte puede dibujarse en bloques de 40 × 40 (2 × 2 baldosas) donde convenga; la grilla de colisión sigue siendo de 20 px.
