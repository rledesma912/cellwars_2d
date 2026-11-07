---
id: S003
type: spike
status: approved         # draft (definición) → approved (en curso) → done (informe listo) → archivado por close-spike
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0005], spike: }
updated: 2026-11-07
---

# Spike 003: disparo de pie

- Branch: `spike/003-disparo-de-pie`
- Tipo: gameplay
- Origen: GDD `vision.md` § Pilares ("Combate cuerpo a cuerpo y a distancia") y § Preguntas abiertas (arsenal); backlog

## Definición (se aprueba antes de empezar)

- Pregunta: ¿qué forma de disparar de pie (modo de disparo, cadencia, rayo o proyectil, alcance) se siente deliberada y legible para Elyon, en línea con el pilar de "control preciso y deliberado"?
- Motivo: disparar es la mecánica central de combate y todavía no sabemos cómo se siente. Hay varias formas razonables y elegir mal es caro, porque el spike de combate contra el primer enemigo, el diseño de las salas y el arte dependen de esto. La pregunta abierta de `vision.md` sobre el arsenal también se responde (al menos en parte) acá.
- Alcance:
  - Entra: disparar **quieto** (Elyon parado en el piso) en tres ángulos: adelante, 45° arriba y 45° abajo. El ángulo cambia de golpe, sin interpolar: se elige con `move_up` / `move_down` en el momento. Alcance corto. Comparar las alternativas de abajo. Observar qué pasa si se intenta disparar mientras se corre, para decidir la regla (ver alternativas).
  - Para probar hace falta un blanco: en la sala de prueba del prototipo hay **blancos quietos** que reaccionan al impacto (parpadean o desaparecen). No tienen vida, no atacan y no son enemigos: eso queda para el spike de combate.
  - No entra: disparar en el aire, agachado o rodando; munición y arsenal de varias armas; daño y vida; enemigos; sonido; importar el arte final de `cw2d-art` (el prototipo usa greybox: una línea o un rectángulo que marca el ángulo del arma sobre el sprite actual, como pide `CLAUDE.md` hasta pasar el `[feel]`); botón definitivo del input map.
  - Sin límite de tiempo: se cierra cuando se cumplan los criterios de salida y lo decidas vos.
- Criterios de salida:
  1. Jugaste las tres variantes de modo de disparo (tiro a tiro, automático, ráfaga) y elegiste una, o descartaste las tres con un motivo.
  2. Comparaste rayo instantáneo y proyectil visible, y elegiste uno.
  3. Quedaron en un `.tres` valores de cadencia, alcance (y velocidad del proyectil, si gana el proyectil) que te resultan buenos.
  4. Hay una regla elegida para "disparar corriendo".
  5. Quedó anotado lo que reportes del `[feel]` (yo no lo marco como cumplido).
- Alternativas a evaluar:
  - **Modo de disparo**: (a) tiro a tiro, un disparo por cada vez que se aprieta el botón, con una cadencia máxima; (b) automático, dispara mientras el botón está apretado, a cadencia fija; (c) ráfaga, cada vez que se aprieta salen N disparos seguidos y después hay una pausa.
  - **Qué sale del arma**: (a) rayo instantáneo (pega en el mismo cuadro, con un destello corto que muestra la línea; en Godot se resuelve con un `RayCast2D` o una consulta de rayo); (b) proyectil visible que viaja a una velocidad configurable (un `Area2D` que avanza en cada paso de física).
  - **Disparar corriendo**: (a) no se puede: hay que frenar primero; (b) apretar disparar frena a Elyon y dispara al terminar de frenar; (c) disparar interrumpe la carrera en seco y dispara al instante. Se prueban las tres con una opción en el `.tres`.
  - En el prototipo se cambia de variante desde el inspector, editando el `.tres` (`ShootConfig`, solo del prototipo), sin tocar código.
- Detalles del prototipo:
  - Va en `prototypes/spike_003/`, con una escena propia que reusa la escena `Player` actual y una sala de prueba con blancos.
  - El botón de disparo se registra **en tiempo de ejecución** desde el prototipo (`InputMap.add_action`), sin tocar `project.godot`. Como propuesta para probar: `J` / `X` en teclado y el botón izquierdo del frente (X en Xbox) en gamepad.
  - El overlay F3 muestra el modo, el ángulo, la cadencia y el tiempo hasta el próximo disparo.
- Destino del código: descartar (por defecto). Lo que sirve de ese código son los valores del `.tres` y la forma de la lógica pura, que pasan a la spec de la feature.

## Qué se construyó

Todo en `prototypes/spike_003/`, en la branch del spike (no llega a `develop`):

