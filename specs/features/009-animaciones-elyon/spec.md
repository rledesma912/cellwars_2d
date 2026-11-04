---
id: F009
type: feature
status: done
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0004, D0005], spike: }
updated: 2026-11-04
---

# Feature 009: Animaciones de Elyon en el juego

- Origen: arte de `cw2d-art` probado por el desarrollador en la laptop, 2026-11-03. Depende de D0005.
- Vía: completa (toca arte, escena y motor, y tiene criterios `[feel]`)

## Objetivo

Hoy el juego muestra las imágenes provisorias de Elyon. Las animaciones nuevas solo estuvieron en una copia de prueba. Esta feature las lleva al juego, con el tamaño y la velocidad de D0005, y convierte el rodar de esa prueba en una regla del motor.

Elyon usa las animaciones `quieto`, `arrancar`, `correr`, `frenar`, `girar`, `preparar`, `subir`, `caer`, `aterrizar` y `rodar`. Al caer de alto con velocidad hacia donde mira, rueda sin frenar en vez de detenerse a recuperarse.

## Fuera de alcance

- Animación de muerte: llega con la feature de muerte y checkpoint.
- Variantes de salto con carrera.
- Rodar a voluntad con un botón, o achicar la colisión mientras rueda.
- Publicar el arte en `assets/final/` del repositorio `cw2d-art`, que se resuelve en ese repositorio.
- Cambios en saltos, caídas, salas o valores de `player_movement.tres` que no sean `run_speed`.

## Criterios de aceptación

**Regla de rodar**

- ✅ F009-AC01 [unit] Al aterrizar de una caída igual o mayor a `hard_landing_height`, con velocidad horizontal de al menos `roll_min_speed_fraction` × `run_speed` hacia donde mira, el motor entra en el estado nuevo rodar.
- ✅ F009-AC02 [unit] Mientras rueda, conserva la velocidad horizontal e ignora la dirección apretada, durante `roll_time`.
- ✅ F009-AC03 [unit] Si la caída alta termina más lento que ese umbral o con velocidad contraria a donde mira, el motor entra en recuperarse y frena, como hasta ahora.
- ✅ F009-AC04 [unit] Al terminar `roll_time` sale de rodar y responde otra vez a la dirección apretada.
- ✅ F009-AC05 [unit] El estado rodar muestra la animación `rodar`, que dura `roll_time`. Recuperarse muestra siempre `aterrizar`.

**Arte**

- ✅ F009-AC06 [unit] `game/art/elyon/elyon_frames.tres` tiene todas las animaciones que puede pedir `PlayerAnimation.pick`, con cuadros de 144 × 144.
- ✅ F009-AC07 [manual] Las 10 animaciones se ven en el juego, hacia los dos lados, con los pies apoyados en el piso y sin que Elyon cambie de tamaño entre ellas.

**Tamaño y velocidad (D0005)**

- ✅ F009-AC08 [manual] La colisión de 34 × 82 coincide con el dibujo: los pies se apoyan en el piso, y no choca con aire ni atraviesa paredes o techos.
- ✅ F009-AC09 [manual] Con `run_speed` en 215 se recorren las 3 salas de prueba de punta a punta, incluido cruzar el agujero de 6 baldosas de la sala 1.

**Sensación**

- ✅ F009-AC10 [feel] A 215 px/s, la carrera tiene el peso buscado y los pies no patinan.
- ✅ F009-AC11 [feel] Rodar se siente como una continuación natural de la caída y no le quita control al jugador.

## Casos límite

- Rueda hacia una pared: se detiene contra ella y sigue en rodar hasta que termina `roll_time`.
- Rueda hacia un borde: si se queda sin piso, pasa a estar en el aire, como en los demás estados de piso.
- Salta mientras rueda: el salto no sale, pero si se aprieta cerca del final puede quedar guardado por el jump buffer.
- Cae de alto con velocidad contraria a donde mira, por el poco control en el aire: recupera sin rodar. La copia de prueba mostraba la animación de rodar mientras frenaba; acá no.
- `roll_time` en 0: nunca rueda.

## Parámetros de tuning (Resource)

`game/data/player_movement.tres`: `run_speed`, y por defecto del script `roll_min_speed_fraction` y `roll_time`.

## Notas finales

- Rodar es un estado propio del motor porque cambia las reglas: conserva la velocidad. La animación ya no puede decidir distinto que el motor, como pasaba en la copia de prueba.
- Al terminar de rodar, Elyon muestra `quieto` durante 1 paso de física antes de seguir, igual que al terminar el giro.
- La imagen salió de la copia de prueba: `assets/final/` de `cw2d-art` sigue sin publicar.
- AC07 a AC11: el desarrollador los validó jugando en la laptop, en las salas de `develop`, con pisos de 2 baldosas. Las casillas del PR quedaron sin tildar; aceptó cerrar con su mensaje: "probé en la laptop, confirmado".
