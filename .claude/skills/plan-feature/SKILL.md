---
name: plan-feature
description: Redacta el plan técnico (plan.md) y las tasks (tasks.md) de una feature aprobada de cellwars_2d y crea su issue en GitHub. Usala después de que spec-feature deje una spec en status approved por la vía completa.
---

# Plan feature

Plantillas: `specs/templates/plan.md`, `specs/templates/tasks.md`. Convenciones: skill `godot-conventions`.

Precondiciones (si alguna falla, detenete y reportá): estás en la branch `feat/NNN-<nombre>` (la creó `spec-feature`), working tree limpio, y `specs/features/NNN-<nombre>/spec.md` tiene `status: approved`.

## 1. Diseño

1. Leé la spec, `specs/architecture.md` y el código existente de los sistemas que toca.
2. Para cada sistema de Godot involucrado, invocá la skill `godot-prompter:*` del dominio (salvo que el patrón ya esté fijado en `architecture.md` o en una decisión y sus supuestos no hayan cambiado). Si su recomendación contradice `architecture.md` o una decisión aprobada, señalá el conflicto y pedí una decisión; no cambies la arquitectura. En el plan, por cada elección no obvia (tipo de nodo, FSM enum vs nodos, señal vs llamada directa), escribí el patrón elegido, la alternativa descartada y el porqué. El desarrollador está aprendiendo Godot: explicalo breve.
3. Completá `plan.md` (mismo frontmatter que la spec, `status: draft`):
   - **Árbol de escenas**: bloque con la jerarquía de nodos y su tipo.
   - **Scripts y responsabilidades**: tabla; cada archivo clasificado como lógica pura / nodo / Resource. Ninguna regla de juego en nodos.
   - **Señales**: nombre, emisor, receptores, payload.
   - **Qué se testea con gdUnit4**: un ítem por cada criterio `[unit]`, con el nombre del test (`test_fnnn_acnn_...`).
   - **Impacto en overlay debug**: líneas nuevas en F3.
   - **Riesgos**.
4. Si el diseño revela que la spec es incorrecta o inviable, detenete y proponé el cambio a la spec.

## 2. Tasks

`tasks.md`: tasks chicas y ordenadas (cada una cerrable con un commit), cada una con `(cubre: FNNN-ACnn, ...)`. Todo criterio de la spec queda cubierto por al menos una task; los `[manual]`/`[feel]` se cubren con la task de playtest. Orden típico: Resource de config → lógica pura + tests → nodo → overlay → `.tres` inicial → playtest.

## 3. Issue

1. `gh issue create` con título `FNNN: <nombre>`, cuerpo con enlace a la carpeta de la spec y la lista de tasks como checklist.
2. Completá `Issue: #N` en la spec (es un dato administrativo, no un cambio de criterios).
3. Commit `docs: plan y tasks FNNN` y push.

Mostrá plan y tasks y pedí revisión explícita antes de implementar. Siguiente paso: `implement-task`.
