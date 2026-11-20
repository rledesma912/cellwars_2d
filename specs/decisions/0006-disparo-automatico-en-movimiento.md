---
id: D0006
type: decision
status: approved
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0005], spike: S003 }
updated: 2026-11-20
---

# 0006: Disparo automático con proyectil, de pie, corriendo y en el aire

- Origen: spike 003 (disparo de pie, ampliado a disparar corriendo y en el aire el 2026-11-20). Aprobada por el desarrollador el 2026-11-20 ("Sí, apruebo la D0006, cerrá el spike").

## Contexto

Disparar es la mecánica central del combate y no sabíamos cómo se sentía. El spike S003 probó en un prototipo varias cosas:

- Tres modos de gatillo.
- Rayo o proyectil.
- Cuatro reglas para disparar corriendo.
- Disparar en el aire.
- Varios ángulos.

Los blancos del prototipo estaban quietos: no había enemigos ni daño. El desarrollador jugó cada variante y eligió. Sobre el resultado dijo *"Está bueno"* (de pie) y *"Se siente bien"* (en movimiento).

## Opciones consideradas

Modo de gatillo:

| Opción | Resultado |
|---|---|
| Tiro a tiro | Un disparo por apretón; no elegida |
| **Automático** | **Elegida**: mantener apretado dispara de forma repetida; el primer tiro sale al apretar |
| Ráfaga | N tiros por apretón y una pausa; no elegida |

Qué sale del arma:

| Opción | Resultado |
|---|---|
| Rayo instantáneo | Pega en el mismo paso con un destello; no elegida |
| **Proyectil visible** | **Elegida**: viaja a velocidad configurable |

Disparar corriendo:

| Opción | Resultado |
|---|---|
| No se puede (hay que frenar) | Elegida primero, con la duda de si alcanza con salas y enemigos reales; reemplazada en la ampliación |
| Frena solo y dispara al quedar quieto | No elegida |
| Corta la carrera en seco y dispara | No elegida |
| **Sigue corriendo y dispara** | **Elegida**, a velocidad completa (también se probaron 75 % y 50 %) |

Disparar en el aire:

| Opción | Resultado |
|---|---|
| Abajo en el aire a 20° (igual que de pie) | No elegida |
| **Abajo en el aire a 45°** | **Elegida** |
| Abajo en el aire a 70° | No elegida |
| **Disparar no cambia la caída** | **Elegida** |
| Disparar frena la caída (50 % o 25 % de gravedad) | No elegida |

Ángulos de pie: se probaron 45°, 50° y 55° arriba; 50° y 55° no le gustaron al desarrollador. Quedaron **40° arriba** y **20° abajo** (también se probó 15°).

## Decisión

- **Gatillo automático**: el primer tiro sale al apretar y, mientras siga apretado, sale uno cada `auto_interval` (0,14 s de arranque).
- **Proyectil visible**: avanza en cada paso de física y lanza un rayo corto desde donde estaba hasta donde va a estar, para no atravesar blancos finos. Tiene alcance corto (360 px de arranque).
- **Tres ángulos que cambian de golpe**, sin interpolar, elegidos con `move_up` / `move_down`:
  - De pie: 40° arriba, adelante y 20° abajo.
  - En el aire: 40° arriba, adelante y **45° abajo**.
- **Se dispara de pie, corriendo y en el aire**:
  - De pie, Elyon queda plantado un instante después de cada tiro (`shot_recovery`).
  - Corriendo, sigue a velocidad completa y no queda plantado.
  - En el aire, el salto y la caída no cambian.
- **No se dispara** girando, preparando el salto, aterrizando, rodando ni muerto. Agachado tampoco: esa postura no existe todavía.
- **Forma del código**:
  - La lógica pura del gatillo es un `RefCounted` en `game/systems/`.
  - El nodo de Elyon lee el botón, llama a esa lógica y aplica lo que devuelve.
  - Los valores van en un Resource `.tres` en `game/data/`. El `.tres` inicial usa los valores de la tabla "Valores de tuning que funcionaron" del informe de S003.
- **Acción `shoot`** en el input map:
  - En teclado: `J` y `X`.
  - En gamepad: el botón todavía no se decide. El botón X ya está asignado a `dash`; se elige en la spec.

## Consecuencias (qué se actualiza: GDD, architecture.md, specs)

- `specs/gdd/mechanics/`: nuevo documento de la mecánica de disparo, con lo decidido acá: gatillo, proyectil, ángulos, cuándo se puede disparar y cuándo queda plantado.
- `specs/gdd/vision.md`, pregunta abierta del arsenal: se responde en parte. Por ahora hay **un arma** de disparo automático; la munición y las armas extra siguen abiertas.
- `specs/architecture.md`, input map: se agrega `shoot` (teclado `J`/`X`; gamepad a definir en la spec).
- `CLAUDE.md`, input map de "Arquitectura de código": se agrega `shoot`.
- `specs/backlog.md`:
  - Sale el spike de disparo.
  - Entra la feature de disparo. Incluye traer el arte de disparo de `cw2d-art` y resolver el botón del gamepad frente a `dash`.
  - Entra el arte de disparo para `cw2d-art`:
    - retocar las poses de pie a 40° y 20°, con la boca de abajo a 42 px;
    - dibujar las poses de disparar corriendo y en el aire, en tres ángulos.
  - En el spike de combate se suma:
    - revisar si disparar corriendo a velocidad completa en automático vuelve el combate frenético;
    - resolver la muerte hacia atrás en el aire (pose de impacto, pose en el aire mientras el motor mueve el cuerpo, y aterrizaje).
- `specs/discarded.md`: tiro a tiro, ráfaga, rayo instantáneo, "no se puede disparar corriendo", frenar o cortar la carrera para disparar, ángulos de 50° y 55° arriba, y frenar la caída al disparar.
