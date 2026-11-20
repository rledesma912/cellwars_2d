---
id: F012
type: feature
status: draft
superseded_by:
links: { gdd: [G001, G003], decisions: [D0006, D0007], spike: S003 }
updated: 2026-11-20
---

# Playtest: feature 012 (disparo)

> Guía de pasos. Se tilda en el checklist del PR, que es la fuente de verdad: este archivo no lleva casillas.

## Preparación (escena, overlay F3)

- Abrí `game/main.tscn` (F5 en el editor) y apretá **Jugar**. También podés correr directo `game/world/world.tscn`.
- **F3** (o Back en el gamepad) muestra el panel. Las líneas del disparo están bajo "— disparo —": `apunta`, `puede disparar`, `próximo tiro en`, `pose de tiro` y `disparos`. Arriba siguen las de Elyon: `estado`, `velocidad`, `caída`.
- Botones: **J** o **X** disparan (en el gamepad, X). **W/S** o **↑/↓** apuntan arriba o abajo. Saltar: Espacio o K (A en el gamepad).
- Tuning en `game/data/shoot.tres`: cadencia, velocidad y alcance del proyectil, ángulos, tiempo de pose y bocas del arma.

## Checklist [manual]

- F012-AC08:
  - Apretá J, después X, y en el gamepad el botón X; con los tres, mantené apretado → dispara de forma repetida (`disparos` sube unos 7 por segundo).
  - En el gamepad, B no dispara (es `dash`, que todavía no hace nada).
- F012-AC09: quieto, mantené disparar y tocá arriba y abajo →
  - el tiro sale adelante, a 40° arriba y a 20° abajo, y cambia de golpe (`apunta`);
  - con el disparo apretado, apretá una dirección o saltá → arranca en el acto, sin quedar plantado.
- F012-AC10: corré y mantené disparar en los tres ángulos → no frena (`velocidad` sigue en 215).
- F012-AC11: saltá y caé disparando en los tres ángulos →
  - abajo en el aire sale más empinado (45°);
  - el salto llega a la misma altura y la caída dura lo mismo que sin disparar (comparalo con `caída`).
- F012-AC12: mantené disparar mientras te das vuelta, preparás el salto, aterrizás de alto (recuperarse), rodás y morís → no sale ningún tiro (`puede disparar: no`, `estado` muestra la situación).
- F012-AC13:
  - Disparale a una pared, al piso (abajo desde un escalón) y al techo (arriba) → el proyectil desaparece al tocarlos.
  - Disparando al aire libre, desaparece a unas 18 baldosas.
  - Pegate a una pared y disparale → el tiro no aparece del otro lado.
- F012-AC14:
  - Disparando, pausá con Esc → los proyectiles se quedan quietos y siguen al continuar.
  - Disparando, cruzá a otra sala, o morí y volvé a la entrada → los proyectiles de antes desaparecen.
- F012-AC15:
  - De pie, cada tiro muestra la animación de disparo del ángulo; cambiar de ángulo salta a la pose del otro ángulo.
  - Al soltar, la pose sigue unos 0,6 s y vuelve a quieto.
  - Corriendo y en el aire, una línea celeste marca el arma durante el mismo tiempo.
- F012-AC16: recorré las animaciones (quieto, arrancar, correr, frenar, girar, preparar, subir, caer, caída larga, aterrizar, rodar y las dos muertes) → todas son de la hoja Elyon2, se ven como en el spike, con los pies en el piso y sin cuadros que falten o salten.
- F012-AC17: con F3 abierto, disparando → se ven `apunta`, `puede disparar`, `próximo tiro en`, `pose de tiro` y `disparos`, y cambian al jugar.

## Checklist [feel]

<!-- Solo lo marca el desarrollador. -->

- F012-AC18: ¿disparar de pie, corriendo y en el aire se siente como en el spike: ágil y legible, sin que el control del movimiento cambie? Lo mueven `fire_interval` (cadencia), `projectile_speed` y `shot_range` (cuánto y qué tan lejos se ve el tiro), los tres ángulos y `aim_pose_time` (cuánto queda la pose).

## Notas del playtest
