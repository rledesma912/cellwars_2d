---
id: S003
type: spike
status: done         # draft (definición) → approved (en curso) → done (informe listo) → archivado por close-spike
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0005, D0006], spike: }
updated: 2026-11-20
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

### Ampliación: disparar corriendo y en el aire (pedida y aprobada por el desarrollador el 2026-11-20)

- Pregunta: ¿se siente bien que Elyon dispare **sin frenar** mientras corre y mientras salta o cae, y con qué reglas?
- Motivo: el desarrollador quiere las dos cosas. Cambia la regla elegida para correr (`FORBID`) y saca "disparar en el aire" de la lista de lo que no entra. Como la decisión del spike todavía no se escribió, se amplía este spike en lugar de abrir otro.
- Entra:
  - **Disparar corriendo**: Elyon sigue corriendo mientras dispara, en los tres ángulos (40° arriba, adelante, 20° abajo). Se suma como cuarta regla al correr (`FIRE_WHILE_RUNNING`), comparable con las otras tres con la tecla 3.
  - **Disparar en el aire**: subiendo y cayendo, en los tres ángulos, sin cambiar el salto.
  - Mientras corre o está en el aire, Elyon no queda plantado después de cada tiro (`shot_recovery` vale solo de pie).
  - Sala de prueba: se suman blancos pensados para tirar en movimiento (un pasillo largo para correr disparando y blancos altos para tirar en el aire).
  - Arte: no hay animaciones de disparar corriendo ni en el aire. Se usan las de `correr`, `subir` y `caer` con una línea encima que marca el arma (greybox).
- Alternativas a evaluar:
  - **Velocidad al disparar corriendo**: (a) velocidad completa; (b) más lento mientras dispara (multiplicador en el `.tres`, se prueba con una tecla).
  - **Ángulo de abajo en el aire**: (a) el mismo 20° que de pie; (b) uno más empinado, solo en el aire (valor en el `.tres`).
  - **Efecto del tiro en el salto**: (a) ninguno; (b) mientras dispara en el aire la caída se frena un poco (multiplicador de gravedad en el `.tres`).
- No entra: disparar agachado o rodando; el arte final de las poses de disparo en movimiento; la muerte hacia atrás en el aire (va al spike de combate); enemigos, daño y sonido.
- Criterios de salida (se suman a los de arriba):
  6. Probaste disparar corriendo y elegiste una regla al correr (incluida volver a `FORBID`) y una velocidad.
  7. Probaste disparar en el aire y elegiste el ángulo de abajo en el aire y si el tiro afecta la caída.
  8. Quedó anotado lo que reportes del `[feel]` de disparar en movimiento.

## Qué se construyó

Todo en `prototypes/spike_003/`, en la branch del spike (no llega a `develop`):

- `spike_003.tscn`: sala de 64 × 36 con piso, un escalón de arranque (para tirar 45° abajo), una repisa alta y cinco blancos quietos que destellan y cuentan impactos: uno bajo en el piso, uno parado, uno flotando, uno sobre la repisa y uno lejos, fuera del alcance.
- `shoot_logic.gd`: lógica pura (`RefCounted`) del gatillo: tiro a tiro, automático y ráfaga, la regla al correr y cuánto queda plantado Elyon después de cada tiro.
- `shoot_config.gd` y `shoot_config.tres`: todos los valores y las tres variantes. Las variantes también se cambian jugando con las teclas 1, 2 y 3.
- `shooter_player.gd`: subclase de `Player` que mete el disparo sin tocar `game/`. Le esconde la dirección y el salto al motor mientras Elyon está plantado.
- `shot_caster.gd` y `projectile.gd`: el rayo instantáneo es una consulta de rayo (`intersect_ray`). El proyectil avanza en cada paso de física y lanza un rayo corto desde donde estaba hasta donde va a estar, así no atraviesa un blanco fino aunque avance 15 px por paso.
- Animaciones `disparar_adelante`, `disparar_arriba` y `disparar_abajo` (impact, recovery y hold) aprobadas en `cw2d-art` (commit `3b32a14`), copiadas en `prototypes/spike_003/art/` a pedido del desarrollador, ya en ejecución. Cada tiro arranca desde el impacto, cambiar de ángulo salta al mismo cuadro del otro ángulo y la pose se sostiene mientras se mantiene apretado el botón o hasta 0,6 s después del último tiro.
- El botón `shoot` (J, X y el botón X del gamepad) se registra al arrancar la escena, sin tocar `project.godot`.
- Ampliación (disparar en movimiento): cuarta regla al correr, `FIRE_WHILE_RUNNING`, y una situación nueva, "en el aire", en la lógica del gatillo. En los dos casos Elyon no queda plantado. Las teclas 4, 5 y 6 cambian la velocidad corriendo al disparar, el ángulo de abajo en el aire y la gravedad al caer disparando. Hay tres blancos más: dos altos y uno bajo y lejos. Como no hay arte de disparo en movimiento, el arma se marca con una línea celeste.
- Acceso temporal desde el menú principal (botón "Prototipo 003", solo en builds de debug), mergeado a `develop` en el PR #32.

Verificado: consola sin errores al correr la escena, y una prueba por código de las 18 combinaciones (modo × rayo/proyectil × regla al correr) disparó sin errores y pegó en los blancos. En la ampliación, otra prueba por código confirmó: con `FORBID` no sale tiro corriendo; con `FIRE_WHILE_RUNNING` dispara a 215 px/s (y a 108 px/s con la velocidad al 50 %); en el aire sale el ángulo pedido; con la gravedad al 25 % el salto dura 57 cuadros en lugar de 38.

## Evidencia y findings

