# CLAUDE.md — cellwars_2d

Plataformas 2D en pixel art con Godot. Desarrollador solo, aprendiendo GDScript: **explicá en comentarios breves y en los PRs toda decisión de Godot que no sea obvia.** Todo open source.

## Reglas de lectura

- Para entender el estado del juego, empezá por `specs/INDEX.md`.
- Ignorá `specs/archive/` salvo que se pida investigar historia.
- Antes de proponer una mecánica o enfoque, revisá `specs/discarded.md`. Si está ahí, solo se reabre con un motivo nuevo y explícito.
- Documento de diseño del flujo completo: `specs/HANDOFF.md`.

## Vocabulario

GDD (`specs/gdd/`, modular) · Spike (investigación con timebox; produce evidencia, no código de producción) · Decisión/ADR (`specs/decisions/`) · Spec (criterios con ID) · Plan (diseño técnico: escenas, scripts, señales, Resources). **No usar la sigla "TDD"** en el repo.

## Stack

| Tema | Decisión |
|---|---|
| Motor | Godot 4.7.x estable, `godot` en el PATH |
| Lenguaje | GDScript (sin C#) |
| Renderer | `gl_compatibility` |
| Tile / resolución | 32 px · viewport 640×360, stretch `viewport` + `integer` (a validar en Spike 001) |
| Niveles | `TileMapLayer` nativo; sin LDtk ni editores externos |
| Arte | Pixelorama / LibreSprite. Greybox hasta que el sistema pase su `[feel]` |
| Unit tests | gdUnit4, solo lógica pura, headless: `godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test -c` (gdUnit4 v6.2.2; `--ignoreHeadlessMode` es seguro porque no testeamos input/UI) |
| Formato / lint | gdtoolkit (`gdformat`, `gdlint`), aplicado por hook en cada Write/Edit de `.gd` |
| MCP | `godot` (`@coding-solo/godot-mcp`): correr el proyecto y leer consola/errores |
| Skills | GodotPrompter (plugin `godot-prompter@skillsmith`) + skills de proceso en `.claude/skills/` |
| CI | Postergado |

## Principios del flujo

1. **Spike solo con incertidumbre relevante**: feel desconocido de mecánica central; ≥2 enfoques técnicos y elegir mal es caro; dudas de viabilidad/rendimiento; integración nueva. Si no, directo a spec.
   - Un solo spike abierto a la vez. Un spike está abierto si existe una branch `spike/*` (local o remota) o algún archivo en `specs/spikes/`; deja de estarlo cuando `close-spike` termina. El timebox se respeta: al vencer, detenete y proponé cerrar o **una** extensión.
   - El código de un spike **nunca llega a `develop` ni a `main`**: vive en `prototypes/spike_NNN/` en la branch `spike/NNN-*`.
2. **Todo spike termina en una decisión** en `specs/decisions/`, que luego actualiza GDD / arquitectura / spec. Las decisiones técnicas importantes fuera de spikes también se registran.
3. **Verificación en capas**; cada criterio declara la suya:
   - `[unit]`: gdUnit4 sobre lógica pura. Lo cierra el agente.
   - `[manual]`: resultado objetivo jugando. Lo cierra el desarrollador.
   - `[feel]`: subjetivo. **El agente nunca lo marca como cumplido.**
4. **Smoke run antes de entregar**: correr el juego vía MCP y confirmar consola sin errores antes de pedir playtest.
5. **Las specs son la fuente de verdad.** No cambies criterios, GDD ni decisiones aprobadas: si la spec es incorrecta o inviable, detenete y proponé el cambio.
6. **Trazabilidad**: criterios con ID (`F003-AC02`). Tests lo citan en el nombre (`test_f003_ac02_...`), tasks lo referencian, playtest lo marca. GDD → (spike → decisión) → spec → plan → tasks → tests/playtest → PR.
7. **Documentación mínima suficiente.** Features chicas sin incertidumbre usan la vía liviana (un solo `spec.md` con sección "Plan y tasks"). Vía completa si toca >1 sistema, crea un sistema nuevo o tiene `[feel]`.
8. **Niveles**: no edites `.tscn` en `game/levels/` salvo pedido explícito.
9. **Tuning**: todo valor ajustable vive en un Resource `.tres` en `game/data/`. El agente crea el `.tres` inicial de un Resource nuevo con los valores de la spec; desde ahí lo edita solo el desarrollador.
10. **Vivos vs registros**: vivos (`gdd/`, `architecture.md`, `spec.md`, `INDEX.md`, `backlog.md`) reflejan la verdad actual y nunca contienen ideas descartadas, decisiones reemplazadas ni preguntas resueltas. Registros (spikes, decisiones) no se editan una vez cerrados; al vencer van a `specs/archive/`. **Nada se borra**: se mueve a `archive/` o queda en git; lo descartado va en una línea a `specs/discarded.md`.
11. **Consolidar es parte de terminar**: nada está cerrado hasta que sus resultados se consolidaron en los documentos vivos.
12. **Aprobación explícita**: solo cuenta un mensaje del desarrollador que apruebe eso concreto. Silencio, falta de objeciones o un "ok" a otra cosa no es aprobación.
13. **Ante error, conflicto o precondición incumplida**: detenete y reportá qué falló, qué no hiciste y qué opciones hay. No improvises una alternativa.
14. **Vigencia**: `CLAUDE.md`, `.claude/skills/` y `specs/templates/` mandan. `specs/HANDOFF.md` es un registro del diseño original; ante diferencias, no se aplica.

## Arquitectura de código

**Lógica pura + nodo fino + config en Resource.**

- Lógica de juego en clases `RefCounted` sin dependencia del árbol, en `game/systems/`. Son las únicas con unit tests (`test/` es espejo de `game/systems/`).
- Nodos (`CharacterBody2D`, `Area2D`…) leen input, llaman a la lógica pura y aplican el resultado. Sin reglas.
- Parámetros ajustables: Resources tipados con `@export` (p. ej. `PlayerMovementConfig`), instanciados como `.tres` en `game/data/`.
- Comunicación entre sistemas por señales. Evitar `get_node()` con rutas largas. Autoloads: como máximo un bus de eventos y el estado global.
- Física a 60 ticks; movimiento en `_physics_process`.
- Debug overlay `game/debug/debug_overlay.tscn` (F3, acción `debug_toggle`): estado, velocidad, `is_on_floor`, timers, FPS. Cada sistema nuevo agrega sus líneas.
- Escenas: `game/main.tscn` es la raíz persistente y cambia de pantalla; `game/ui/` tiene los menús; `game/world/` es la escena activa mientras se juega (arma la partida con salas de `levels/` y entidades de `entities/`).
- Input map: `move_left`, `move_right`, `move_up`, `move_down`, `jump`, `dash` (reservado), `pause`, `debug_toggle`. Teclado y gamepad. Los menús navegan con las acciones `ui_*` de Godot.
- Textos: nunca escritos directo; cada texto visible es una etiqueta (`MENU_PLAY`) traducida en `game/i18n/texts.csv` (columnas `es`, `en`). Los nodos con texto fijo se traducen solos; el texto armado por código usa `tr()`.

## Estructura del repo

```
project.godot        # en la raíz
specs/               # tiene .gdignore
  gdd/ (vision.md, controls.md, mechanics/, art-direction.md)
  INDEX.md · architecture.md · backlog.md · discarded.md
  templates/ · spikes/ · decisions/ · features/NNN-nombre/ · archive/{spikes,decisions,features}/
game/ systems/ entities/ world/ levels/ ui/ i18n/ data/ art/ debug/ main.tscn
test/                # gdUnit4
addons/              # gdUnit4
prototypes/          # solo en branches spike/*
.claude/ settings.json · hooks/ · skills/ · agents/
```

- Los `.uid` **se commitean**. `.godot/` y los `*.import` no se editan a mano.

## Frontmatter de `specs/`

Todo documento (excepto `INDEX.md`, `discarded.md`, `backlog.md`, `HANDOFF.md` y `templates/`):

```yaml
---
id: F003            # F feature (FNNN), S spike (SNNN), D decisión (DNNNN), G sección del GDD, ARCH arquitectura
type: feature       # feature | spike | decision | gdd | architecture
status: draft       # draft | approved | in-progress | done | superseded | discarded
superseded_by:
links: { gdd: [], decisions: [], spike: }
updated: YYYY-MM-DD
---
```

Los criterios de aceptación viven en el cuerpo con su ID, no en el frontmatter.

**Numeración**: el siguiente número libre se calcula mirando `specs/`, `specs/archive/` **y** las branches (`git branch -a --list 'spike/*' 'feat/*'`) y tags `archive/spike-*`, porque un spike o feature en curso solo existe en su branch.

## Permisos sobre artefactos

| Artefacto | El agente puede | Aprueba / modifica |
|---|---|---|
| GDD | Proponer cambios | Desarrollador |
| Decisiones | Redactar propuesta | Desarrollador (aprobada no se edita; se reemplaza con una nueva) |
| `spec.md` | Redactar borrador | Desarrollador; una vez aprobada el agente solo propone |
| `plan.md`, `tasks.md` | Redactar y actualizar | Desarrollador revisa |
| Código, tests | Implementar | Revisión en PR |
| `playtest.md` | Generar checklist | Desarrollador marca `[manual]` y `[feel]` |
| Niveles, `.tres` de tuning | No tocar salvo pedido (excepción: crear el `.tres` inicial de un Resource nuevo) | Desarrollador |
| Consolidación y archivo | Vía `close-spike`, `close-feature`, `curate-specs`, siempre por PR | Desarrollador. **El agente nunca borra: mueve a `archive/`** |
| `INDEX.md`, `discarded.md` | Actualizar al consolidar | Desarrollador revisa en el PR |

## Ciclo de vida de los documentos

| Documento | Abierto | Al cerrarse |
|---|---|---|
| Spike (doc) | En la branch `spike/NNN-*`: `draft` (definición) → `approved` (en ejecución) → `done` (informe listo) | Decisión aprobada → `close-spike` lo lleva a `develop` por PR, ya en `archive/spikes/` |
| Spike (código) | `prototypes/spike_NNN/` en `spike/NNN-*` | Tag `archive/spike-NNN` + branch borrada (local y remota, con confirmación) |
| Decisión | `draft` (propuesta) en `specs/decisions/` | `approved` queda; `superseded` → `archive/decisions/` y los vivos apuntan a la nueva |
| Spec | En la branch `feat/NNN-*`: `draft` → `approved` → `in-progress` | `done` (ver regla abajo), consolidada *as-built*, queda en `features/` |
| Plan, tasks, playtest | Junto a la spec | `close-feature` → `archive/features/` |
| Feature descartada | — | Carpeta a `archive/features/` + línea en `discarded.md` |

**Spec as-built**: estado `done` solo si todos los criterios se cumplieron o cada desviación tiene aceptación explícita del desarrollador (registrada en "Notas finales"); criterios con resultado final, sin preguntas abiertas, tuning referenciando el `.tres` (no números copiados), sección corta "Notas finales".

## Git

Modelo `develop` + `main` (decisión `D0001`):

- `develop`: integración. Toda branch de trabajo sale de `develop` actualizado y vuelve por PR a `develop` (`gh pr create --base develop`).
- `main`: solo releases. PR `develop` → `main` titulado `release: vX.Y.Z` y, tras el merge, tag anotado `vX.Y.Z` en `main`; los builds de itch.io salen de un tag. El agente nunca abre un release sin pedido explícito.
- Hotfix: `hotfix/<nombre>` desde `main` → PR a `main` + tag de parche → merge de `main` a `develop`.
- Branches: `spike/NNN-nombre` (no se mergean; solo los docs llegan a `develop`), `feat/NNN-nombre`, `docs/*`, `chore/*`.
- PR con checklist de playtest; el desarrollador mergea después de jugar.
- No se usan las issues de GitHub: el avance de cada feature vive en su `tasks.md`.
- Commits convencionales: `feat:`, `fix:`, `spike:`, `docs:`, `chore:`.
