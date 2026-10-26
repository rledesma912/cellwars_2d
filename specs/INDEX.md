# Estado del juego

> Documento vivo. Qué puede hacer el jugador hoy. Lo actualiza `close-feature`.
> Una línea por feature cerrada, agrupadas por categoría (movimiento, combate, enemigos, niveles, UI…), con enlace a su spec.

## Interfaz y flujo

- Menú principal (Jugar, Salir), partida provisoria, pausa con Esc/Start (Continuar, Volver al menú); teclado, gamepad y mouse. [F001](features/001-flujo-de-pantallas/spec.md)
- Opciones: pantalla completa, volumen general e idioma (español / inglés); se recuerdan entre sesiones en `settings.json`. Todos los textos del juego están traducidos. [F002](features/002-opciones/spec.md)

## Movimiento

- Sala de prueba greybox de 3 pisos con escaleras, precipicio, entrada y salida; salir de la sala devuelve al inicio. Panel de debug con F3. [F003](features/003-personaje-simple/spec.md)
- Elyon, el soldado (48 px, animado con imágenes provisorias), corre y frena con peso, se da vuelta, se prepara antes de saltar, tiene salto variable, coyote time y jump buffer, corrige poco en el aire sin darse vuelta y se recupera al caer de más de un piso. Todo ajustable en `player_movement.tres`. [F004](features/004-movimiento-del-soldado/spec.md)

## En curso

_Nada en curso._
