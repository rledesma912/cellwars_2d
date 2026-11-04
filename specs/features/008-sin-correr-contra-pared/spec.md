---
id: F008
type: feature
status: draft
superseded_by:
links: { gdd: [], decisions: [D0003], spike: }
updated: 2026-11-03
---

# Feature 008: Elyon no corre contra una pared

- Origen: playtest del desarrollador, 2026-11-03. Amplía la regla de animación de F004-AC18.
- Vía: liviana (solo toca el movimiento del soldado, sin criterios `[feel]`)

## Objetivo

Hoy, si Elyon está en el piso y se aprieta la dirección hacia una pared, sigue pasando la animación de arranque como si intentara correr. Medido en una sala de prueba: `arrancar` durante 78 pasos seguidos con velocidad horizontal 0 después de `move_and_slide()` e `is_on_wall()` verdadero. Pasa porque el motor vuelve a acelerar en cada paso y la pared le saca esa velocidad.

Contra una pared, Elyon se ve quieto, mirando hacia ella.

## Fuera de alcance

- Animación propia de choque o de empujar.
- Cambios en la física, en los valores de `player_movement.tres` o en el motor de estados.
- Paredes en el aire: `subir` y `caer` no cambian.

## Criterios de aceptación

- F008-AC01 [unit] Con el motor en correr y bloqueado por una pared, la animación es `quieto`, a cualquier velocidad.
- F008-AC02 [unit] Con el motor en correr y sin bloqueo, la animación sigue la regla de F004-AC18: `arrancar` por debajo del 70 % de `run_speed` y `correr` desde ahí.
- F008-AC03 [unit] El bloqueo solo cambia la animación de correr: frenar, girar, preparar salto, en el aire y recuperarse muestran lo mismo con o sin bloqueo.
- F008-AC04 [manual] En el piso, con la dirección apretada contra una pared, Elyon se ve quieto sin alternar con `arrancar` ni `correr`, a la derecha y a la izquierda.
- F008-AC05 [manual] Al soltar la dirección sigue quieto. Al apretar la dirección contraria se da vuelta y corre, sin demora agregada.
- F008-AC06 [manual] Apretado contra la pared, el salto sale igual que siempre, y en cuanto la pared deja de bloquear, por ejemplo al llegar arriba de un escalón, vuelve a correr.

## Casos límite

- `is_on_wall()` solo es verdadero si el cuerpo intentó moverse contra la pared en ese paso. Si el bloqueo frenara al motor, en el paso siguiente dejaría de detectar la pared y la animación alternaría. Por eso el criterio AC04 pide que no alterne y el motor no se toca.
- Pared del lado contrario a la dirección apretada: no bloquea. Corre con normalidad alejándose de ella.
- Llega a la pared a toda velocidad: pasa de `correr` a `quieto` en el paso del choque.
- Stick del gamepad a medias: cuenta igual que la tecla si la dirección apunta a la pared.

## Parámetros de tuning (Resource)

Ninguno.

## Preguntas abiertas

Ninguna.
