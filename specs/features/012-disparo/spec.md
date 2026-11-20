---
id: F012
type: feature
status: draft           # draft → approved → in-progress → done (as-built)
superseded_by:
links: { gdd: [G001, G003], decisions: [D0006], spike: S003 }
updated: 2026-11-20
---

# Feature 012: disparo

- Origen: GDD `mechanics/disparo.md` / decisión 0006 (spike 003)
- Vía: completa (sistema nuevo, toca a Elyon, el input map, el debug y las salas; tiene `[feel]`)

## Objetivo

Elyon dispara en el juego como se eligió en el spike S003:

- Gatillo **automático**.
- **Proyectil visible** de alcance corto.
- **Tres ángulos** que cambian de golpe.
- Se dispara **de pie, corriendo y en el aire**.

El proyectil se frena contra paredes, pisos y techos. Todavía no hay nada a qué pegarle: los enemigos, el daño y los blancos llegan con el spike de combate.

## Fuera de alcance

- Enemigos, daño, vida y blancos.
- Munición, recalentamiento y otras armas.
- Sonido, fogonazo y vainas.
- Disparar agachado (esa postura no existe todavía).
- Arte nuevo de disparo:
  - el retoque de las poses de pie a 40°/20°;
  - las poses de disparar corriendo y en el aire.

  Son tareas de `cw2d-art`; ver la pregunta 3 sobre qué arte usa esta feature.
- La muerte hacia atrás en el aire (va al spike de combate).
- El botón para abrir prototipos del menú: no se toca.

## Criterios de aceptación

Lógica pura (`game/systems/combat/`):

- F012-AC01 [unit] **Ángulo según el input:**
  - solo arriba → arriba;
  - solo abajo → abajo;
  - los dos juntos o ninguno → adelante.
- F012-AC02 [unit] **Dirección del tiro** (largo 1, `y` negativa es arriba), con 40° arriba, 20° abajo de pie y 45° abajo en el aire:
  - adelante mirando a la derecha → (1, 0);
  - arriba mirando a la izquierda → (−cos 40°, −sin 40°) ≈ (−0,766, −0,643);
  - abajo de pie mirando a la derecha → (cos 20°, sin 20°) ≈ (0,940, 0,342);
  - abajo en el aire mirando a la derecha → (cos 45°, sin 45°) ≈ (0,707, 0,707).
- F012-AC03 [unit] **Automático:** con `fire_interval` = 0,14 s y pasos de 1/60 s, mantener apretado durante 60 pasos da **7 tiros**, en los pasos 0, 9, 18, 27, 36, 45 y 54. El primero sale en el paso del apretón.
- F012-AC04 [unit] **La cadencia tiene tope:** soltar y volver a apretar no dispara más rápido. Si se suelta después del primer tiro y se aprieta de nuevo 3 pasos después, no sale tiro hasta el paso 9.
- F012-AC05 [unit] **Situaciones:**
  - dispara quieto en el piso, corriendo, frenando y en el aire;
  - no dispara girando, preparando el salto, aterrizando, rodando ni muerto;
  - mantener apretado durante una de esas situaciones dispara en el primer paso en que vuelve a poder, si ya pasó el intervalo.
- F012-AC06 [unit] **Boca del arma:** la posición respecto de los pies es la del `.tres` para cada ángulo. Mirando a la izquierda, la x se espeja. Ejemplo, adelante: (33, −52) mirando a la derecha y (−33, −52) mirando a la izquierda.
- F012-AC07 [unit] **Vuelo del proyectil:** a 900 px/s, con alcance de 360 px, avanza 15 px por paso y termina en el paso 24, con 360 px recorridos. En cada paso devuelve el tramo (desde, hasta) que hay que revisar.

En el juego:

- F012-AC08 [manual] **Botones:**
  - `J` o `X` en el teclado, y el botón del gamepad que se elija (pregunta 2), disparan;
  - mantenerlos apretados dispara de forma repetida;
  - la acción `shoot` está en el input map del proyecto.
- F012-AC09 [manual] **De pie:** quieto, dispara en los tres ángulos, y mantener arriba o abajo cambia el ángulo al instante.
- F012-AC10 [manual] **Corriendo:** dispara en los tres ángulos sin frenar. En F3, la velocidad sigue en 215 mientras dispara.
- F012-AC11 [manual] **En el aire:** subiendo y cayendo, dispara en los tres ángulos, con el de abajo más empinado (45°). El salto y la caída no cambian: en F3, la altura y la caída son las mismas con y sin disparar.
- F012-AC12 [manual] **Cuándo no dispara:** girando, preparando el salto, aterrizando, rodando o muerto no sale ningún tiro. El estado se ve en F3.
- F012-AC13 [manual] **Paredes:**
  - el proyectil desaparece al tocar una pared, un piso o un techo, y al llegar a su alcance;
  - pegado a una pared y disparando hacia ella, el tiro no aparece del otro lado.
