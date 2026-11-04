---
id: F009
type: feature
status: draft
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0004, D0005], spike: }
updated: 2026-11-04
---

# Playtest: feature 009

> Guía de pasos. Se tilda en el checklist del PR, que es la fuente de verdad: este archivo no lleva casillas.

## Preparación (escena, overlay F3)

En la laptop corré `~/probar_en_laptop.sh`: trae la copia y abre directo la partida. Activá el panel con F3. Los valores se ajustan en `game/data/player_movement.tres`.

## Checklist [manual]

- F009-AC07: quedate quieto, arrancá, corré, frená, date vuelta, saltá y caé, hacia los dos lados. Caé de un piso corriendo para ver `rodar`, y frenando en el aire para ver `aterrizar` → las 10 animaciones se ven, con los pies en el piso y sin cambios de tamaño (overlay: `estado`).
- F009-AC08: apoyate en paredes, pasá bajo techos y parate en bordes → los pies se apoyan en el piso, y Elyon no choca con aire ni atraviesa nada.
- F009-AC09: recorré las 3 salas de punta a punta, incluido el agujero de 6 baldosas de la sala 1 → se puede llegar a cada salida.

## Checklist [feel]

- F009-AC10: ¿la carrera tiene el peso buscado y los pies no patinan? (`run_speed`, `accel_time`, `decel_time`)
- F009-AC11: ¿rodar se siente como una continuación natural de la caída, sin quitarte el control? (`roll_time`, `roll_min_speed_fraction`, `hard_landing_height`)

## Notas del playtest
