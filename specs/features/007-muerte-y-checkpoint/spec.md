---
id: F007
type: feature
status: draft
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0005], spike: }
updated: 2026-11-04
---

# Feature 007: Muerte y checkpoint por sala

- Origen: GDD `vision.md`, pilar "Mortalidad alta, checkpoints frecuentes"; backlog.
- Vía: completa (toca motor, animación, partida y salas, y tiene criterios `[feel]`)

## Objetivo

Hoy nada mata a Elyon: caer al vacío lo devuelve al instante a la entrada de la sala, y no hay nada más que sea mortal. Esta feature crea la muerte. Al tocar una zona mortal, Elyon pierde el control, cae con la animación `morir` y vuelve a la entrada de la sala. Caer al vacío también es morir, con una espera corta porque Elyon ya está fuera de la pantalla.

Cada sala es un checkpoint: siempre se vuelve a la entrada de la sala actual, sin repetir salas anteriores.

## Fuera de alcance

- Enemigos, trampas con movimiento, daño, vida y disparos. Una zona mortal es solo un rectángulo fijo que mata al tocarlo.
- Muertes distintas según la causa, incluida la que hace volar el cuerpo hacia atrás.
- Sonido, fundidos de pantalla y contador de muertes.
- Refugio: la salida de la última sala sigue volviendo a la sala 1, y eso no cuenta como morir.
- Decidir si Elyon aguanta varios golpes. Esa pregunta del GDD sigue abierta para los enemigos.

## Criterios de aceptación

**Regla de morir**

- F007-AC01 [unit] Al morir, el motor entra en el estado nuevo morir desde cualquier otro estado, e ignora dirección y salto hasta que se reinicie.
- F007-AC02 [unit] Mientras está muerto, en el piso frena con `decel_time`, y en el aire sigue cayendo con la gravedad de caída hasta `max_fall_speed`.
- F007-AC03 [unit] La muerte dura el tiempo pedido: `death_time` por una zona mortal y `void_restart_time` por el vacío. Al terminar, el motor avisa que ya se puede volver a la entrada.
- F007-AC04 [unit] Morir estando ya muerto no cambia el tiempo que queda.
- F007-AC05 [unit] El estado morir muestra la animación `morir`, que dura `death_time`.
- F007-AC06 [unit] Volver al checkpoint da la sala actual, su entrada y sin conservar el movimiento, también si se había llegado a esa sala volviendo desde la siguiente.

**Jugando**

- F007-AC07 [manual] Al tocar una zona mortal en el piso, Elyon se ve caer con `morir`, sin responder a los controles, y después aparece quieto en la entrada de la sala actual (overlay: `estado`, `timer estado`, `sala`).
- F007-AC08 [manual] Al tocar una zona mortal en el aire, sigue cayendo muerto hasta el piso y termina igual.
- F007-AC09 [manual] Al caer al vacío, pasa la espera y aparece quieto en la entrada de la sala actual. En la sala que sale por abajo, caer por la salida sigue llevando a la sala siguiente.
- F007-AC10 [manual] Mientras está muerto, cruzar un borde de la sala no cambia de sala.
- F007-AC11 [manual] Pausar durante la muerte la congela y al continuar sigue donde estaba. Volver al menú durante la muerte no da errores.
- F007-AC12 [manual] Cada sala de prueba tiene al menos una zona mortal visible en gris rojizo, se puede recorrer sin tocarla y la entrada queda fuera de ella.

**Sensación**

- F007-AC13 [feel] Morir se entiende al instante y volver a intentar es rápido: el castigo se siente mínimo.
- F007-AC14 [feel] La zona mortal es justa: mata cuando se ve que la tocaste, y no antes.

## Casos límite

- Muere corriendo: frena unos 13 px mientras cae, sin retroceso.
- Muere rodando, girando o preparando un salto: el estado se corta y el salto preparado no sale.
- Toca otra zona mortal mientras está muerto: no pasa nada (AC04).
- Salto apretado durante la muerte: se descarta al reiniciar y no salta al aparecer. Si sigue apretado, hace falta soltarlo y volver a apretar.
- Muere en el aire sobre el vacío: sigue la muerte de la zona mortal; se ve salir de la pantalla y vuelve al terminar `death_time`.
- Vuelve a una sala anterior y muere ahí: reinicia en la entrada de esa sala, no de la que venía.
- Al reiniciar, mira a la derecha, como hoy, sea cual sea el lado de la entrada.

## Parámetros de tuning (Resource)

Se agregan a `PlayerMovementConfig`, como valores por defecto del script, sin tocar `game/data/player_movement.tres`.

| Parámetro | Tipo | Valor inicial | Rango sugerido |
|---|---|---|---|
| `death_time` | float (s) | 1,6 | 0,5 – 3,0 |
| `void_restart_time` | float (s) | 0,4 | 0,0 – 1,5 |

## Preguntas abiertas

- ¿Se incluye la zona mortal? Sin algo que mate en pantalla, la animación `morir` nunca se vería, porque el vacío mata fuera de cuadro. Recomendación: sí, en gris rojizo y solo en las salas de prueba.
- ¿Qué animación se usa? Recomendación: la que cae hacia adelante, de 9 cuadros, porque no mueve al personaje. La que vuela hacia atrás necesita retroceso de 80 px y conviene dejarla para golpes de enemigos.
- ¿Caer al vacío espera 0,4 s o sigue siendo instantáneo? Recomendación: 0,4 s, para que se note que moriste. Con `void_restart_time` en 0 queda como hoy.
