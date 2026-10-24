---
id: F002
type: feature
status: approved
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-24
---

# Feature 002: Opciones (pantalla completa, volumen e idioma)

- Origen: backlog (esqueleto del juego, después de F001)
- Vía: completa (crea un sistema nuevo, la configuración del jugador, y amplía el flujo de pantallas de F001)

## Objetivo

Que el jugador pueda elegir desde el menú principal si juega en pantalla completa o en ventana, a qué volumen y en qué idioma (español o inglés), y que el juego recuerde esa elección la próxima vez que lo abra.

Que la elección se guarde de forma **segura** (un archivo roto, a medio escribir o manipulado nunca rompe el juego ni hace perder la configuración anterior) y **eficiente** (se escribe al disco solo cuando algo cambió de verdad).

Todos los textos del juego pasan a una tabla de traducciones, incluidos los menús que ya existen de F001.

## Fuera de alcance

- Abrir las opciones desde el menú de pausa: se suma cuando haya partida real (F003 en adelante).
- Volúmenes separados de música y efectos: hoy el juego no tiene sonido. Hay un solo volumen general.
- Cambiar teclas o botones (remapeo de controles).
- Elegir resolución o tamaño de ventana, y atajo de teclado para pantalla completa (F11).
- Idiomas además de español e inglés.
- Sonido final del juego: para poder probar el volumen se usa un "bip" de prueba provisorio.

## Criterios de aceptación

Configuración del jugador (lógica pura):

- F002-AC01 [unit] Una configuración nueva tiene pantalla completa desactivada, volumen 100 % y el idioma que corresponde al sistema (ver AC04).
- F002-AC02 [unit] El volumen siempre queda entre 0 y 100: pedir 130 deja 100; pedir −5 deja 0.
- F002-AC03 [unit] Conversión del volumen a la escala de audio de Godot (decibeles): 100 % → 0 dB; 50 % → aproximadamente −6 dB; 0 % → silencio total.
- F002-AC04 [unit] Idioma por defecto según el idioma del sistema: cualquier variante de español (`es`, `es_AR`, `es_ES`…) → español; cualquier variante de inglés → inglés; cualquier otro → inglés.
- F002-AC05 [unit] Cambiar una opción al mismo valor que ya tenía se informa como "sin cambios" (y por lo tanto no se guarda); cambiarla a otro valor se informa como "cambió".

Guardado (lógica pura con acceso a archivos, sin escenas):

- F002-AC06 [unit] Guardar la configuración y volver a leerla devuelve los mismos valores.
- F002-AC07 [unit] Si el archivo no existe, está roto o tiene valores inválidos (volumen "abc", idioma "fr", un tipo de dato inesperado), los valores afectados vuelven a su valor por defecto y el resto se respeta.
- F002-AC08 [unit] El guardado escribe primero un archivo temporal y recién al terminar reemplaza al anterior: después de guardar no queda ningún archivo temporal, y si quedó uno de un guardado interrumpido, se ignora al leer.

Flujo de pantallas (amplía el de F001):

- F002-AC09 [unit] Menú + evento `open_options` → Opciones; Opciones + evento `back` → Menú. En Opciones, los eventos de jugar y pausar se ignoran.

Pantallas (jugando):

- F002-AC10 [manual] El menú principal muestra "Jugar", "Opciones" y "Salir". "Opciones" abre una pantalla con el título "Opciones", una casilla "Pantalla completa", una barra "Volumen" con su porcentaje, un selector "Idioma" (Español / English) y el botón "Volver", con el foco en "Pantalla completa".
- F002-AC11 [manual] Marcar "Pantalla completa" pasa el juego a pantalla completa en el momento; desmarcarla lo vuelve a ventana.
- F002-AC12 [manual] Al mover la barra de volumen suena un bip de prueba al volumen elegido; en 0 % no se escucha nada.
- F002-AC13 [manual] Cambiar el idioma cambia en el momento todos los textos de la pantalla de opciones; al volver, el menú principal y el menú de pausa también están en el idioma elegido.
- F002-AC14 [manual] "Volver", Esc o el botón B del gamepad regresan al menú principal, con el foco en "Opciones".
- F002-AC15 [manual] Cerrar el juego y volver a abrirlo conserva la pantalla completa, el volumen y el idioma elegidos.
- F002-AC16 [manual] Sin archivo de configuración (primera vez), el juego arranca en el idioma de la compu si es español o inglés, y en inglés si es otro.
- F002-AC17 [manual] En la pantalla de opciones se navega con flechas, pad direccional y stick; la barra de volumen se mueve con izquierda/derecha de a 10 %; todo responde también al mouse.

## Casos límite

- Borrar el archivo de configuración y abrir el juego: arranca en ventana, con volumen 100 % y el idioma del sistema, sin errores.
- Archivo de configuración editado a mano con basura: arranca sin errores, con los valores por defecto donde no se entienda.
- Volumen en 0 % y salir del juego: al volver a abrir sigue en silencio (no "vuelve" al 100 %).
- Entrar y salir de Opciones varias veces seguidas: el foco siempre queda donde corresponde y no hay errores en la consola.
- Un texto sin traducción: se ve la etiqueta (p. ej. `MENU_PLAY`) en vez de un hueco, así se detecta en el playtest.

## Parámetros de tuning (Resource)

No aplica: no son valores de juego. El paso de la barra de volumen (10 %) es una constante de la interfaz.

## Dónde y cómo se guarda

- En el archivo `settings.cfg` dentro de la carpeta que Godot reserva para cada juego en la compu del jugador (`user://`). En Linux es `~/.local/share/godot/app_userdata/Cellwars 2D/`.
- Se guarda en el momento en que el jugador cambia una opción, solo si el valor cambió (AC05).
- Seguro: guardado en dos pasos (AC08), y al leer solo se aceptan valores simples y conocidos (verdadero/falso, un número, `es` o `en`); cualquier otra cosa se descarta (AC07).

## Traducciones

- Tabla única `game/i18n/texts.csv` con una etiqueta por texto (`MENU_PLAY`, `OPTIONS_VOLUME`…) y columnas `es` y `en`.
- Los textos de F001 (menú principal, partida provisoria y pausa) pasan a usar etiquetas.

## Preguntas abiertas

Ninguna.
