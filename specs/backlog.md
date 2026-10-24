# Backlog

> Documento vivo. Lo que falta hacer, en orden aproximado de prioridad. Lo descartado no queda acá: va a `discarded.md`.

- Feature 003: salas y transiciones entre salas fijas. Antes, decisión corta sobre la grilla: con 640×360 y tiles de 32 px una pantalla mide 20×11,25 tiles.
- Feature 004: personaje simple (moverse y saltar, sin animaciones) para recorrer salas.
- Feature 005: muerte y checkpoint por sala.
- Antes de la primera publicación: activar el directorio de usuario propio (*Usar directorio de usuario personalizado* con nombre `CW_2D`), así los datos del jugador quedan en `AppData\Roaming\CW_2D\` (Windows) o `~/.local/share/CW_2D/` (Linux) en vez de bajo una carpeta `Godot`. Cambia la ruta de `settings.json`: hacerlo una sola vez, antes de que haya jugadores.
- Más adelante, si hace falta: spike sobre el peso del movimiento (cuánta anticipación y recuperación de animación se banca el control sin sentirse injusto).