- **Modo**: el desarrollador eligió **automático** (mantener apretado dispara de forma repetida; el primer tiro sale al apretar).
- **Qué sale del arma**: eligió **proyectil visible**.
- **Disparar corriendo**: primero eligió **no se puede** (`FORBID`), con una duda explícita: *"me queda duda si al generar pantallas, terreno y enemigos no convenga que dispare mientras corra"*. Después pidió probar disparar corriendo y en el aire (ampliación). Con eso eligió **seguir corriendo mientras dispara** (`FIRE_WHILE_RUNNING`) **a velocidad completa** (`run_fire_speed` 1,0).
- **Disparar en el aire**: eligió el tiro hacia abajo en el aire a **45°** (de pie sigue en 20°) y que disparar **no cambie la caída** (`air_fire_gravity` 1,0).
- **Ángulos de pie**: probó 50° y 55° y no le gustaron. Quedan **40° arriba** y **20° abajo**. Pidió anotar que hay que retocar el arte de disparo (se dibujó para unos 45°).
- **Boca al tirar abajo de pie**: subirla mejora el tiro; eligió **42 px** sobre los pies (el arte la tiene en 32).
- **Arma en movimiento**: corriendo y en el aire no hay arte de disparo; el prototipo marca el arma con una línea celeste. El desarrollador la notó.
- **Valores**: no los cambió. Sobre los de arranque dijo: *"me parecen valores default que me permiten adaptarme mientras pruebo"*. Quedan como valores iniciales, no como valores finales.
- **[feel]**: sobre el disparo de pie con animaciones dijo *"Está bueno"*. Sobre disparar corriendo y en el aire dijo *"Se siente bien"*. El agente no marca el `[feel]` como cumplido: se vuelve a jugar en la feature.
- **Boca del arma**: medida sobre el cuadro `hold` de cada animación de Elyon2, desde los pies y mirando a la derecha: adelante (33, −52), arriba (26, −66), abajo (29, −32), esta última subida a −42.
- **Botón**: el botón X del gamepad (`JOY_BUTTON_X`, índice 2) también está asignado a `dash`, que hoy está reservado y no hace nada. En el teclado no hay choque: J queda al lado de K (saltar) y L (`dash`).

## Valores de tuning que funcionaron

Valores iniciales del prototipo, aceptados como punto de partida (`prototypes/spike_003/shoot_config.tres`):

| Parámetro | Valor | Nota |
|---|---|---|
| `mode` | AUTO | Elegido |
| `delivery` | PROJECTILE | Elegido |
| `run_rule` | FIRE_WHILE_RUNNING | Elegido en la ampliación |
| `run_fire_speed` | 1,0 | No frena al disparar corriendo |
| `aim_up_angle` / `aim_down_angle` | 40° / 20° | De pie |
| `air_aim_down_angle` | 45° | Abajo en el aire |
| `air_fire_gravity` | 1,0 | Disparar no cambia la caída |
| `auto_interval` | 0,14 s | ~7 tiros por segundo |
| `projectile_speed` | 900 px/s | 15 px por paso de física |
| `shot_range` | 360 px | 18 baldosas, un poco más de un cuarto de sala |
| `shot_recovery` | 0,12 s | Elyon queda plantado después de cada tiro |
| `aim_pose_time` | 0,6 s | Sigue apuntando después del último tiro |
| `muzzle_forward` / `_up` / `_down` | (33, −52) / (26, −66) / (29, −42) | Medidas sobre el arte de Elyon2; abajo subida a 42 px a pedido |

## Riesgos y limitaciones

- **Disparar corriendo a velocidad completa con automático** puede volver el combate frenético (la visión pide "lectura del enemigo sobre la ejecución frenética"). Se probó contra blancos que no hacen nada; cuántos tiros hacen falta y si conviene limitarlo se ve en el spike de combate, con vida y enemigos.
- **Sin arte de disparo en movimiento**: corriendo y en el aire el prototipo usa una línea. La feature necesita poses de disparar corriendo y en el aire (tres ángulos), que se piden a `cw2d-art`.
- **Arte de disparo de pie a retocar**: está dibujado para unos 45° y los ángulos elegidos son 40° arriba y 20° abajo. La boca de abajo quedó a 42 px, más alta que en el dibujo (32 px).
- **Botón X del gamepad** compartido con `dash`: hay que elegir en la spec.
- **Sin sonido ni fogonazo**: el arte dice que el fogonazo y las vainas son partículas del motor; no se probaron.
- El arte de disparo está en el prototipo, no en `game/art`: la feature tiene que traerlo desde `cw2d-art`.
- **Fuera de alcance, anotado**: la muerte hacia atrás en el aire se ve mal (el desarrollador lo marcó). Se resuelve en el spike de combate: pose de impacto, pose en el aire mientras el motor mueve el cuerpo y aterrizaje. Las poses son de `cw2d-art`; la física, la elección de animación y la detección del aterrizaje son del juego.

## Recomendación

Disparo **automático** con **proyectil visible**, en tres ángulos que cambian de golpe (40° arriba, adelante, 20° abajo de pie y 45° abajo en el aire), de pie, **corriendo sin frenar** y **en el aire sin cambiar el salto**. De pie, Elyon queda plantado un instante después de cada tiro; en movimiento, no. Usar los valores de la tabla como `.tres` inicial de la feature y mantener la forma del prototipo: lógica pura del gatillo, Resource de configuración y proyectil que avanza con un rayo corto por paso.

## Siguiente paso

- [x] Decisión D0006 → GDD (mecánica de disparo), arquitectura (acción `shoot`), backlog (feature de disparo, arte de disparo en movimiento, muerte en el aire y límites del disparo corriendo en el spike de combate)
- [ ] Otro spike: no hace falta para el disparo; el spike de combate ya está en el backlog
- [ ] Descartar la idea: no
