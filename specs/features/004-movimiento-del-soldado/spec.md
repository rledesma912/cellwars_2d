---
id: F004
type: feature
status: in-progress
superseded_by:
links: { gdd: [G001], decisions: [D0002, D0003], spike: S001 }
updated: 2026-10-25
---

# Feature 004: Movimiento del soldado

- Origen: GDD `vision.md` § Pilares (control preciso y deliberado) / decisión 0003 (movimiento híbrido y soldado de 48 px), que sale del spike 001
- Vía: completa (cambia el sistema de movimiento, el personaje, su animación y el overlay de debug; tiene criterios `[feel]`)

## Objetivo

El rectángulo de la F003 se convierte en **Elyon, el soldado**: mide 48 px, se mueve con el **movimiento híbrido** elegido en el spike 001 y se ve animado.

- Arranca y frena en un instante corto, en lugar de hacerlo en seco.
- Si está quieto, tarda un momento en darse vuelta. Si venía corriendo para el otro lado, primero frena.
- Antes de despegar hace una preparación corta.
  - El salto es variable: más alto si se mantiene el botón.
  - Tiene coyote time y jump buffer.
- En el aire corrige con la mitad de fuerza que en el piso y no puede darse vuelta.
- Si cae desde más alto que un piso, tarda un momento en recuperarse.
- **El motor manda los tiempos y la animación se adapta.** Cada animación de acción dura lo que dice el `.tres`, aunque el dibujo tenga más o menos cuadros.

Es la versión de juego de lo que se probó en el prototipo: mismo comportamiento, ahora con tests y dentro de la partida.

## Fuera de alcance

- Agacharse, rodar, colgarse de bordes, trepar, dash, combate, daño y muerte.
- Arte final y sonido. Las imágenes de Elyon son **provisorias**: sirven para jugar y medir, y se reemplazan antes de publicar.
- Mediciones en el overlay (largo del último salto, frenada). Quedaron registradas en el spike 001.
- Cambiar de sala (F005) y morir (F006). Salir de la pantalla sigue devolviendo al inicio, como en la F003.
- Rediseñar la sala de prueba. Se revisó y sirve tal cual (ver "Sala de prueba").

## Criterios de aceptación

Lógica pura (`PlayerMotor`, sin nodos). Todos los tiempos y alturas se miden simulando pasos de 1/60 s.

**Piso**

- F004-AC01 [unit] Arrancar: quieto, mirando a la derecha y con dirección derecha sostenida, la velocidad horizontal sube de a poco y llega a `run_speed` en `accel_time` (tolerancia: 1 paso). Mientras sube, el estado es "correr".
- F004-AC02 [unit] Frenar: corriendo a `run_speed` y sin dirección, el estado pasa a "frenar" y la velocidad llega a 0 en `decel_time` (tolerancia: 1 paso). Al llegar a 0, el estado es "quieto".
- F004-AC03 [unit] Girar quieto: quieto mirando a la derecha, con dirección izquierda, entra en "girar". Durante `turn_time` no se mueve; al terminar mira a la izquierda y vuelve a "quieto".
- F004-AC04 [unit] Girar corriendo: corriendo hacia la derecha, con dirección izquierda, primero frena hasta 0 (estado "frenar") y recién después gira. Nunca pasa de velocidad positiva a negativa sin pasar por 0 y por "girar".

**Salto**

- F004-AC05 [unit] Preparación: en el piso, al apretar salto entra en "preparar salto". Durante `jump_prep_time` sigue en el piso, conserva la velocidad horizontal y no responde a la dirección. Al terminar, despega.
- F004-AC06 [unit] Salto lleno: con el botón sostenido, la altura máxima es `jump_height` (tolerancia: 2 px).
- F004-AC07 [unit] Toque corto: si el botón se suelta antes de despegar, la altura máxima es `min_jump_height` (tolerancia: 2 px).
- F004-AC08 [unit] Soltar subiendo: si el botón se suelta a mitad de la subida, la altura queda entre `min_jump_height` y `jump_height` (tolerancia: 2 px).
- F004-AC09 [unit] Caída más pesada: bajando, la gravedad es la de subida × `fall_gravity_scale`, sin superar `max_fall_speed`.
- F004-AC10 [unit] Sin doble salto: apretar salto en el aire, pasado el coyote time, no cambia la velocidad vertical.
- F004-AC11 [unit] Mantener no repite: si el botón sigue apretado desde antes, al tocar el piso no vuelve a saltar.

