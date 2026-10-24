# Backlog

> Documento vivo. Lo que falta hacer, en orden aproximado de prioridad. Lo descartado no queda acá: va a `discarded.md`.

- Feature 004: varias salas y el paso entre ellas (el cuadrado sale por un borde y aparece en la sala vecina). Cada sala define qué hay bajo su borde inferior: "vacío mortal" o "sala de abajo".
- Feature 005: muerte y checkpoint por sala (caer al vacío mortal reinicia desde la entrada de la sala).
- Después de la F005: mapa del nivel 1 (documento en `specs/gdd/levels/`, con plantilla y preguntas guía).
- Más adelante: secuencia tipo cómic animado (viñetas con movimiento) al terminar cada nivel. Falta decidir si lleva texto; hoy la visión dice "sin cinemáticas extensas", así que al llegar hay que proponer el cambio a la visión. Meta a largo plazo: 10–20 niveles (la v1 sigue en 3).
- Antes de la primera publicación: activar el directorio de usuario propio (*Usar directorio de usuario personalizado* con nombre `CW_2D`), así los datos del jugador quedan en `AppData\Roaming\CW_2D\` (Windows) o `~/.local/share/CW_2D/` (Linux) en vez de bajo una carpeta `Godot`. Cambia la ruta de `settings.json`: hacerlo una sola vez, antes de que haya jugadores.
- Más adelante, si hace falta: spike sobre el peso del movimiento (cuánta anticipación y recuperación de animación se banca el control sin sentirse injusto).
