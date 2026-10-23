---
name: spec-feature
description: Redacta la spec de una feature de cellwars_2d - evalúa si necesita spike, elige vía completa o liviana y escribe spec.md con criterios identificados y etiquetados [unit]/[manual]/[feel]. Usala cuando el desarrollador pida especificar una feature nueva.
---

# Spec feature

Plantilla: `specs/templates/spec.md`.

## 1. Contexto

Leé `specs/INDEX.md`, el GDD relevante, las decisiones vigentes en `specs/decisions/`, `specs/architecture.md` y `specs/discarded.md`. Si la feature (o parte) está descartada, decilo y no sigas sin un motivo nuevo explícito.

## 2. ¿Necesita spike?

Aplicá los criterios del principio 1 de `CLAUDE.md`. Si alguno se cumple, recomendá un spike (skill `spike`) explicando qué incertidumbre resolvería, y detenete hasta que el desarrollador decida. Si no aplica ninguno, decilo en una línea y seguí.

## 3. Vía

- **Liviana**: feature chica, un solo sistema existente, sin `[feel]`. Un único `spec.md` con sección final "Plan y tasks".
- **Completa**: toca más de un sistema, crea un sistema nuevo o tiene criterios `[feel]`. `spec.md` ahora; `plan.md` y `tasks.md` después con `plan-feature`.

## 4. Redactar

1. Número `NNN`: siguiente libre en `specs/features/`, `specs/archive/features/` y las branches `feat/*` (`git fetch` y `git branch -a --list '*feat/*'`).
2. **Branch** (igual en ambas vías): con working tree limpio y `develop` al día con `origin/develop`, creá `feat/NNN-<nombre>` desde `develop`. La spec, el plan, el código y el playtest viajan juntos en esta branch y en un único PR.
3. Carpeta `specs/features/NNN-<nombre>/spec.md`, id `FNNN`, `status: draft`, `links` completos (GDD, decisiones, spike). Commit `docs: spec FNNN (draft)`.
4. Criterios de aceptación con ID `FNNN-ACnn` y **una** etiqueta cada uno:
   - `[unit]`: comportamiento de lógica pura verificable con gdUnit4 (timers, cálculos, transiciones). Redactalo como entrada → salida.
   - `[manual]`: resultado objetivo jugando ("sube a una plataforma de 3 tiles").
   - `[feel]`: subjetivo; siempre lo cierra el desarrollador.
   Cada criterio es verificable por sí solo. Preferí `[unit]` cuando la regla se puede aislar.
5. Parámetros de tuning: tabla con tipo, valor inicial y rango. Si vienen de un spike, usá los valores que funcionaron.
6. Casos límite y Fuera de alcance explícitos.
7. Preguntas abiertas: solo las reales; cada una debe resolverse antes de aprobar o quedar como decisión del desarrollador.

## 5. Aprobación

Mostrá la spec y **pedí aprobación explícita**. Al aprobarse: `status: approved`, commit `docs: spec FNNN aprobada` y push. Desde ese momento no cambiás criterios: si algo resulta incorrecto o inviable, detenete y proponé el cambio.

Siguiente paso (siempre en `feat/NNN-<nombre>`):
- Vía completa → `plan-feature`.
- Vía liviana → completá "Plan y tasks" en la spec, creá la issue (`gh issue create`, título `FNNN: <nombre>`), anotá `Issue: #N`, commit, y seguí con `implement-task`.
