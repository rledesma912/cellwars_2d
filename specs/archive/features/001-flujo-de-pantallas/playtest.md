---
id: F001
type: feature
status: done
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-23
---

# Playtest: feature 001

## Preparación (escena, overlay F3)

- Abrí el proyecto en Godot con la branch `feat/001-flujo-de-pantallas`.
- Ejecutá el juego completo con **F5** (arranca en `game/main.tscn`).
- Tené a mano un gamepad conectado para los ítems de gamepad.
- Abrí abajo el panel **Salida** (Output) del editor: ahí aparecen los errores en rojo y las advertencias en amarillo.
- No hay overlay F3 ni valores de tuning en esta feature.

## Checklist [manual]

- [ ] F001-AC08: abrí el juego con F5 → aparece "Cellwars 2D" con los botones "Jugar" y "Salir", y "Jugar" tiene el borde blanco del foco.
- [ ] F001-AC09: apretá "Jugar" → aparece "Partida (provisoria)" y el contador "Tiempo" empieza a subir.
- [ ] F001-AC10: en la partida, apretá Esc → aparece el cartel "Pausa" encima de la partida oscurecida, el foco está en "Continuar" y el contador queda quieto. Repetí con Start del gamepad.
- [ ] F001-AC11: en pausa, apretá "Continuar" → el cartel desaparece y el contador sigue desde el mismo número. Repetí cerrando la pausa con Esc y con Start.
- [ ] F001-AC12: en pausa, apretá "Volver al menú" → aparece el menú principal. Apretá "Jugar" → el contador arranca de 0.0.
- [ ] F001-AC13: en el menú principal, apretá "Salir" → el juego se cierra y el panel Salida no muestra errores.
- [ ] F001-AC14: en el menú principal y en el de pausa, movete entre botones con las flechas, con el pad direccional y con el stick; confirmá con Enter, con Espacio y con el botón A; probá también hacer clic con el mouse → todo funciona en los dos menús.
- [ ] F001-AC15: hacé 5 veces seguidas el recorrido menú → Jugar → Esc → Volver al menú → el panel Salida no muestra errores ni advertencias.

Casos límite (de la spec):

- [ ] En el menú principal, apretá Esc o Start → no pasa nada (el juego no se cierra).
- [ ] En la partida, apretá Esc muchas veces rápido → la pausa se abre y se cierra en orden; nunca aparecen dos carteles.
- [ ] Volvé al menú desde la pausa → el menú responde normalmente (no queda congelado).
- [ ] Con el menú abierto, desconectá el gamepad → el teclado sigue funcionando.

## Checklist [feel]

No hay criterios `[feel]` en esta feature.

## Notas del playtest
