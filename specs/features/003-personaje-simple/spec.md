---
id: F003
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0002], spike: }
updated: 2026-10-24
---

# Feature 003: Personaje simple en una sala de prueba

- Origen: GDD `vision.md` § Estructura y núcleo (plataformas en pantallas fijas) / decisión 0002 (baldosas de 20 px)
- Vía: completa (crea un sistema nuevo —el movimiento del personaje— y además toca la partida, una sala y el overlay de debug)

## Objetivo

Al tocar Jugar, en lugar de la pantalla provisoria aparece **una sala de prueba** en greybox (formas grises, sin arte) y **un rectángulo que hace de protagonista**. El rectángulo camina, cae y salta. Con eso se puede recorrer la sala entera: tres pisos conectados por escalones y un hueco en el piso de abajo.

Es el primer paso del camino de menor a mayor: moverse antes que cambiar de sala (F004) o morir (F005).

## Fuera de alcance

- Arte, animaciones y sonido del personaje.
- El "peso" del movimiento: aceleración, frenado, anticipación. El rectángulo arranca y frena en seco. El peso se trabaja más adelante (spike en el backlog).
- Salto variable (más alto si se mantiene apretado), *coyote time* y *jump buffer*.
- Colgarse de bordes, trepar, agacharse, dash.
- Pasar a otra sala (F004) y morir de verdad (F005). Caer por el hueco solo reubica al personaje (ver AC10).
- Cámara: la sala ocupa la pantalla entera y no hay scroll.

## Criterios de aceptación

Lógica pura (`PlayerMotor`, sin nodos):

- F003-AC01 [unit] Caminar: con dirección derecha la velocidad horizontal es `run_speed`; con izquierda, `-run_speed`; sin dirección (o con las dos a la vez), 0. Vale igual en el piso y en el aire.
- F003-AC02 [unit] Gravedad: en el aire la velocidad vertical aumenta `gravity × delta` por paso, sin superar `max_fall_speed`. En el piso no se acumula.
- F003-AC03 [unit] Salto: en el piso y con salto recién apretado, la velocidad vertical pasa a `-jump_velocity`. Simulando pasos de 1/60 s, la altura máxima alcanzada es `jump_height` (tolerancia: 2 px).
- F003-AC04 [unit] Sin salto en el aire: salto apretado fuera del piso no cambia la velocidad vertical (no hay doble salto).
- F003-AC05 [unit] Mantener apretado no repite: si el salto sigue apretado desde antes (no es "recién apretado"), al tocar el piso no salta de nuevo.
- F003-AC06 [unit] Valores derivados: a partir de `jump_height` y `time_to_apex`, `gravity = 2·h / t²` y `jump_velocity = 2·h / t`.

Jugando:

- F003-AC07 [manual] Al tocar Jugar aparece la sala de prueba llenando la pantalla: 32 × 18 baldosas de 20 px, sin franjas ni baldosas cortadas. Tiene 3 pisos, escalones entre pisos, paredes a los costados y un hueco en el piso de abajo.
- F003-AC08 [manual] El rectángulo (40 × 60 px, 2 × 3 baldosas) aparece parado en el punto de inicio. Camina con A/D, flechas, cruceta y stick izquierdo; salta con Espacio, K o el botón A del gamepad. No atraviesa paredes, pisos ni techos.
- F003-AC09 [manual] Partiendo del piso de abajo se llega al piso de arriba de todo solo caminando y saltando por los escalones.
- F003-AC10 [manual] Al caer por el hueco y salir por debajo de la pantalla, el rectángulo reaparece en el punto de inicio, quieto. Es provisorio: la F005 lo reemplaza por la muerte.
- F003-AC11 [manual] Pausa (Esc / Start) congela al rectángulo, incluso a mitad de un salto; Continuar lo deja seguir desde donde estaba.
- F003-AC12 [manual] F3 (o el botón Select/Back del gamepad) muestra el overlay de debug con velocidad, si está en el piso y FPS; F3 de nuevo lo oculta. Los valores cambian al moverse.
- F003-AC13 [manual] Cambiar `jump_height` en `game/data/player_movement.tres` desde el inspector cambia la altura del salto en la siguiente partida.

## Casos límite

- Chocar contra un techo a mitad de salto: el rectángulo empieza a caer en ese momento, no queda pegado.
- Saltar pegado a una pared y apretando contra ella: sube igual, no se traba.
- Caer desde el piso de arriba hasta el de abajo: aterriza sin atravesar el piso, aun a velocidad máxima de caída.
- Stick apenas inclinado: por debajo de la zona muerta del gamepad no se mueve.

## Parámetros de tuning (Resource)

`PlayerMovementConfig`, instanciado en `game/data/player_movement.tres` (el agente crea el archivo inicial; después lo ajusta solo el desarrollador).

| Parámetro | Tipo | Valor inicial | Rango sugerido |
|---|---|---|---|
| `run_speed` | float (px/s) | 140 | 80–250 |
| `jump_height` | float (px) | 80 (4 baldosas) | 40–140 |
| `time_to_apex` | float (s) | 0,35 | 0,2–0,6 |
| `max_fall_speed` | float (px/s) | 600 | 300–1000 |

`gravity` y `jump_velocity` no se ajustan a mano: se calculan de `jump_height` y `time_to_apex` (AC06). Así se ajusta "qué tan alto" y "qué tan rápido", que es más fácil de pensar.

Con 80 px de salto, el rectángulo sube escalones de hasta 3 baldosas (60 px) con margen. Pero no sube un piso entero (6 baldosas, 120 px) de un salto, por eso la sala tiene escalones.

## Preguntas abiertas

1. **Permiso para la sala.** La regla 8 dice que el agente no edita `game/levels/` sin pedido explícito. Para esta feature hace falta crear `game/levels/test/test_room.tscn`, la sala de prueba. Propuesta: autorizar al agente a crear y editar **las salas de prueba** (`game/levels/test/`). Las salas de los niveles de verdad siguen siendo tuyas.
2. **Textos del overlay de debug.** La regla dice que todo texto visible va traducido. El overlay es una herramienta de desarrollo que el jugador no ve. Propuesta: sus textos quedan fijos en castellano, sin traducir, como excepción anotada en `architecture.md`.
