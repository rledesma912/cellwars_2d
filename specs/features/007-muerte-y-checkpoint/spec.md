---
id: F007
type: feature
status: done
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

- ✅ F007-AC01 [unit] Al morir, el motor entra en el estado nuevo morir desde cualquier otro estado, e ignora dirección y salto hasta que se reinicie.
- ✅ F007-AC02 [unit] Mientras está muerto, en el piso frena con `decel_time`, y en el aire sigue cayendo con la gravedad de caída hasta `max_fall_speed`.
- ✅ F007-AC03 [unit] La muerte dura el tiempo pedido: `death_time` por una zona mortal y `void_restart_time` por el vacío. Al terminar, el motor avisa que ya se puede volver a la entrada.
- ✅ F007-AC04 [unit] Morir estando ya muerto no cambia el tiempo que queda.
- ✅ F007-AC05 [unit] El estado morir muestra la animación `morir`, que dura `death_time`.
- ✅ F007-AC06 [unit] Volver al checkpoint da la sala actual, su entrada y sin conservar el movimiento, también si se había llegado a esa sala volviendo desde la siguiente.

**Jugando**

- Aceptado F007-AC07 [manual] Al tocar una zona mortal en el piso, Elyon se ve caer con `morir`, sin responder a los controles, y después aparece quieto en la entrada de la sala actual (overlay: `estado`, `timer estado`, `sala`).
- Aceptado F007-AC08 [manual] Al tocar una zona mortal en el aire, sigue cayendo muerto hasta el piso y termina igual.
- Aceptado F007-AC09 [manual] Al caer al vacío, pasa la espera y aparece quieto en la entrada de la sala actual. En la sala que sale por abajo, caer por la salida sigue llevando a la sala siguiente.
- Aceptado F007-AC10 [manual] Mientras está muerto, cruzar un borde de la sala no cambia de sala.
- Aceptado F007-AC11 [manual] Pausar durante la muerte la congela y al continuar sigue donde estaba. Volver al menú durante la muerte no da errores.
- Aceptado F007-AC12 [manual] Cada sala de prueba tiene al menos una zona mortal visible en gris rojizo, se puede recorrer sin tocarla y la entrada queda fuera de ella.

**Sensación**

- Aceptado F007-AC13 [feel] Morir se entiende al instante y volver a intentar es rápido: el castigo se siente mínimo.
- Aceptado F007-AC14 [feel] La zona mortal es justa: mata cuando se ve que la tocaste, y no antes.

## Casos límite

- Muere corriendo: frena unos 11 px mientras cae, sin retroceso.
- Muere rodando, girando o preparando un salto: el estado se corta y el salto preparado no sale.
- Toca otra zona mortal mientras está muerto: no pasa nada (AC04).
- Salto apretado durante la muerte: se descarta al reiniciar y no salta al aparecer. Si sigue apretado, hace falta soltarlo y volver a apretar.
- Muere en el aire sobre el vacío: sigue la muerte de la zona mortal; se ve salir de la pantalla y vuelve al terminar `death_time`.
- Vuelve a una sala anterior y muere ahí: reinicia en la entrada de esa sala, no de la que venía.
- Al reiniciar, mira a la derecha, como hoy, sea cual sea el lado de la entrada.

## Parámetros de tuning (Resource)

En `game/data/player_movement.tres`, grupo "Muerte" de `PlayerMovementConfig`: `death_time` y `void_restart_time`. Hasta que se cambien en el inspector, usan el valor por defecto del script y no aparecen escritos en el `.tres`.

## Notas finales

- **Cierre sin casillas tildadas.** El desarrollador no marcó el checklist del PR. Probó en la laptop y confirmó ("Probé corriendo el ícono que me dejaste, confirmado"). Se le avisó que faltaba tildar o aceptar el cierre así, y respondió: "Cerrá F007 y mergeá el #24, dejando el pozo". Por eso AC07 a AC14 figuran como aceptados, no como marcados.
- **AC11 sin prueba confirmada.** La pausa y el volver al menú solo existen entrando por el menú principal. Se le preguntó si los había probado y no hubo respuesta sobre eso; cerró igual. Conviene mirarlo en la próxima prueba.
- **AC13, observación sobre la caída alta.** Probando el pozo, el desarrollador objetó: "cae de una altura que consideramos mortal y cae parado". La caída usa la pose normal y `morir` arranca de pie. Se aceptó dejar el pozo y resolverlo en una feature nueva (ver `specs/backlog.md`), con un pedido de arte de caída larga y muerte por caída.
- **Pozo agregado al final, a pedido.** La sala 1 tiene un pozo de 6 baldosas en el piso de arriba, antes de la salida, y una segunda zona mortal 460 px más abajo. Es un banco de prueba de la caída alta. Lo que mata es la zona, no la altura.
- **Un intento descartado.** El pozo se probó primero en la sala 3 y, con la dirección apretada, Elyon aterrizaba en el piso del medio. En la sala 1, la pared de la derecha lo mantiene dentro.
- **Implementación.** `body_entered` avisa solo al entrar, por eso ninguna entrada de sala puede quedar dentro de una zona. `morir` tampoco se reinicia al terminar: se queda en el último cuadro. `LevelProgress.apply(VOID)` ya no reinicia; la vuelta la da `checkpoint()`.
