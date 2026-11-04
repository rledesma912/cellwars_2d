---
id: F010
type: feature
status: approved
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0005], spike: }
updated: 2026-11-04
---

# Feature 010: Caída mortal

- Origen: playtest de F007 ("cae de una altura que consideramos mortal y cae parado") y backlog. La regla de alturas y el arte los aprobó el desarrollador jugando una copia de prueba, el 2026-11-03 y el 2026-11-04.
- Vía: completa (toca motor, animación y arte, y tiene criterios `[feel]`)

## Objetivo

Hoy ninguna altura mata: en el pozo de la sala 1 lo que mata es la zona mortal del fondo, y Elyon cae erguido, como en un salto. Esta feature hace que la altura sea una regla del juego. Un piso se sobrevive y dos no.

| Altura de la caída | Con velocidad hacia donde mira | Sin esa velocidad |
|---|---|---|
| Menos de `hard_landing_height` | Sigue corriendo | Queda quieto |
| Desde `hard_landing_height` y menos de `lethal_fall_height` | Rueda | Se recupera con `aterrizar` |
| `lethal_fall_height` o más | Muere con `morir_caida` | Muere con `morir_caida` |

Desde `long_fall_height`, Elyon muestra `caer_largo` en el aire: el jugador ve que perdió el control antes de tocar el piso. Además, `morir` se reemplaza por el arte nuevo, que se desploma en el lugar, sin ir hacia atrás.

## Fuera de alcance

- Sonido, polvo o sangre al golpear.
- Cambios en la gravedad, en el tope de velocidad de caída o en `death_time`.
- Muertes por golpe o toxina, y la muerte que hace volar el cuerpo hacia atrás.
- Dar más control o una forma de salvarse durante la caída.
- Publicar el arte en `assets/final/` de `cw2d-art`, que se resuelve en ese repositorio.

## Criterios de aceptación

**Regla de la altura**

- F010-AC01 [unit] Al aterrizar de una caída igual o mayor a `lethal_fall_height`, el motor entra en morir, por caída, con el tiempo de `death_time`, tenga la velocidad que tenga.
- F010-AC02 [unit] Una caída apenas menor a `lethal_fall_height` sigue las reglas de hoy: rueda o se recupera (F004-AC16, F009-AC01 y F009-AC03).
- F010-AC03 [unit] Morir por caída ignora dirección y salto hasta que se reinicie, y al terminar vuelve al checkpoint como las demás muertes (F007-AC01, F007-AC03 y F007-AC06).
- F010-AC04 [unit] La altura se cuenta solo mientras baja: en un salto se mide desde el punto más alto, no desde donde despegó.
- F010-AC17 [unit] Al entrar a otra sala, la altura vuelve a contarse desde 0: una caída no suma lo que bajó en la sala anterior.

**Qué se ve**

- F010-AC05 [unit] En el aire, bajando, con la caída igual o mayor a `long_fall_height`, la animación es `caer_largo`. Por debajo, `caer`. Subiendo, `subir`.
- F010-AC06 [unit] Muerto, en el piso, con la caída igual o mayor a `lethal_fall_height`, la animación es `morir_caida`, sea por la altura o por una zona mortal. Por debajo de esa altura, `morir`.
- F010-AC07 [unit] Muerto, en el aire, con la caída igual o mayor a `lethal_fall_height`, sigue mostrando `caer_largo` hasta tocar el piso. No hay `morir_caida` flotando.
- F010-AC08 [unit] `morir_caida` no se estira con `death_time`: va a su ritmo propio (0,22 s hasta quedar tendido) y se queda en su último cuadro, sin reiniciarse, hasta volver a la entrada. `morir` sigue durando `death_time` (F007-AC05).
- F010-AC09 [unit] `game/art/elyon/elyon_frames.tres` tiene `caer_largo` y `morir_caida`, con cuadros de 144 × 144.

**Jugando**

