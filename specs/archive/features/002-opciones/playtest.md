---
id: F002
type: feature
status: done
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-24
---

# Playtest: feature 002

## Preparación (escena, overlay F3)

- Abrí el proyecto en Godot con la branch `feat/002-opciones` y ejecutá el juego completo con **F5**.
- Abrí abajo el panel **Salida** del editor para ver errores (rojo) y advertencias (amarillo).
- Tené auriculares o parlantes encendidos para el bip de volumen, y un gamepad conectado.
- El archivo de configuración vive en `~/.local/share/godot/app_userdata/Cellwars 2D/settings.json`. Hoy no existe: la primera vez arrancás como un jugador nuevo. Para los casos límite lo vas a borrar o editar a mano.
- No hay overlay F3 ni valores de tuning en esta feature.

## Checklist [manual]

- [ ] F002-AC10: en el menú principal aparecen "Jugar", "Opciones" y "Salir". Apretá "Opciones" → pantalla con título "Opciones", "Pantalla completa", "Volumen" con su porcentaje, "Idioma" y "Volver"; el foco está en "Pantalla completa".
- [ ] F002-AC11: activá "Pantalla completa" → el juego pasa a pantalla completa en el momento. Desactivala → vuelve a ventana.
- [ ] F002-AC12: mové la barra de volumen → suena un bip al volumen elegido (más bajo cuanto menor el porcentaje). En 0 % no se escucha nada.
- [ ] F002-AC13: elegí "English" → todos los textos de la pantalla de opciones cambian a inglés en el momento. Volvé al menú y entrá a jugar y pausá → el menú principal y el de pausa también están en inglés. Volvé a "Español" y comprobá lo mismo.
- [ ] F002-AC14: en Opciones, probá volver con el botón "Volver", con Esc y con el botón B del gamepad → en los tres casos aparece el menú principal con el foco en "Opciones".
- [ ] F002-AC15: dejá pantalla completa activada, volumen en 30 % e idioma English. Cerrá el juego y volvé a abrirlo con F5 → arranca en pantalla completa, en inglés, y en Opciones el volumen marca 30 %.
- [ ] F002-AC16: cerrá el juego, borrá `settings.json` y volvé a abrirlo → arranca en ventana y en español (el idioma de tu compu).
- [ ] F002-AC17: en Opciones, movete con flechas, pad direccional y stick; con el foco en la barra de volumen, izquierda/derecha la mueven de a 10 %; probá también todo con el mouse.

Casos límite (de la spec):

- [ ] Editá `settings.json` a mano y escribí basura (por ejemplo `hola {{{`) → el juego arranca sin errores, en ventana, volumen 100 % y español.
- [ ] Poné el volumen en 0 %, cerrá y volvé a abrir → sigue en silencio (en Opciones marca 0 %).
- [ ] Entrá y salí de Opciones varias veces seguidas → el foco siempre queda donde corresponde y no hay errores en Salida.
- [ ] Recorré todo el juego en inglés → no aparece ninguna etiqueta sin traducir (por ejemplo `MENU_PLAY`).

## Checklist [feel]

No hay criterios `[feel]` en esta feature.

## Notas del playtest
