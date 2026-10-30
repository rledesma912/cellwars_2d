---
id: F006
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0004], spike: }
updated: 2026-10-30
---

# Playtest: feature 006

> Guía de pasos. Se tilda en el checklist del PR, que es la fuente de verdad: este archivo no lleva casillas.

## Preparación (escena, overlay F3)

- Abrí el juego completo: `game/main.tscn`, con **F5** en el editor, y tocá **Jugar**.
- **F3** abre el overlay de debug. Mirá sobre todo:
  - **"sala"**: en qué sala estás, por ejemplo "sala: 2 / 3";
  - **"FPS"**;
  - **"velocidad"**, **"estado"** y **"mira"**, para ver que el movimiento sigue igual al cruzar.
- El recorrido del nivel de prueba:
  - **sala 1**: entrás abajo a la izquierda; salís por la derecha en el piso de arriba;
  - **sala 2**: entrás arriba a la izquierda; bajás dos pisos y salís cayendo por el hueco del piso de abajo, a la derecha;
  - **sala 3**: entrás cayendo desde arriba; bajás dos pisos y salís por la derecha en el piso de abajo. Tiene un precipicio en el piso de abajo, a la izquierda del centro.
- Las salas están en `game/levels/test/` (`test_room_1.tscn`, `test_room_2.tscn`, `test_room_3.tscn`) y el nivel en `game/levels/test/test_level.tres`.

## Checklist [manual]

- F006-AC07: Jugar → aparece la sala 1 con Elyon en su entrada, abajo a la izquierda. Recorré las tres salas → cada una tiene 3 pisos y escalones de 4 baldosas que Elyon sube; la sala 1 sale por la derecha, la 2 por abajo y la 3 por la derecha. (overlay: "sala")
- F006-AC08: en la sala 1, corré por el piso de arriba y salí por la derecha corriendo; repetí saltando → la pantalla cambia a la sala 2 al instante. Elyon aparece a la izquierda, sigue corriendo o en el mismo salto y mira a la derecha. (overlay: "sala: 2 / 3", "velocidad", "estado", "mira")
- F006-AC09: desde la sala 2, volvé por la izquierda → llegás a la sala 1, del lado de su salida, mirando a la izquierda. Andá y volvé varias veces seguidas, también parándote justo en el borde → cada cruce cambia de sala sin trabarse. (overlay: "sala")
- F006-AC10: en la sala 2, caé por el hueco del piso de abajo → Elyon aparece cayendo desde arriba en la sala 3 y aterriza en el primer piso. En la sala 3 caé al precipicio, y en la sala 1 también → vuelve quieto a la entrada de esa misma sala. (overlay: "sala" no cambia en el precipicio)
- F006-AC11: mirá el FPS mientras cruzás, la primera vez y las siguientes, en las dos direcciones y por abajo → no baja al cruzar. (overlay: "FPS")
- F006-AC12: cruzá de sala en sala → la línea "sala" cambia en cada cruce: 1 / 3, 2 / 3, 3 / 3. Al salir por la derecha de la sala 3, vuelve a "1 / 3" con Elyon quieto en la entrada (provisorio hasta el refugio). (overlay: "sala")
- F006-AC13: pausá (Esc) en cada una de las tres salas, también justo al cruzar → la pausa congela todo y al seguir continúa bien. Desde la pausa volvé al menú y tocá Jugar → empieza otra vez en la sala 1. (overlay: "sala: 1 / 3")

## Checklist [feel]

<!-- Solo lo marca el desarrollador. -->

- F006-AC14: ¿pasar de una sala a otra se siente continuo, como el cambio de pantalla de *Flashback* o *Prince of Persia*, sin cortar el ritmo de la carrera ni del salto? Esto no se ajusta con un `.tres`: depende de dónde están los marcadores `Entrance`/`Exit` de cada sala y de que las aberturas estén alineadas. El movimiento en sí se ajusta en `game/data/player_movement.tres`.

## Notas del playtest
