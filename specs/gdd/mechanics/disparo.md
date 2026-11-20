---
id: G003
type: gdd
status: approved
superseded_by:
links: { gdd: [G001, G002], decisions: [D0006], spike: }
updated: 2026-11-20
---

# Disparo

> Cómo dispara Elyon. Sale del spike S003 y de la decisión D0006. Los números exactos los fija la feature en su `.tres`; acá van las reglas.

## Gatillo

- **Automático**: el primer tiro sale al apretar disparar y, mientras se mantiene apretado, sigue disparando a cadencia fija (unos 7 tiros por segundo de arranque).
- **Un arma**. Si habrá más armas o munición limitada sigue abierto en la visión.

## Qué sale del arma

- **Proyectil visible**, rápido y de **alcance corto**: se pierde a poco más de un cuarto de sala.
- El proyectil se frena contra paredes y pisos y pega en lo que encuentra.

## Ángulos

Tres, que cambian de golpe (sin girar el arma de a poco): se mantiene arriba o abajo mientras se dispara.

| Dónde | Arriba | Adelante | Abajo |
|---|---|---|---|
| De pie y corriendo | 40° | horizontal | 20° |
| En el aire | 40° | horizontal | 45° |

## Cuándo se puede disparar

- **De pie**: después de cada tiro Elyon queda plantado un instante (no corre ni salta). Le da peso a cada tiro.
- **Corriendo**: sigue corriendo a velocidad completa mientras dispara.
- **En el aire** (subiendo o cayendo): dispara sin cambiar el salto ni la caída.
- **No se dispara** girando, preparando el salto, aterrizando, rodando ni muerto.

## Arte

- De pie: animaciones de disparo en los tres ángulos (impacto, recuperación y pose sostenida), de `cw2d-art`.
- Corriendo y en el aire: poses de disparo en los tres ángulos, pendientes en `cw2d-art`.
