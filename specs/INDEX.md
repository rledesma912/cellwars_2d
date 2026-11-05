# Estado del juego

> Documento vivo. Qué puede hacer el jugador hoy. Lo actualiza `close-feature`.
> Una línea por feature cerrada, agrupadas por categoría (movimiento, combate, enemigos, niveles, UI…), con enlace a su spec.

## Interfaz y flujo

- Menú principal (Jugar, Salir), partida provisoria, pausa con Esc/Start (Continuar, Volver al menú); teclado, gamepad y mouse. [F001](features/001-flujo-de-pantallas/spec.md)
- Opciones: pantalla completa, volumen general e idioma (español / inglés); se recuerdan entre sesiones en `settings.json`. Todos los textos del juego están traducidos. [F002](features/002-opciones/spec.md)

## Presentación

- Pixel art moderno a 1280×720: la imagen llena la pantalla a cualquier tamaño 16:9 con los píxeles parejos (suavizado *sharp bilinear*) y movimiento suave. Sala de prueba de 64 × 36 baldosas; menús y panel de debug al mismo tamaño en pantalla. [F005](features/005-migracion-1280x720/spec.md)

## Movimiento

- Sala de prueba greybox de 3 pisos con escaleras, precipicio, entrada y salida. Panel de debug con F3. [F003](features/003-personaje-simple/spec.md)
- Elyon, el soldado (99 px, animado con imágenes provisorias), corre y frena con peso, se da vuelta, se prepara antes de saltar, tiene salto variable, coyote time y jump buffer, corrige poco en el aire sin darse vuelta y se recupera al caer de más de un piso. Todo ajustable en `player_movement.tres`. [F004](features/004-movimiento-del-soldado/spec.md)
- Contra una pared, Elyon se ve quieto en lugar de intentar correr, y puede saltar o darse vuelta como siempre. [F008](features/008-sin-correr-contra-pared/spec.md)
- Animaciones nuevas de Elyon a 77 px, carrera a 215 px/s, y al caer de alto con velocidad rueda sin frenar. [F009](features/009-animaciones-elyon/spec.md)

## Niveles

- Un nivel es una lista ordenada de salas: al salir por la salida se pasa a la siguiente y por la entrada a la anterior, al instante y sin cortar el movimiento; también se baja a la sala de abajo. Nivel de prueba de 3 salas; la salida de la última vuelve por ahora a la sala 1. [F006](features/006-varias-salas/spec.md)
- Elyon puede morir: al tocar una zona mortal cae sin control y vuelve a la entrada de la sala actual, y caer al vacío también mata, con una espera corta. Cada sala es un checkpoint. Las salas de prueba tienen zonas mortales en gris rojizo. [F007](features/007-muerte-y-checkpoint/spec.md)
- La altura mata: un piso se sobrevive y dos no. Desde cierta altura se ve `caer_largo` en el aire, y el golpe muestra `morir_caida`, sin cuadros de pie. Una caída que cruza de sala sigue sumando, y si mata, vuelve a la sala donde empezó. `morir` tiene arte nuevo, que se desploma en el lugar. [F010](features/010-caida-mortal/spec.md)

## En curso

_Nada en curso._
