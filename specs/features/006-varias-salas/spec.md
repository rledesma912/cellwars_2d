---
id: F006
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0004], spike: }
updated: 2026-10-29
---

# Feature 006: Varias salas y el paso entre ellas

- Origen: visión G001 ("Pantallas cortas, avance por salas"; "Estructura") y backlog. El enfoque de la lista ordenada de salas lo aprobó el desarrollador el 2026-10-24.
- Vía: completa. Crea un sistema nuevo (nivel y salas), toca `World` y las salas de prueba, y tiene `[feel]`.

## Objetivo

Que un nivel sea una **lista ordenada de salas** y que Elyon pase de una a otra al salir por un borde, como en los clásicos de pantalla fija: la pantalla cambia de golpe y Elyon aparece del otro lado, en la sala vecina.

- El nivel es un Resource (`LevelData`) con la lista de salas en orden.
- Las salas no conocen a sus vecinas. Cada una marca su **entrada** y su **salida**, en lados opuestos: izquierda y derecha, o arriba y abajo.
- `World` tiene una sola sala cargada:
  - salir por la **salida** lleva a la sala siguiente;
  - salir por la **entrada** lleva a la anterior.
- Mientras se juega una sala, la anterior y la siguiente se cargan en segundo plano, para que el cambio no se trabe.
- Cada sala define qué hay bajo su borde inferior: **vacío mortal** o **la sala de abajo**. Lo segundo pasa cuando la salida está abajo.

Para probarlo se arma un nivel de prueba con 3 salas en `game/levels/test/`.

## Fuera de alcance

- Muerte, animación de muerte y checkpoint (F007). Caer al vacío mortal sigue haciendo lo de hoy: Elyon vuelve a la entrada de la sala actual, quieto.
- El refugio y el final del nivel (ver "Preguntas abiertas" para la última salida).
- El mapa del nivel 1 y el arte de las salas: siguen en greybox.
- Varios niveles, menú de niveles y guardar el avance.
- Transiciones con efectos (fundidos, deslizamientos), salvo que se elija lo contrario en las preguntas abiertas.
- Cámara con scroll: el juego sigue siendo de pantalla fija.

## Criterios de aceptación

Lógica del nivel:

- F006-AC01 [unit] Avance por la lista. Con un nivel de 3 salas:
  - salir por la salida de la sala 1 → sala 2; de la 2 → sala 3;
  - salir por la entrada de la sala 3 → sala 2; de la 2 → sala 1.
- F006-AC02 [unit] Bordes de la lista:
  - salir por la entrada de la sala 1 no cambia de sala: Elyon vuelve a la entrada de la sala 1;
  - salir por la salida de la última sala hace lo que se decida en la pregunta abierta 1.
- F006-AC03 [unit] Qué borde cruzó. A partir del rectángulo de Elyon y la sala de 1280×720, se sabe si salió entero por la izquierda, por la derecha o por abajo, o si sigue adentro:
  - cuenta recién cuando ya no se ve nada de él;
  - asomar por arriba en un salto no cuenta como salir.
- F006-AC04 [unit] Qué significa ese borde en cada sala:
  - el borde de la salida → sala siguiente;
  - el borde de la entrada → sala anterior;
  - el borde de abajo, si no es la salida → vacío mortal (vuelve a la entrada de la sala actual);
  - cualquier otro borde no cuenta: las salas tienen paredes ahí.
- F006-AC05 [unit] Posición al llegar. Al pasar por un borde, Elyon aparece en el marcador del lado opuesto de la sala nueva (la entrada si avanzó, la salida si volvió) y conserva su desplazamiento respecto del marcador que cruzó:
  - en un paso horizontal conserva la altura relativa: si salió 30 px por encima del marcador de salida, entra 30 px por encima del marcador de entrada;
  - en un paso por abajo conserva la distancia horizontal relativa;
  - conserva la velocidad y hacia dónde mira, así que un salto o una carrera siguen del otro lado.
- F006-AC06 [unit] Validación del nivel de prueba. Cada sala de `LevelData` de prueba tiene entrada y salida en lados opuestos. Las salas vecinas encajan: si la salida de una está a la derecha, la entrada de la siguiente está a la izquierda; si está abajo, la siguiente entra por arriba.

