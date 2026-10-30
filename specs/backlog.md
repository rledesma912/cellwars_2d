# Backlog

> Documento vivo. Lo que falta hacer, en orden aproximado de prioridad. Lo descartado no queda acá: va a `discarded.md`.

- Feature 006: varias salas y el paso entre ellas (el personaje sale por un borde y aparece en la sala vecina). Enfoque aprobado: el nivel es una lista ordenada de salas en un Resource (`LevelData`); las salas no conocen a sus vecinas, solo marcan su entrada y su salida; `World` tiene una sola sala cargada, sale por la salida → siguiente, por la entrada → anterior; precarga en segundo plano de la anterior y la siguiente. Cada sala define qué hay bajo su borde inferior: "vacío mortal" o "sala de abajo". Regla: toda sala tiene entrada y salida en lados distintos, y la salida nunca está arriba. Con salto de unos 114 px (D0004), escalones de hasta 4 baldosas.
- Feature 007: muerte y checkpoint por sala (caer al vacío mortal reinicia desde la entrada de la sala).
- Después de la F007: mapa del nivel 1 (documento en `specs/gdd/levels/`, con plantilla y preguntas guía).
- Más adelante: secuencia tipo cómic animado (viñetas con movimiento) al terminar cada nivel. Falta decidir si lleva texto; hoy la visión dice "sin cinemáticas extensas", así que al llegar hay que proponer el cambio a la visión. Meta a largo plazo: 10–20 niveles (la v1 sigue en 3).
- Antes de la primera publicación: reemplazar las imágenes provisorias de Elyon (`game/art/elyon/`) por arte propio con las mismas animaciones, cuadros de 144 × 144 y pies en (72, 143) (D0004).
- Antes de la primera publicación: activar el directorio de usuario propio (*Usar directorio de usuario personalizado* con nombre `CW_2D`), así los datos del jugador quedan en `AppData\Roaming\CW_2D\` (Windows) o `~/.local/share/CW_2D/` (Linux) en vez de bajo una carpeta `Godot`. Cambia la ruta de `settings.json`: hacerlo una sola vez, antes de que haya jugadores.
