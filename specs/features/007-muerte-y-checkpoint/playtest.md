---
id: F007
type: feature
status: draft
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0005], spike: }
updated: 2026-11-04
---

# Playtest: feature 007

> Guía de pasos. Se tilda en el checklist del PR, que es la fuente de verdad: este archivo no lleva casillas.

## Preparación (escena, overlay F3)

- En la laptop: `~/probar_en_laptop.sh`. Abre directo la partida (`world.tscn`).
- La pausa y el menú solo existen entrando por el menú principal. Para AC11: `~/godot --path ~/cw2d_prueba`.
- F3 muestra el overlay. Para esta feature, mirá `estado`, `timer estado` y `sala`.
- Tiempos ajustables en `game/data/player_movement.tres`, grupo "Muerte". Todavía no aparecen escritos en el archivo porque usan el valor por defecto; se cambian desde el inspector.

Las zonas mortales son los rectángulos gris rojizo:

| Sala | Dónde | Cómo se esquiva |
|---|---|---|
| 1 | En el piso de abajo, cerca de la entrada, antes del hueco | Saltando por encima |
| 2 | Colgando sobre el hueco de la salida | Bajando al hueco sin saltar |
| 3 | En el piso del medio, a la derecha del obstáculo | Saltando por encima |

## Checklist [manual]

- F007-AC07: Caminá hacia la zona de la sala 1 → Elyon cae con `morir`, sin responder a los controles, y aparece quieto en la entrada de la sala (overlay: `estado` dice "morir" y `timer estado` baja desde 1,60 hasta 0; `sala` no cambia).
- F007-AC08: En la sala 2, saltá desde el borde del hueco hasta tocar la zona colgante → sigue cayendo muerto y termina igual, en la entrada de esa sala (overlay: `en el piso` dice "no" al morir).
- F007-AC09: En la sala 1, caé por el hueco del piso de abajo → pasa una espera corta y aparece quieto en la entrada (overlay: `timer estado` baja desde 0,40). En la sala 2, caminá hasta caer por el hueco de la salida sin saltar → pasás a la sala 3 (overlay: `sala` dice "3 / 3").
- F007-AC10: Repetí el salto de AC08 → el cuerpo cae por la salida ya muerto, y reaparece en la sala 2 (overlay: `sala` sigue en "2 / 3" todo el tiempo).
- F007-AC11: Entrando por el menú principal, morí en una zona y pausá con Esc a media caída → todo se congela (overlay: `timer estado` no baja). Continuá → sigue donde estaba. Morí otra vez y elegí volver al menú desde la pausa → vuelve sin errores y podés jugar de nuevo.
- F007-AC12: Recorré las tres salas de entrada a salida → en cada una se ve una zona gris rojiza, se puede pasar sin tocarla, y la entrada queda fuera de ella.

## Checklist [feel]

<!-- Solo lo marca el desarrollador. -->

- F007-AC13: ¿Morir se entiende al instante y volver a intentar es rápido, con un castigo que se siente mínimo? (`death_time`, `void_restart_time`)
- F007-AC14: ¿La zona mortal es justa, mata cuando se ve que la tocaste y no antes? (tamaño y lugar de cada zona en su sala; el cuerpo de Elyon mide 34 × 82)

## Notas del playtest
