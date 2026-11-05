---
id: F011
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-11-04
---

# Playtest: feature 011

> Guía de pasos. Se tilda en el checklist del PR, que es la fuente de verdad: este archivo no lleva casillas.

## Preparación (escena, overlay F3)

Esta feature se prueba **entrando por el menú principal**. `probar_en_laptop.sh` abre la partida directo, sin `Main`: así no aparece el cartel y Elyon sigue de largo fuera de la pantalla.

En la laptop:

1. `~/probar_en_laptop.sh --sin-abrir`, que trae la copia e importa los textos nuevos.
2. `godot --path ~/cw2d_prueba`, que abre el menú principal.

F3 muestra el overlay. Para esta feature, mirá `sala` y `checkpoint`. Sin parámetros de tuning nuevos.

El refugio está en la sala 3: es la salida a la derecha del piso de abajo, marcada con el rectángulo gris verdoso.

## Checklist [manual]

- F011-AC05: Jugá desde la sala 1 hasta la sala 3 y salí por la marca verde → Elyon deja de moverse, la sala queda congelada y aparece "Refugio alcanzado", con "Volver al menú" como único botón.
- F011-AC06: Con el cartel abierto, apretá Esc o Start → no se abre la pausa. Repetí la llegada al refugio y apretá el botón una vez con cada control: teclado, gamepad y mouse → vuelve al menú principal.
- F011-AC07: Desde el menú, elegí Jugar → aparece quieto en la entrada de la sala 1 (overlay: `sala` dice "1 / 3" y `checkpoint` dice "sala 1").
- F011-AC08: En Opciones, cambiá el idioma y llegá al refugio en cada uno → "Refugio alcanzado" y "Volver al menú" en español, "Refuge reached" y "Back to menu" en inglés.
- F011-AC09: Mirá la salida de la sala 3 → se distingue el rectángulo gris verdoso, y Elyon lo atraviesa sin chocar.

## Checklist [feel]

Sin criterios `[feel]` en esta feature.

## Notas del playtest
