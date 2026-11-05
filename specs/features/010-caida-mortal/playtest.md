---
id: F010
type: feature
status: draft
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0005], spike: }
updated: 2026-11-04
---

# Playtest: feature 010

> Guía de pasos. Se tilda en el checklist del PR, que es la fuente de verdad: este archivo no lleva casillas.

## Preparación (escena, overlay F3)

- En la laptop: `~/probar_en_laptop.sh`. Abre directo la partida (`world.tscn`).
- F3 muestra el overlay. Para esta feature, mirá `caída`, `estado`, `timer estado` y `sala`.
- `caída` muestra la altura contada, y después de aterrizar conserva la última. Cuenta un 3 % más que la distancia real: un piso (240 px) se ve como unos 248 y dos pisos (480 px) como unos 495. El límite se compara con ese número.
- Las alturas se ajustan en `game/data/player_movement.tres`, grupo "Aterrizaje": `long_fall_height` y `lethal_fall_height`. Todavía no aparecen escritas en el archivo porque usan el valor por defecto; se cambian desde el inspector.

Lugares de prueba:

| Sala | Dónde | Qué pasa |
|---|---|---|
| 1 | Pozo del piso de arriba, antes de la salida | Cae hasta la zona mortal del fondo |
| 2 | Borde derecho del piso de arriba | Un piso hasta el piso del medio |
| 2 | Hueco nuevo a la derecha del piso del medio | Baja por la salida a la sala 3 y muere al aterrizar (cambio nuevo) |
| 3 | Hueco nuevo en el piso de arriba, cerca de donde se llega | Dos pisos sobre piso común (cambio nuevo) |

Cambios en la sala 3: además del hueco, el piso del medio termina antes, la zona mortal de ese piso se corrió a la izquierda y el bloque del piso de abajo también. Para seguir hacia la izquierda en el piso de arriba, hay que saltar el hueco.

## Checklist [manual]

- F010-AC10: En la sala 1, subí al piso de arriba y dejate caer por el pozo → cambia de `caer` a `caer_largo` en el aire, pasa a `morir_caida` sin ningún cuadro de pie y aparece quieto en la entrada (overlay: `estado` dice "morir" y `timer estado` baja desde 1,60).
- F010-AC11: En la sala 3, desde donde se llega, dejate caer por el hueco hacia la izquierda → muere al tocar el piso común, sin zona mortal. Volvé, saltá el hueco, date vuelta y dejate caer hacia la derecha → muere igual (overlay: `caída` da unos 495).
- F010-AC12: En la sala 2, salí corriendo del borde derecho del piso de arriba → rueda al llegar al piso del medio y sigue vivo. Como rodar conserva la velocidad, puede seguir de largo por el hueco nuevo, pasar a la sala 3 y morir al aterrizar: es esperable. Volvé a la entrada de la sala y bajá soltando la dirección apenas caés → se recupera con `aterrizar`. En los dos casos no se ve `caer_largo` (overlay: `caída` da unos 248).
- F010-AC13: Morí por altura en la sala 3, una vez hacia cada lado → tendido, todo el cuerpo toca el piso y el arma queda adelante, recortada por el piso.
- F010-AC14: En la sala 1, caminá hacia la zona mortal del piso de abajo, cerca de la entrada → `morir` se desploma en el lugar, sin inclinarse hacia atrás antes de caer.
- F010-AC18: En la sala 2, parate en el piso del medio, sobre la parte que quedó a la izquierda del hueco nuevo, y dejate caer por él → pasa a la sala 3 en el aire, sigue en `caer_largo`, muere al aterrizar y reaparece en la entrada de la sala 3 (overlay: `sala` pasa a "3 / 3" y `caída` sigue subiendo al cruzar, hasta unos 450). Además, bajá por el hueco original desde el piso de abajo → llega vivo.

## Checklist [feel]

<!-- Solo lo marca el desarrollador. -->

- F010-AC15: ¿Antes de tocar el piso se entiende que la caída es grave? Mirá también saltar y bajar un piso, que muestra `caer_largo` durante 6 pasos y sobrevive. (`long_fall_height`)
- F010-AC16: ¿El golpe se siente seco y la muerte por altura se siente justa, se entiende por qué murió? (`lethal_fall_height`, `death_time`)

## Notas del playtest
