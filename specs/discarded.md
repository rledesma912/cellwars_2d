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
| 2026-11-04 | Reiniciar la altura de una caída al cambiar de sala | No queda lógico: una caída que cruza de sala sigue siendo una sola caída | `features/010-caida-mortal/spec.md` |
| 2026-11-20 | Gatillo tiro a tiro (un disparo por apretón) | El desarrollador eligió automático | `archive/spikes/003-disparo-de-pie.md`, D0006 |
| 2026-11-20 | Gatillo en ráfaga (N tiros por apretón y pausa) | El desarrollador eligió automático | `archive/spikes/003-disparo-de-pie.md`, D0006 |
| 2026-11-20 | Disparo como rayo instantáneo | El desarrollador eligió proyectil visible | `archive/spikes/003-disparo-de-pie.md`, D0006 |
| 2026-11-20 | No poder disparar corriendo (hay que frenar primero) | Elegida al principio con dudas para salas y enemigos reales; reemplazada por seguir corriendo mientras dispara | `archive/spikes/003-disparo-de-pie.md`, D0006 |
| 2026-11-20 | Frenar solo al disparar corriendo, o cortar la carrera en seco | El desarrollador eligió seguir corriendo | `archive/spikes/003-disparo-de-pie.md`, D0006 |
| 2026-11-20 | Correr más lento mientras se dispara (75 % o 50 %) | El desarrollador eligió velocidad completa | `archive/spikes/003-disparo-de-pie.md`, D0006 |
| 2026-11-20 | Ángulo de disparo arriba de 50° o 55° | Probados y no gustaron; queda 40° | `archive/spikes/003-disparo-de-pie.md`, D0006 |
| 2026-11-20 | Ángulo abajo en el aire de 20° o 70° | El desarrollador eligió 45° | `archive/spikes/003-disparo-de-pie.md`, D0006 |
| 2026-11-20 | Frenar la caída mientras se dispara en el aire | El desarrollador eligió que la caída no cambie | `archive/spikes/003-disparo-de-pie.md`, D0006 |
| 2026-11-20 | Quedar plantado un instante después de cada tiro de pie | Con la regla elegida no tenía efecto en lo jugado; hacerlo de verdad cambia el control sin haberlo probado | D0007 |
