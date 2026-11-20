---
id: D0007
type: decision
status: approved
superseded_by:
links: { gdd: [G003], decisions: [D0006], spike: S003 }
updated: 2026-11-20
---

# 0007: Disparar de pie sin quedar plantado

- Origen: spec de la feature 012 (disparo), pregunta 1. El desarrollador eligió la opción (a) el 2026-11-20 y aprobó la decisión ("Sí, apruebo la D0007 y la spec F012").
- De **D0006** reemplaza solo el punto "De pie, Elyon queda plantado un instante después de cada tiro (`shot_recovery`)". Todo lo demás sigue vigente.

## Contexto

D0006 dice que, de pie, Elyon queda plantado 0,12 s después de cada tiro, sin poder correr ni saltar. Al escribir la spec de la feature se vio que en el prototipo esa regla nunca tuvo efecto con la configuración elegida. Con "seguir corriendo mientras dispara", apretar una dirección o saltar liberaba a Elyon en el mismo paso. Sin input, quedarse quieto no cambia nada. El desarrollador jugó y aprobó el disparo sin notar el plantado.

## Opciones consideradas

| Opción | Resultado |
|---|---|
| **No quedar plantado** | **Elegida**: es lo que se jugó y se sintió bien |
| Plantado de verdad (0,12 s sin correr ni saltar después de cada tiro de pie) | No elegida: no se probó y cambia el control del movimiento |

## Decisión

- Después de un tiro de pie, Elyon puede correr o saltar en el mismo paso. Ninguna situación lo deja plantado por disparar.
- La pose de disparo de pie (`aim_pose_time`) es solo visual: arrancar a moverse la corta.

## Consecuencias (qué se actualiza: GDD, architecture.md, specs)

- `specs/gdd/mechanics/disparo.md`, "Cuándo se puede disparar": de pie dispara sin quedar plantado.
- `specs/features/012-disparo/spec.md`: sin `shot_recovery` en el `.tres` (ya redactada así).
- `specs/discarded.md`: "Quedar plantado un instante después de cada tiro de pie".