**Ayudas**

- F004-AC12 [unit] Coyote time: si camina al vacío y aprieta salto dentro de `coyote_time`, salta sin preparación. Pasado ese tiempo, no.
- F004-AC13 [unit] Jump buffer: si aprieta salto en el aire y toca el piso dentro de `jump_buffer_time`, al tocarlo arranca la preparación del salto. Si el piso llega más tarde, no.

**Aire y aterrizaje**

- F004-AC14 [unit] Control en el aire: en el aire, la velocidad horizontal cambia con `air_control` × la aceleración del piso. Puede frenar o corregir hasta 0, pero no ir para el lado contrario al que miraba al despegar ni darse vuelta.
- F004-AC15 [unit] Aterrizaje normal: si cae menos de `hard_landing_height`, al tocar el piso queda en "quieto" o "correr" y responde enseguida.
- F004-AC16 [unit] Aterrizaje pesado: si cae `hard_landing_height` o más, entra en "recuperarse".
  - Durante `land_recovery_time` no responde a la dirección y frena.
  - Al terminar, vuelve a "quieto".

**Valores derivados y animación**

- F004-AC17 [unit] Valores derivados:
  - gravedad de subida `g = 2·jump_height / time_to_apex²`;
  - velocidad de salto `2·jump_height / time_to_apex`;
  - velocidad de corte `√(2·g·min_jump_height)`;
  - aceleración del piso `run_speed / accel_time`;
  - frenado `run_speed / decel_time`.
- F004-AC18 [unit] Animación según el estado: cada estado del motor tiene su animación.
  - quieto → `quieto`; correr → `arrancar` por debajo del 70 % de `run_speed` y `correr` desde ahí; frenar → `frenar`; girar → `girar`; preparar salto → `preparar`.
  - En el aire: `subir` si sube y `caer` si baja.
  - Recuperarse → `aterrizar`.
- F004-AC19 [unit] El motor manda los tiempos: una animación de N cuadros a F cuadros por segundo dura N/F s. Para que dure T s se reproduce a velocidad (N/F) / T. Se aplica a girar (`turn_time`), preparar (`jump_prep_time`) y aterrizar (`land_recovery_time`).

**Jugando**

- F004-AC20 [manual] Al tocar Jugar, en lugar del rectángulo aparece Elyon animado, de 48 px de alto, parado en el inicio de la sala de prueba. Mira a la derecha y, al ir a la izquierda, se ve espejado.
- F004-AC21 [manual] Partiendo de la entrada se llega a la salida de la sala de prueba solo corriendo y saltando, sin que se trabe en techos ni escalones. El precipicio de 3 baldosas se salta corriendo.
- F004-AC22 [manual] Se mantiene lo de la F003:
  - salir de la pantalla lo devuelve al inicio, quieto y mirando a la derecha;
  - la pausa lo congela, también a mitad de una preparación o de una recuperación;
  - Continuar lo deja seguir desde donde estaba.
- F004-AC23 [manual] F3 muestra, además de lo que ya mostraba, el estado del motor, hacia dónde mira y los timers (estado actual, coyote, buffer). Cambian al moverse.
- F004-AC24 [manual] Cambiar un valor en `game/data/player_movement.tres` desde el inspector (por ejemplo `jump_prep_time` o `turn_time`) cambia el movimiento en la siguiente partida, y la animación correspondiente dura el tiempo nuevo.
- F004-AC25 [feel] El soldado se siente con peso y compromiso, pero responde: el mismo equilibrio que se eligió en el spike 001, ahora en la sala del juego.
- F004-AC26 [feel] La preparación, el giro y la recuperación se leen en la animación: se ve que el soldado se prepara, se da vuelta y se recupera, sin que parezca que el control se trabó.

## Casos límite

- **Salto durante el giro o la recuperación.** Si se aprieta salto en esos estados, no salta en ese momento. Si el giro o la recuperación terminan dentro de `jump_buffer_time`, salta al terminar.
- **Borde durante la preparación.** Si el impulso que conserva lo saca del borde antes de despegar, cae sin saltar y vale el coyote time.
- **Coyote time** solo vale si cayó caminando: después de un salto no da un segundo salto.
- **Chocar con un techo subiendo:** empieza a caer en ese momento. Con 48 px + 52 px de salto, la cabeza toca justo el techo de cada piso; no debe quedar pegado.
- **Izquierda y derecha juntas:** se anulan, como sin dirección. Frena.
- **Stick apenas inclinado:** por debajo de la zona muerta no se mueve. Con inclinación parcial, `run_speed` se escala con el stick, igual que en la F003.
- **Reinicio** (salir de la pantalla): vuelve quieto, mirando a la derecha y con los timers en cero, aunque estuviera en el aire o recuperándose.

