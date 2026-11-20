# Backlog

> Documento vivo. Lo que falta hacer, en orden aproximado de prioridad. Lo descartado no queda acá: va a `discarded.md`.

- Feature: disparo (`gdd/mechanics/disparo.md`, D0006). Acción `shoot` en el input map; elegir el botón del gamepad (X ya es de `dash`). Traer de `cw2d-art` el arte de disparo de pie. Los valores iniciales del `.tres` están en `archive/spikes/003-disparo-de-pie.md` (tabla de tuning).
- Arte (`cw2d-art`): retocar las poses de disparo de pie a 40° arriba y 20° abajo, con la boca del tiro abajo a 42 px sobre los pies, y dibujar las poses de disparar corriendo y en el aire en los tres ángulos (abajo en el aire a 45°).
- Spike: combate contra el primer enemigo, después de la feature de disparo. Vida de Elyon (aguanta varios golpes y se muestra sin HUD) y un racimo fijo en el piso o el techo que lanza proyectiles con cáscara, tiene descarga cercana, explota y encadena explosiones. Responde las preguntas abiertas de `vision.md` sobre la vida y los enemigos. Además:
  - Revisar si disparar corriendo a velocidad completa en automático vuelve el combate frenético.
  - Resolver la muerte hacia atrás en el aire, que hoy se ve mal: pose de impacto (con una pausa corta), pose en el aire mientras el motor mueve el cuerpo con impulso y gravedad, y aterrizaje que termina en el piso. Las poses son de `cw2d-art`; la física, la elección de animación y la detección del aterrizaje son del juego.
- Mapa del nivel 1 (documento en `specs/gdd/levels/`, con plantilla y preguntas guía).
- Más adelante: secuencia tipo cómic animado (viñetas con movimiento) al terminar cada nivel. Falta decidir si lleva texto; hoy la visión dice "sin cinemáticas extensas", así que al llegar hay que proponer el cambio a la visión. Meta a largo plazo: 10–20 niveles (la v1 sigue en 3).
- Antes de la primera publicación: activar el directorio de usuario propio (*Usar directorio de usuario personalizado* con nombre `CW_2D`), así los datos del jugador quedan en `AppData\Roaming\CW_2D\` (Windows) o `~/.local/share/CW_2D/` (Linux) en vez de bajo una carpeta `Godot`. Cambia la ruta de `settings.json`: hacerlo una sola vez, antes de que haya jugadores.
