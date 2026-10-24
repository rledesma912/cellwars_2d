---
id: F001
type: feature
status: approved
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-23
---

# Feature 001: Menú principal y flujo de pantallas

- Origen: GDD `vision.md` (estructura del juego; primera pieza del esqueleto)
- Issue: #5
- Vía: completa (crea un sistema nuevo: el flujo de pantallas)

## Objetivo

Que el juego tenga su esqueleto de navegación: arranca en un menú principal, desde ahí se entra a una escena de juego (todavía vacía), se puede pausar y volver al menú, y se puede salir del juego. Todo navegable con teclado, gamepad y mouse.

## Fuera de alcance

- Pantalla de opciones (volumen, pantalla completa): F002.
- Contenido de la escena de juego: salas, personaje, enemigos (F003 en adelante). Acá es un placeholder con un texto.
- Transiciones animadas entre pantallas (fundidos). Por ahora, corte seco.
- Pausa automática al perder el foco de la ventana.
- Confirmación al volver al menú o al salir ("¿Seguro?").
- Arte final, fuentes y sonido de la UI: greybox con el tema por defecto de Godot.
- Traducción a otros idiomas: los textos de la UI van en castellano.
- Líneas en el debug overlay (F3): el overlay todavía no existe.

## Criterios de aceptación

Flujo (lógica pura, independiente de las escenas):

- F001-AC01 [unit] El flujo arranca en el estado `MENU`.
- F001-AC02 [unit] `MENU` + evento `play` → `PLAYING`.
- F001-AC03 [unit] `PLAYING` + evento `pause` → `PAUSED`.
- F001-AC04 [unit] `PAUSED` + evento `resume` → `PLAYING`; `PAUSED` + evento `pause` → `PLAYING` (la misma tecla pausa y despausa).
- F001-AC05 [unit] `PAUSED` + evento `to_menu` → `MENU`.
- F001-AC06 [unit] Un evento que no corresponde al estado actual no cambia el estado (p. ej. `MENU` + `pause` → `MENU`; `PLAYING` + `to_menu` → `PLAYING`).
- F001-AC07 [unit] Cada cambio de estado se notifica una sola vez con el estado anterior y el nuevo; un evento ignorado no notifica nada.

Pantallas (jugando):

- F001-AC08 [manual] Al abrir el juego aparece el menú principal con el título "Cellwars 2D" y los botones "Jugar" y "Salir", con el foco en "Jugar".
- F001-AC09 [manual] "Jugar" lleva a la escena de juego, que muestra un texto placeholder.
- F001-AC10 [manual] En la escena de juego, Esc (teclado) o Start (gamepad) abre el menú de pausa encima de la escena, con "Continuar" y "Volver al menú", foco en "Continuar". Mientras está abierto, la escena de juego no avanza.
- F001-AC11 [manual] En pausa, "Continuar" o volver a apretar Esc/Start cierra la pausa y la escena sigue desde donde estaba.
- F001-AC12 [manual] En pausa, "Volver al menú" lleva al menú principal; al volver a "Jugar", la escena de juego empieza de cero.
- F001-AC13 [manual] "Salir" cierra el juego sin errores en la consola.
- F001-AC14 [manual] En los dos menús se navega con flechas y con el pad direccional/stick, se confirma con Enter/Espacio y con el botón A, y los botones también funcionan con clic del mouse.
- F001-AC15 [manual] Recorrer el ciclo menú → jugar → pausa → menú cinco veces seguidas no deja errores ni advertencias en la consola.

## Casos límite

- Esc/Start en el menú principal: no hace nada (no sale del juego).
- Apretar Esc/Start muchas veces rápido: la pausa se abre y cierra de forma consistente, nunca quedan dos menús de pausa abiertos.
- Volver al menú con el juego en pausa: el menú principal no queda congelado (la pausa se levanta al salir de la escena de juego).
- Desconectar el gamepad con el menú abierto: se sigue pudiendo usar el teclado.

## Parámetros de tuning (Resource)

No aplica: la feature no tiene valores de juego ajustables.

## Preguntas abiertas

Ninguna.
