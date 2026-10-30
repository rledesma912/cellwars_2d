# Ideas descartadas

> Una línea por idea. Sirve para no olvidar qué se evaluó y para que el agente no la vuelva a proponer sin motivo nuevo.
> Regla: antes de proponer una mecánica o enfoque, revisar esta tabla. Si está acá, solo se reabre con un motivo nuevo y explícito.

| Fecha | Idea | Motivo | Referencia |
|---|---|---|---|
| 2026-10-25 | Movimiento "moderno" con control total en el aire (variante A del spike 001) | Responde bien pero se siente liviano: no transmite el peso del soldado | `archive/spikes/001-movimiento-y-peso.md`, D0003 |
| 2026-10-25 | Movimiento cinemático comprometido, arco fijo y giro lento, estilo Prince of Persia (variante B del spike 001) | Mucho peso, pero traba el control | `archive/spikes/001-movimiento-y-peso.md`, D0003 |
| 2026-10-25 | Soldado de 40 px de alto | Le falta definición | `archive/spikes/001-movimiento-y-peso.md`, D0003 |
| 2026-10-25 | Soldado de más de 48 px de alto | Obliga a bajar el salto de 52 px o a pasar a 2 pisos por sala; se mantienen 3 pisos | `archive/spikes/001-movimiento-y-peso.md`, D0003 |
| 2026-10-29 | Resolución 640×360 en modo `viewport` (retro), como base del juego | Poca definición para el pixel art moderno buscado; la luz y el movimiento van en escalones | `archive/spikes/002-resolucion.md`, D0004 |
| 2026-10-29 | Resolución 960×540 | Escala exacto a 1080p, pero no fue la elegida frente a 1280×720 | `archive/spikes/002-resolucion.md`, D0004 |
| 2026-10-29 | Escalado entero con base 1280×720 | En 1080p queda ×1, chico y con un marco negro grande | `archive/spikes/002-resolucion.md`, D0004 |
| 2026-10-29 | Escalado fraccional nítido (sin suavizar) | Unos píxeles quedan dobles y otros simples | `archive/spikes/002-resolucion.md`, D0004 |
| 2026-10-29 | Suavizado *sharp bilinear* sobre la imagen terminada | Obliga a dibujar a la resolución interna: pierde la luz y el movimiento suaves de `canvas_items` | `archive/spikes/002-resolucion.md`, D0004 |
| 2026-10-30 | Entrada y salida de cada sala en lados estrictamente opuestos | Obliga a que todo el nivel sea horizontal o todo vertical: no deja bajar en medio del recorrido. Reemplazada por "lados distintos, salida nunca arriba" (aprobado por el desarrollador) | `features/006-varias-salas/spec.md` |
