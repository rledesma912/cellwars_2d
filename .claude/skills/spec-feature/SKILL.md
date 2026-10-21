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

1. Número `NNN`: siguiente libre en `specs/features/` y `specs/archive/features/`. Carpeta `specs/features/NNN-<nombre>/spec.md`, id `FNNN`, `status: draft`, `links` completos (GDD, decisiones, spike).
2. Criterios de aceptación con ID `FNNN-ACnn` y **una** etiqueta cada uno:
   - `[unit]`: comportamiento de lógica pura verificable con gdUnit4 (timers, cálculos, transiciones). Redactalo como entrada → salida.
   - `[manual]`: resultado objetivo jugando ("sube a una plataforma de 3 tiles").
   - `[feel]`: subjetivo; siempre lo cierra el desarrollador.
   Cada criterio es verificable por sí solo. Preferí `[unit]` cuando la regla se puede aislar.
3. Parámetros de tuning: tabla con tipo, valor inicial y rango. Si vienen de un spike, usá los valores que funcionaron.
4. Casos límite y Fuera de alcance explícitos.
5. Preguntas abiertas: solo las reales; cada una debe resolverse antes de aprobar o quedar como decisión del desarrollador.

## 5. Aprobación

Mostrá la spec y **pedí aprobación**. Al aprobarse: `status: approved`. Desde ese momento no cambiás criterios: si algo resulta incorrecto o inviable, detenete y proponé el cambio.

Siguiente paso: vía completa → `plan-feature`; vía liviana → completá "Plan y tasks", creá la issue (`gh issue create`) y seguí con `implement-task`.