## Sala de prueba

La sala de la F003 (`game/levels/test/test_room.tscn`) se revisó para el soldado nuevo, contando baldosas, y **no cambia**:

- Cada piso tiene 100 px de aire. 48 de cuerpo + 52 de salto = 100: entra justo.
- Los escalones son de 2 baldosas (40 px) y el salto llega a 52 px.
- El precipicio es de 3 baldosas (60 px). El salto corriendo mide unos 95 px.
- Los huecos para subir de piso miden 2 baldosas. El cuerpo nuevo es más angosto que el rectángulo (20 px contra 26).

Al implementar se confirma con una simulación que aprieta teclas, como en la F003.

## Parámetros de tuning (Resource)

`PlayerMovementConfig` (`game/systems/player/player_movement_config.gd`) suma parámetros. Los valores iniciales son los de la variante elegida en el spike 001 (`variant_c48.tres`, tag `archive/spike-001`). Viven en `game/data/player_movement.tres`, que ya existe: **al aprobar esta spec, el desarrollador autoriza al agente a cambiar ese archivo una sola vez** a estos valores. Desde ahí lo vuelve a editar solo el desarrollador.

| Parámetro | Tipo | Valor inicial | Rango sugerido |
|---|---|---|---|
| `run_speed` | float (px/s) | 135 | 80 – 200 |
| `accel_time` | float (s) | 0,15 | 0 – 0,4 (0 = arranca en seco) |
| `decel_time` | float (s) | 0,12 | 0 – 0,4 (0 = frena en seco) |
| `turn_time` | float (s) | 0,08 | 0 – 0,3 (0 = gira al instante) |
| `jump_height` | float (px) | 52 | 30 – 52 (más de 52 choca con el techo de un piso) |
| `min_jump_height` | float (px) | 30 | 15 – `jump_height` (igual = salto de altura fija) |
| `time_to_apex` | float (s) | 0,36 | 0,25 – 0,5 |
| `fall_gravity_scale` | float | 1,25 | 1 – 2 |
| `max_fall_speed` | float (px/s) | 600 | 300 – 900 |
| `jump_prep_time` | float (s) | 0,07 | 0 – 0,2 (0 = despega al apretar) |
| `air_control` | float (0–1) | 0,5 | 0 – 1 (0 = arco fijo) |
| `hard_landing_height` | float (px) | 100 | 60 – 200 |
| `land_recovery_time` | float (s) | 0,15 | 0 – 0,4 (0 = sin recuperación) |
| `coyote_time` | float (s) | 0,08 | 0 – 0,15 |
| `jump_buffer_time` | float (s) | 0,1 | 0 – 0,2 |

Las alturas se verificaron simulando pasos de 1/60 s con los valores iniciales y con los extremos de los rangos:

- el salto lleno da `jump_height`;
- el toque corto da `min_jump_height`;
- soltar a mitad de la subida da un valor entre los dos.

En todos los casos la diferencia fue de menos de 0,1 px.

No son parámetros, sino reglas de D0003:

- en el aire no se da vuelta;
- el cuerpo de colisión mide 20 × 48 px;
- los cuadros de animación miden 64 × 64 px, con los pies en (32, 63).

## Arte provisorio

- Las 21 imágenes de Elyon a 48 px del spike 001 se traen al juego en `game/art/elyon/`, con su `SpriteFrames`.
- Animaciones: `quieto`, `arrancar`, `correr`, `frenar`, `girar`, `preparar`, `subir`, `caer`, `aterrizar`.
- Son provisorias, sin animación de muerte ni de combate.
- Reemplazan al greybox solo en el personaje; la sala sigue en greybox.

## Decisiones del desarrollador

- Spec aprobada el 2026-10-25 ("Apruebo"), incluyendo:
  - el cambio único de `game/data/player_movement.tres` a los valores iniciales por el agente;
  - las imágenes provisorias de Elyon en el juego.

## Preguntas abiertas

_Ninguna._