- `spike_003.tscn`: sala de 64 × 36 con piso, un escalón de arranque (para tirar 45° abajo), una repisa alta y cinco blancos quietos que destellan y cuentan impactos: uno bajo en el piso, uno parado, uno flotando, uno sobre la repisa y uno lejos, fuera del alcance.
- `shoot_logic.gd`: lógica pura (`RefCounted`) del gatillo: tiro a tiro, automático y ráfaga, la regla al correr y cuánto queda plantado Elyon después de cada tiro.
- `shoot_config.gd` y `shoot_config.tres`: todos los valores y las tres variantes. Las variantes también se cambian jugando con las teclas 1, 2 y 3.
- `shooter_player.gd`: subclase de `Player` que mete el disparo sin tocar `game/`. Le esconde la dirección y el salto al motor mientras Elyon está plantado.
- `shot_caster.gd` y `projectile.gd`: el rayo instantáneo es una consulta de rayo (`intersect_ray`). El proyectil avanza en cada paso de física y lanza un rayo corto desde donde estaba hasta donde va a estar, así no atraviesa un blanco fino aunque avance 15 px por paso.
- Animaciones `disparar_adelante`, `disparar_arriba` y `disparar_abajo` (impact, recovery y hold) aprobadas en `cw2d-art` (commit `3b32a14`), copiadas en `prototypes/spike_003/art/` a pedido del desarrollador, ya en ejecución. Cada tiro arranca desde el impacto, cambiar de ángulo salta al mismo cuadro del otro ángulo y la pose se sostiene mientras se mantiene apretado el botón o hasta 0,6 s después del último tiro.
- El botón `shoot` (J, X y el botón X del gamepad) se registra al arrancar la escena, sin tocar `project.godot`.

Verificado: consola sin errores al correr la escena, y una prueba por código de las 18 combinaciones (modo × rayo/proyectil × regla al correr) disparó sin errores y pegó en los blancos.

## Evidencia y findings

- **Modo**: el desarrollador eligió **automático** (mantener apretado dispara de forma repetida; el primer tiro sale al apretar).
- **Qué sale del arma**: eligió **proyectil visible**.
- **Disparar corriendo**: eligió **no se puede** (`FORBID`, hay que frenar primero), con una duda explícita: *"me queda duda si al generar pantallas, terreno y enemigos no convenga que dispare mientras corra"*. La regla vale para la feature y se revisa con enemigos y salas reales (ver Riesgos).
- **Valores**: no los cambió. Sobre los de arranque dijo: *"me parecen valores default que me permiten adaptarme mientras pruebo"*. Quedan como valores iniciales, no como valores finales.
- **[feel]**: sobre el prototipo con animaciones dijo *"Está bueno"*. No hubo más comentarios del feel; queda sin cerrar (el agente no lo marca como cumplido).
- **45° abajo**: con el arte real, la boca del arma queda a 23 px del piso. Desde el piso, ese tiro pega casi en los pies; sirve sobre todo desde un escalón o una repisa. El desarrollador no lo comentó.
- **Boca del arma**: medida sobre el cuadro `hold` de cada animación, desde los pies y mirando a la derecha: adelante (35, −54), arriba (18, −62), abajo (32, −23).
- **Botón**: el botón X del gamepad (`JOY_BUTTON_X`, índice 2) también está asignado a `dash`, que hoy está reservado y no hace nada. En el teclado no hay choque: J queda al lado de K (saltar) y L (`dash`).

## Valores de tuning que funcionaron

Valores iniciales del prototipo, aceptados como punto de partida (`prototypes/spike_003/shoot_config.tres`):

| Parámetro | Valor | Nota |
|---|---|---|
| `mode` | AUTO | Elegido |
| `delivery` | PROJECTILE | Elegido |
| `run_rule` | FORBID | Elegido; se revisa en el spike de combate |
| `auto_interval` | 0,14 s | ~7 tiros por segundo |
| `projectile_speed` | 900 px/s | 15 px por paso de física |
| `shot_range` | 360 px | 18 baldosas, un poco más de un cuarto de sala |
| `shot_recovery` | 0,12 s | Elyon queda plantado después de cada tiro |
| `aim_pose_time` | 0,6 s | Sigue apuntando después del último tiro |
| `muzzle_forward` / `_up` / `_down` | (35, −54) / (18, −62) / (32, −23) | Medidas sobre el arte; dependen del dibujo, no son tuning |

## Riesgos y limitaciones

- **`FORBID` puede no alcanzar** cuando haya enemigos que se acercan rápido y salas con terreno real: el desarrollador ya lo dudó. Se revisa en el spike de combate. Si cambia, es una decisión nueva que reemplaza esta parte.
- **Sin enemigos ni daño**: el automático a 7 tiros por segundo se probó contra blancos que no hacen nada. Cuántos tiros hacen falta y si el automático vuelve el combate frenético (la visión pide "lectura del enemigo sobre la ejecución frenética") se ve recién con vida y enemigos.
- **45° abajo desde el piso** casi no sirve con el arte actual: pega cerca de los pies. Depende de que las salas tengan desniveles para usarlo, o de un ajuste del arte.
- **Botón X del gamepad** compartido con `dash`: hay que elegir en la spec.
- **Sin sonido ni fogonazo**: el arte dice que el fogonazo y las vainas son partículas del motor; no se probaron.
- El arte de disparo está en el prototipo, no en `game/art`: la feature tiene que traerlo desde `cw2d-art`.

## Recomendación

Disparo de pie **automático**, con **proyectil visible**, en tres ángulos que cambian de golpe, y **sin disparar corriendo** (hay que frenar). Usar los valores de la tabla como `.tres` inicial de la feature. Mantener la forma del prototipo: lógica pura del gatillo, Resource de configuración y proyectil que avanza con un rayo corto por paso. Dejar anotada la duda sobre disparar corriendo para el spike de combate.

## Siguiente paso

- [x] Decisión D0006 → GDD (mecánica de disparo), arquitectura (acción `shoot`), backlog (feature de disparo y revisión de `FORBID` en el spike de combate)
- [ ] Otro spike: no hace falta para el disparo; el spike de combate ya está en el backlog
- [ ] Descartar la idea: no
