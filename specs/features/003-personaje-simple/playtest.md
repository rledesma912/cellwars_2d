---
id: F003
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0002], spike: }
updated: 2026-10-24
---

# Playtest: feature 003

## Preparación (escena, overlay F3)

- Abrí el proyecto en Godot con la branch `feat/003-personaje-simple` y ejecutá el juego completo con **F5**. Tocá **Jugar**.
- Para AC07 (que la sala llene la pantalla), probá también en una ventana propia, fuera del editor: `godot --path /home/rick/LLM/apps/cellwars_2d`.
- Abrí abajo el panel **Salida** del editor para ver errores (rojo) y advertencias (amarillo).
- Controles: caminar con A/D, flechas, cruceta o stick izquierdo; saltar con Espacio, K o el botón A; pausa con Esc o Start; panel de debug con F3 o Select/Back.
- Tuning: `game/data/player_movement.tres` (doble clic → inspector). Valores actuales: caminar 140 px/s, salto 60 px, 0,35 s hasta arriba, caída máxima 600 px/s.
- Recorrido de la sala: entrada a la izquierda (piso 1) → saltar el precipicio → escalera de dos escalones a la derecha → piso 2 hacia la izquierda → escalera de dos escalones → piso 3 hacia la derecha → salida.

## Checklist [manual]

- [ ] F003-AC07: tocá Jugar → la sala llena la pantalla sin franjas ni baldosas cortadas; se ven 3 pisos, dos escaleras de dos escalones, el precipicio en el piso de abajo, la entrada abierta en la pared izquierda (piso 1) y la salida abierta en la pared derecha (piso 3).
- [ ] F003-AC08: el rectángulo aparece parado junto a la entrada. Caminá y saltá con teclado (A/D, flechas, Espacio, K) y con gamepad (cruceta, stick, botón A) → se mueve y salta con todos; no atraviesa paredes, pisos ni techos. (overlay: `velocidad` x vale 140 o −140 al caminar y 0 quieto)
- [ ] F003-AC09: desde la entrada, llegá a la salida solo caminando y saltando → se puede, sin trucos.
- [ ] F003-AC10: caé por el precipicio → reaparece quieto junto a la entrada. Repetí saliendo por la entrada (caminá a la izquierda al empezar) y por la salida → en los dos casos reaparece junto a la entrada.
- [ ] F003-AC11: pausá (Esc o Start) a mitad de un salto → el rectángulo queda congelado en el aire. Continuar → sigue el salto desde donde estaba.
- [ ] F003-AC12: apretá F3 (o Select/Back) → arriba a la izquierda aparecen FPS, velocidad y "en el piso". Movete y saltá → los valores cambian (al saltar, "en el piso: no" y velocidad y negativa). F3 de nuevo lo oculta; también funciona en pausa.
- [ ] F003-AC13: cerrá el juego, cambiá `jump_height` en `player_movement.tres` (por ejemplo a 40) y volvé a jugar → el salto es más bajo. Después volvé a dejarlo en el valor que prefieras.

Casos límite para mirar mientras jugás:
- [ ] Saltá debajo de un piso → la cabeza llega justo al techo y no rebota.
- [ ] Saltá pegado a una pared apretando contra ella → sube igual, no se traba.
- [ ] Bajá del piso 2 al 1 por el hueco de la derecha → aterriza sin atravesar el piso.

## Checklist [feel]

Esta feature no tiene criterios `[feel]`: el "peso" del movimiento es para el Spike 001. Si algo te llama la atención al jugar, anotalo abajo y lo usamos en el spike.

## Notas del playtest