- F012-AC14 [manual] **Pausa y cambio de sala:**
  - en pausa los proyectiles se quedan quietos y siguen al continuar;
  - al cambiar de sala o al morir y volver a la entrada, los proyectiles de la sala anterior desaparecen.
- F012-AC15 [manual] **Se ve el arma:**
  - de pie, se ve la pose de disparo del ángulo elegido (según la pregunta 3);
  - corriendo y en el aire, una línea marca el arma mientras dispara y hasta 0,6 s después del último tiro.
- F012-AC16 [manual] **Debug:** el overlay F3 muestra hacia dónde apunta, si puede disparar, el tiempo hasta el próximo tiro y cuántos tiros salieron.
- F012-AC17 [feel] Disparar de pie, corriendo y en el aire se siente como en el spike: ágil y legible, sin que el control del movimiento cambie.

## Casos límite

- **Pegado a una pared:** la boca del arma queda 16 px más allá del cuerpo y puede caer dentro de la pared. Por eso el primer tramo se revisa desde el centro de Elyon, a la altura de la boca, hasta la boca. Si ese tramo choca, el tiro no sale del arma (AC13).
- **Dar vuelta mientras dispara:** girar es una situación sin tiro (`turn_time`, hoy 0,08 s). Al terminar de girar, sigue disparando hacia el otro lado.
- **Apretar disparar en el aire justo antes de aterrizar:** en el aterrizaje no dispara. Si se mantiene apretado, vuelve a disparar al quedar de pie.
- **Morir con proyectiles en el aire:** siguen hasta chocar o llegar a su alcance, salvo que Elyon vuelva a la entrada de la sala; en ese caso desaparecen (AC14).
- **Muchos tiros:** con 7 tiros por segundo y 0,4 s de vuelo, hay como mucho 3 proyectiles a la vez.

## Parámetros de tuning (Resource)

`ShootConfig` en `game/data/shoot.tres`, con los valores que funcionaron en el spike S003:

| Parámetro | Tipo | Valor inicial | Rango sugerido |
|---|---|---|---|
| `fire_interval` | float (s) | 0,14 | 0,05 – 0,5 |
| `projectile_speed` | float (px/s) | 900 | 300 – 2000 |
| `shot_range` | float (px) | 360 | 100 – 1280 |
| `aim_up_angle` | float (°) | 40 | 20 – 70 |
| `aim_down_angle` | float (°) | 20 | 10 – 45 |
| `air_aim_down_angle` | float (°) | 45 | 10 – 90 |
| `aim_pose_time` | float (s) | 0,6 | 0 – 2 |
| `muzzle_forward` | Vector2 (px) | (33, −52) | depende del arte |
| `muzzle_up` | Vector2 (px) | (26, −66) | depende del arte |
| `muzzle_down` | Vector2 (px) | (29, −42) | depende del arte |

A 900 px/s el proyectil avanza 15 px por paso. Como revisa todo el tramo de cada paso, no atraviesa una pared de una baldosa (20 px) aunque la velocidad suba.

## Preguntas abiertas

1. **"Plantado un instante" no tuvo efecto en lo que jugaste.** D0006 dice que de pie Elyon queda plantado 0,12 s después de cada tiro, pero con la regla elegida (seguir corriendo mientras dispara) apretar una dirección o saltar lo libera en el acto. En el spike nunca se notó. Opciones:
   - **(a) Recomendada:** no implementarlo, así queda igual a lo que jugaste. Hay que corregir D0006 con una decisión corta, D0007, que reemplace solo ese punto, y actualizar `mechanics/disparo.md`.
   - **(b)** Implementarlo de verdad: después de cada tiro de pie, no puede arrancar a correr ni saltar durante 0,12 s. Es algo que no probaste.
2. **Botón del gamepad para disparar.** Hoy A salta, X tiene `dash` (reservado, no hace nada), Back abre el debug y Start pausa. Opciones:
   - **(a) Recomendada:** disparar con **X**, como en el spike, y mover `dash` a **B**.
   - **(b)** Disparar con **B** y dejar X para `dash`.
   - **(c)** Disparar con un gatillo o un bumper (RT o RB).
3. **Arte de disparo de pie.** Las animaciones de disparo solo existen en la hoja nueva de Elyon (Elyon2) que usó el prototipo, que cambia también todas las otras animaciones. Además, `cw2d-art` la entregó "sin final". Opciones:
   - **(a)** Traer la hoja Elyon2 completa, como se jugó en el spike (guardada en el tag `archive/spike-003`). Cambia el dibujo de todas las animaciones.
   - **(b) Recomendada:** dejar el arte actual y marcar el arma con la línea también de pie, como pide `CLAUDE.md` (greybox hasta pasar el `[feel]`). El arte entra después, en su propia feature, cuando `cw2d-art` publique el final.
