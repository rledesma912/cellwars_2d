# Estado del juego

> Documento vivo. Qué puede hacer el jugador hoy. Lo actualiza `close-feature`.
> Una línea por feature cerrada, agrupadas por categoría (movimiento, combate, enemigos, niveles, UI…), con enlace a su spec.

## Interfaz y flujo

- Menú principal (Jugar, Salir), partida provisoria, pausa con Esc/Start (Continuar, Volver al menú); teclado, gamepad y mouse. [F001](features/001-flujo-de-pantallas/spec.md)
- Opciones: pantalla completa, volumen general e idioma (español / inglés); se recuerdan entre sesiones en `settings.json`. Todos los textos del juego están traducidos. [F002](features/002-opciones/spec.md)

## Movimiento

- Un rectángulo de prueba camina, cae y salta (altura de salto exacta y ajustable) por una sala greybox de 3 pisos con escaleras, precipicio, entrada y salida; salir de la sala lo devuelve al inicio. Panel de debug con F3. [F003](features/003-personaje-simple/spec.md)

## En curso

_Nada en curso._
