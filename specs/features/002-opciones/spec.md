---
id: F002
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-24
---

# Feature 002: Opciones (pantalla completa y volumen)

- Origen: backlog (esqueleto del juego, después de F001)
- Vía: completa (crea un sistema nuevo, la configuración del jugador, y amplía el flujo de pantallas de F001)

## Objetivo

Que el jugador pueda elegir desde el menú principal si juega en pantalla completa o en ventana, y a qué volumen, y que el juego recuerde esa elección la próxima vez que lo abra.

## Fuera de alcance

- Abrir las opciones desde el menú de pausa: se suma cuando haya partida real (F003 en adelante).
- Volúmenes separados de música y efectos: hoy el juego no tiene sonido. Hay un solo volumen general.
- Cambiar teclas o botones (remapeo de controles).
- Elegir resolución o tamaño de ventana, y atajo de teclado para pantalla completa (F11).
- Idioma.
- Sonido final del juego: para poder probar el volumen se usa un "bip" de prueba provisorio.

## Criterios de aceptación

Configuración del jugador (lógica pura):

- F002-AC01 [unit] Una configuración nueva tiene pantalla completa desactivada y volumen 100 %.
- F002-AC02 [unit] El volumen siempre queda entre 0 y 100: pedir 130 deja 100; pedir −5 deja 0.
- F002-AC03 [unit] Conversión del volumen a la escala de audio de Godot (decibeles): 100 % → 0 dB; 50 % → aproximadamente −6 dB; 0 % → silencio total.
- F002-AC04 [unit] Guardar la configuración y volver a leerla devuelve los mismos valores.
- F002-AC05 [unit] Si el archivo guardado no existe, está roto o tiene un valor inválido (p. ej. volumen "abc"), los valores afectados vuelven a su valor por defecto y el resto se respeta.

Flujo de pantallas (amplía el de F001):

- F002-AC06 [unit] Menú + evento `open_options` → Opciones; Opciones + evento `back` → Menú. En Opciones, los eventos de jugar y pausar se ignoran.

Pantallas (jugando):

- F002-AC07 [manual] El menú principal muestra "Jugar", "Opciones" y "Salir". "Opciones" abre una pantalla con el título "Opciones", una casilla "Pantalla completa", una barra "Volumen" con su porcentaje y el botón "Volver", con el foco en "Pantalla completa".
- F002-AC08 [manual] Marcar "Pantalla completa" pasa el juego a pantalla completa en el momento; desmarcarla lo vuelve a ventana.
- F002-AC09 [manual] Al mover la barra de volumen suena un bip de prueba al volumen elegido; en 0 % no se escucha nada.
- F002-AC10 [manual] "Volver", Esc o el botón B del gamepad regresan al menú principal, con el foco en "Opciones".
- F002-AC11 [manual] Cerrar el juego y volver a abrirlo conserva la pantalla completa y el volumen elegidos.
- F002-AC12 [manual] En la pantalla de opciones se navega con flechas, pad direccional y stick; la barra de volumen se mueve con izquierda/derecha de a 10 %; todo responde también al mouse.

## Casos límite

- Borrar el archivo de configuración y abrir el juego: arranca en ventana y con volumen 100 %, sin errores.
- Archivo de configuración editado a mano con basura: arranca sin errores, con los valores por defecto donde no se entienda.
- Volumen en 0 % y salir del juego: al volver a abrir sigue en silencio (no "vuelve" al 100 %).
- Entrar y salir de Opciones varias veces seguidas: el foco siempre queda donde corresponde y no hay errores en la consola.

## Parámetros de tuning (Resource)

No aplica: no son valores de juego. El paso de la barra de volumen (10 %) es una constante de la interfaz.

## Dónde se guarda

En el archivo `settings.cfg` dentro de la carpeta que Godot reserva para cada juego en la compu del jugador (`user://`). En Linux es `~/.local/share/godot/app_userdata/Cellwars 2D/`. Se guarda cada vez que el jugador cambia una opción.

## Preguntas abiertas

Ninguna.
