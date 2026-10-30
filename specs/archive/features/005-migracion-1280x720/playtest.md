---
id: F005
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0004], spike: S002 }
updated: 2026-10-29
---

# Playtest: feature 005

> La fuente de verdad es el checklist del PR: tildá ahí. Este archivo es la guía de pasos.

## Preparación (escena, overlay F3)

- Abrí el juego completo: `game/main.tscn`, con **F5** en el editor.
- **F3** abre el overlay de debug. Mirá sobre todo dos líneas:
  - **"escala pixel art"**: ×1.00 en ventana de 1280×720, ×1.50 en pantalla completa a 1080p;
  - **"velocidad"**.
- La pantalla completa se cambia en **Opciones → Pantalla completa**.
- Tuning del movimiento: `game/data/player_movement.tres`, con los valores × 2,2 ya cargados.

## Checklist [manual]

- [ ] F005-AC03: Opciones → Pantalla completa, después Jugar → la sala llena toda la pantalla, sin bordes negros. (overlay: "escala pixel art: ×1.50")
- [ ] F005-AC04: en pantalla completa, mirá de cerca a Elyon quieto y las baldosas → píxeles parejos, sin filas o columnas dobles alternadas, como el "suavizado moderno" del spike.
- [ ] F005-AC05: sin pantalla completa, arrastrá un borde de la ventana para agrandarla y achicarla → la imagen mantiene 16:9, con bordes si hace falta, y el pixel art sigue parejo. (overlay: "escala pixel art" cambia al soltar)
- [ ] F005-AC06: en la sala de prueba, recorré todo con la mirada → ni Elyon ni ninguna baldosa se ven con píxeles desparejos. Si ves alguno desparejo, le falta el material.
- [ ] F005-AC09: probá todas las acciones a los dos lados: quedarte quieto, arrancar, correr, frenar, darte vuelta, prepararte, saltar, caer y aterrizar → Elyon (99 px) pasa cada animación con los pies apoyados en el piso, sin flotar ni hundirse. (overlay: "estado", "mira")
- [ ] F005-AC10: corré en línea recta hasta la velocidad máxima → la velocidad ronda los 297 px/s. (overlay: "velocidad")
- [ ] F005-AC11: mirá la sala entera → 3 pisos, escalones de 4 baldosas, el precipicio, la entrada a la izquierda abajo y la salida; la misma forma que en la F003.
- [ ] F005-AC12: subí desde la planta baja hasta el piso de arriba por todos los escalones; después caé al precipicio y salí por un costado → sube cada escalón y, al caer o salir, vuelve al inicio.
- [ ] F005-AC13: recorré el menú principal, la pausa (Esc) y las opciones con teclado, gamepad y mouse, en español y en inglés → textos y botones del mismo tamaño en pantalla que antes, centrados y traducidos.
- [ ] F005-AC14: F3 durante la partida → el overlay se lee del mismo tamaño que antes y muestra los mismos datos, más la línea de escala.
- [ ] F005-AC15: cambiá pantalla completa, volumen e idioma; cerrá el juego y volvé a abrirlo → las tres opciones se aplican y se recuerdan.

## Checklist [feel]

<!-- Solo lo marca el desarrollador. -->

- [ ] F005-AC16: ¿el movimiento de Elyon se siente igual que en la F004, con el mismo peso, ritmo y control? Si algo cambió, lo mueven estas distancias de `player_movement.tres`: `run_speed`, `jump_height`, `min_jump_height`, `max_fall_speed` y `hard_landing_height`. Los tiempos no se tocaron.
- [ ] F005-AC17: ¿el juego se ve como el pixel art moderno elegido en el spike 002, parejo, nítido y con movimiento fluido?

## Notas del playtest
