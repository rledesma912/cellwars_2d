---
name: curate-specs
description: Curación periódica de specs/ en cellwars_2d - detecta contradicciones, referencias rotas u obsoletas, contenido descartado en documentos vivos, borradores abandonados y frontmatter inconsistente, y propone los arreglos en un PR. Usala al cerrar un milestone, cada ~5 features o cuando el desarrollador lo pida.
---

# Curate specs

Ignorá `specs/archive/` como fuente de verdad, pero usalo para detectar referencias a cosas archivadas.

## 1. Revisar

| Chequeo | Cómo |
|---|---|
| Frontmatter | Todo `.md` de `specs/` (salvo `INDEX.md`, `discarded.md`, `backlog.md`, `HANDOFF.md`, `templates/`) tiene `id`, `type`, `status`, `links`, `updated` con los valores válidos que define `CLAUDE.md` (incluye `type: architecture` / `id: ARCH`). Ids únicos. |
| Contradicciones | GDD vs specs vs decisiones `approved` vs `architecture.md`. |
| Referencias | Enlaces y `links:` que apuntan a archivos inexistentes, a `archive/` o a decisiones `superseded`. |
| Contenido descartado | Ideas de `discarded.md` que siguen mencionadas en documentos vivos. |
| Preguntas viejas | "Preguntas abiertas" en specs `approved`/`in-progress`/`done`. |
| Borradores abandonados | `status: draft` con `updated` de hace más de 30 días. |
| INDEX | Features `done` que faltan en `INDEX.md` o entradas que apuntan a features no cerradas. |
| Spikes | Más de uno abierto (branches `spike/*` + `specs/spikes/`); spikes `done` sin decisión o sin cerrar. |
| Trazabilidad | Criterios `[unit]` de features `in-progress`/`done` sin test `test_fnnn_acnn_*` en `test/` (grep). |

## 2. Informe

Tabla de hallazgos: archivo, problema, propuesta. Mostralo al desarrollador.

## 3. PR

Branch `docs/curate-<YYYY-MM-DD>` desde `develop` actualizado. Aplicá solo los arreglos mecánicos (frontmatter, enlaces, mover a `archive/`, quitar contenido descartado de los vivos). Lo que requiere criterio (contradicciones, GDD, decisiones, criterios de specs aprobadas) va como propuesta en el cuerpo del PR, sin aplicarse. Commit `docs: curación de specs`, PR a `develop`.

Nunca borrar: mover a `archive/` o dejar en git.