Jugando:

- F006-AC07 [manual] Al tocar Jugar aparece la sala 1 del nivel de prueba, con Elyon en su entrada. El nivel tiene 3 salas en greybox, cada una con 3 pisos y escalones de hasta 4 baldosas:
  - una sala sale por la derecha;
  - otra sale por abajo, hacia la sala de abajo;
  - la última sale por la derecha.
- F006-AC08 [manual] Corriendo o saltando por la salida, la pantalla cambia a la sala siguiente en el cuadro siguiente. Elyon aparece del lado de la entrada, sigue en el mismo movimiento y mira para el mismo lado.
- F006-AC09 [manual] Volviendo por la entrada se llega a la sala anterior, del lado de su salida. Se puede ir y volver varias veces.
- F006-AC10 [manual] En la sala que sale por abajo, al caer por la salida Elyon aparece cayendo desde arriba en la sala siguiente. En una sala sin salida abajo, caer al vacío lo devuelve a la entrada de esa sala.
- F006-AC11 [manual] El cambio de sala no se traba: el FPS del overlay no baja al cruzar, ni la primera vez ni las siguientes (overlay: "FPS").
- F006-AC12 [manual] El overlay F3 muestra en qué sala está ("sala: 2 / 3"), y la línea cambia al cruzar.
- F006-AC13 [manual] La pausa sigue funcionando en cualquier sala. Volver al menú y Jugar de nuevo empieza en la sala 1.

Sensación:

- F006-AC14 [feel] Pasar de una sala a otra se siente continuo, como el cambio de pantalla de *Flashback* o *Prince of Persia*: no corta el ritmo de la carrera ni del salto.

## Casos límite

- **Cruzar a mitad de un salto**: la altura relativa al marcador se conserva. Si la sala nueva tiene techo ahí, Elyon choca como en cualquier salto. Las salas de prueba se dibujan con las aberturas alineadas a sus marcadores.
- **Cruzar y volver enseguida** (pararse en el borde e ir y venir): cada cruce es un cambio de sala válido. No hay espera mínima.
- **Precarga sin terminar**: si la sala vecina no terminó de cargarse en segundo plano, se carga en el momento. Puede notarse una pausa breve, pero no falla.
- **Pausa justo en el cruce**: el cambio de sala ocurre en `_physics_process`, que se congela con la pausa; no queda a medias.
- **Nivel de una sola sala**: la entrada y la salida se comportan como bordes de la lista (AC02).

## Parámetros de tuning (Resource)

`LevelData` (`.tres` en `game/levels/`) no es tuning de juego: es el contenido del nivel. Lo arma el desarrollador; el agente crea el del nivel de prueba.

| Parámetro | Tipo | Valor inicial | Rango sugerido |
|---|---|---|---|
| `rooms` (en `LevelData`) | `Array[PackedScene]` | las 3 salas de prueba, en orden | 1 o más |

Cada sala marca su entrada y su salida con dos `Marker2D` (`Entrance` y `Exit`) y declara de qué lado está cada uno. No hay valores numéricos nuevos de movimiento.

## Preguntas abiertas

1. **¿Qué pasa al salir por la salida de la última sala?** El refugio no entra en esta feature. Recomiendo que, por ahora, Elyon vuelva a la entrada de la sala 1: el nivel de prueba se puede recorrer en loop, y el refugio lo reemplaza más adelante. La alternativa es volver al menú principal.
2. **¿Cambio de sala de golpe o con un fundido corto?** Recomiendo **de golpe**, como en *Flashback* y *Prince of Persia*: es lo que pide AC08 ("en el cuadro siguiente") y no corta el ritmo. Un fundido se puede sumar después si hace falta.
3. **¿Entra la salida por abajo en esta feature?** La regla de salas lo permite (arriba y abajo) y el backlog habla de "la sala de abajo", así que la incluí (AC07 y AC10). Al entrar por arriba no se puede volver: Elyon no salta tan alto. Si preferís dejarla para más adelante, saco AC10 y la sala del medio sale por la derecha.