- F010-AC10 [manual] En el pozo de la sala 1 (460 px con zona mortal al fondo), Elyon cae, cambia a `caer_largo`, pasa a `morir_caida` sin ningún cuadro de pie y aparece quieto en la entrada (overlay: `estado`, `timer estado`).
- F010-AC11 [manual] Una sala de prueba tiene una caída de dos pisos que termina en piso común, sin zona mortal, y Elyon muere al tocarlo, hacia los dos lados.
- F010-AC12 [manual] Caer un piso (240 px) se sobrevive: rueda si viene corriendo y se recupera si cae en vertical, sin mostrar `caer_largo`.
- F010-AC13 [manual] Tendido, todo el cuerpo toca el piso, hacia los dos lados, y el arma queda adelante, recortada por el piso.
- F010-AC14 [manual] Al tocar una zona mortal en el piso, `morir` se desploma en el lugar: no se inclina hacia atrás antes de caer.
- F010-AC18 [manual] Al caer de la sala 2 a la sala 3, la línea `caída` del overlay vuelve a 0 al entrar a la sala 3, y solo cuenta lo que baja en ella.

**Sensación**

- F010-AC15 [feel] Antes de tocar el piso se entiende que la caída es grave.
- F010-AC16 [feel] El golpe se siente seco y la muerte por altura se siente justa: se entiende por qué murió.

## Casos límite

Tiempos simulados en pasos de 1/60 s, con la física actual de `player_movement.tres`:

| Caída | Pasos en el aire | Pasos con `caer_largo` | Resultado |
|---|---|---|---|
| 240 px: un piso | 28 | 0 | Sobrevive |
| 354 px: salta y baja un piso | 34 | 6 | Sobrevive |
| 460 px: pozo de la sala 1 | 39 | 11 | Muere |
| 480 px: dos pisos | 40 | 12 | Muere |

- Salta y baja un piso: muestra `caer_largo` 6 pasos y sobrevive. Se revisa en el playtest, y se ajusta con `long_fall_height`.
- Cruza a otra sala mientras cae en `caer_largo`: vuelve a `caer` hasta superar de nuevo `long_fall_height` (F010-AC17).
- Toca una zona mortal con menos de `lethal_fall_height`, en el aire: sigue F007-AC08, con `morir`.
- Cae al vacío desde cualquier altura: sigue siendo muerte por el vacío, con `void_restart_time`. No hay nada que mostrar.
- Muere por altura ya rodando o recuperándose: no puede pasar, porque esos estados solo empiezan si la caída no fue mortal.
- `caer_largo` se repite en el `.tres`, igual que `caer`, porque `Player` reinicia lo que no repite. Su segundo cuadro dura 1,5 s, más que cualquier caída actual (la de 720 px dura 0,85 s).
- Da de frente contra una pared mientras cae: la altura sigue contando. Muere igual si llega al piso con la altura suficiente.

## Parámetros de tuning (Resource)

En `game/data/player_movement.tres`, grupo "Aterrizaje" de `PlayerMovementConfig`.

| Parámetro | Tipo | Valor inicial | Rango sugerido |
|---|---|---|---|
| `long_fall_height` | float (px) | 260 | 240–400 |
| `lethal_fall_height` | float (px) | 420 | 360–700 |

`lethal_fall_height` tiene que quedar por encima de 354 px, para que saltar y bajar un piso no mate.

## Arte

Sale de `cw2d-art`, `specs/animaciones/elyon_caida_mortal.md` y `specs/characters/elyon.yaml`, ya aprobado. Las tiras están en `build/blender/elyon_v9/` de ese repositorio:

| Animación | Tira | Cuadros | Velocidad | Duración relativa |
|---|---|---|---|---|
| `caer_largo` (repite) | `fall_long_final.png` | 2 | 20 cps | 1 y 30 |
| `morir_caida` (no repite) | `death_fall_final.png` | 4 | 14,29 cps | 1, 1, 1,143 y 10 |
| `morir` (reemplaza) | `morir_final.png` | 9 | Sin cambios | Sin cambios |

Se probaron en una copia local del juego con estos valores.
