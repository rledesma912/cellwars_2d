# AGENTS.md — cellwars_2d

Plataformas 2D en pixel art con Godot. Nombre visible **Cellwars 2D**; nombre técnico **`CW_2D`**. Todo open source.

Estas reglas valen para cualquier agente que trabaje en el repo: Claude Code y GitHub Copilot en VS Code (decisión `D0006`). Lo propio de cada uno está en "Herramientas por agente".

## Directores

El juego tiene **dos directores**, que deciden qué se construye, aprueban y prueban. Cada uno trabaja con su propio agente, y ninguno tiene por qué ser técnico ni entrar a GitHub.

- **El director de la sesión** es la persona con la que estás hablando. Si no sabés quién es, mirá `git config user.name` o preguntale.
- **El director de una feature o un spike** es quien lo pidió, y queda escrito en la línea `Director:` del documento. Él aprueba la spec, el plan y la decisión, prueba el juego y confirma el cierre. Si el otro director opina, anotalo, pero decide el de la feature.
- **El GDD (`specs/gdd/`) y las reglas del flujo** (este archivo, las skills y las plantillas) se cambian solo si el director de la sesión dice que lo acordó con el otro. Anotá ese acuerdo en el documento o en el PR.
- **Un solo trabajo abierto a la vez entre los dos**: una feature o un spike. Antes de abrir uno, hacé `git fetch` y mirá si existe alguna branch `feat/*` o `spike/*` (local o remota) o algún archivo en `specs/spikes/`. Si lo hay, decile al director quién lo tiene y qué falta para cerrarlo, y no abras otro. Las branches `docs/*` y `chore/*` chicas pueden convivir, salvo que toquen los mismos archivos que el trabajo abierto.

## Cómo hablarle al director

- **Todo pasa en el chat.** Nunca le pidas que abra GitHub, lea un PR o tilde algo ahí. El PR existe, pero lo manejás vos.
- **Lenguaje llano.** Primero el contexto (qué problema hay y por qué importa), después la idea en palabras simples, y recién después el término técnico, definido la primera vez. Usá ejemplos del propio juego. No nombres herramientas (branch, PR, commit, issue) sin decir qué son y para qué sirven acá.
- **Mostrá en el chat lo que pedís aprobar**: un resumen de la spec, el plan o la decisión, con sus criterios en palabras simples, y el archivo para quien quiera leerlo entero.
- **Explicá las decisiones de Godot que no sean obvias**, en comentarios breves en el código y en el PR. Los directores están aprendiendo.

## Reglas de lectura

- Para entender el estado del juego, empezá por `specs/INDEX.md`.
- Ignorá `specs/archive/` salvo que se pida investigar historia.
- Antes de proponer una mecánica o enfoque, revisá `specs/discarded.md`. Si está ahí, solo se reabre con un motivo nuevo y explícito.
- Documento de diseño del flujo completo: `specs/HANDOFF.md`.

## Vocabulario

GDD (`specs/gdd/`, modular) · Spike (investigación de alcance acotado, sin límite de tiempo; produce evidencia, no código de producción) · Decisión/ADR (`specs/decisions/`) · Spec (criterios con ID) · Plan (diseño técnico: escenas, scripts, señales, Resources) · Director (ver arriba). **No usar la sigla "TDD"** en el repo.

## Stack

| Tema | Decisión |
|---|---|
| Motor | Godot 4.7.x estable, `godot` en el PATH |
| Lenguaje | GDScript (sin C#) |
| Renderer | `gl_compatibility` |
| Tile / resolución | 20 px, sala de 64 × 36 tiles · viewport 1280×720, stretch `canvas_items` fraccional con *sharp bilinear* por sprite · soldado de 77 px (`D0005`) |
| Niveles | `TileMapLayer` nativo; sin LDtk ni editores externos |
| Arte | Pixelorama / LibreSprite. Greybox hasta que el sistema pase su `[feel]` |
| Unit tests | gdUnit4, solo lógica pura, headless: `godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test -c` (gdUnit4 v6.2.2; `--ignoreHeadlessMode` es seguro porque no testeamos input/UI) |
| Formato / lint | gdtoolkit (`gdformat`, `gdlint`) sobre cada `.gd` que escribís, antes del commit (skill `implement-task`) |
| MCP | `godot` (`@coding-solo/godot-mcp`): correr el proyecto y leer consola/errores |
| Skills | De proceso, en `.github/skills/`. GodotPrompter, si tu agente lo tiene |
| CI | Postergado |

## Herramientas por agente

| | Claude Code | Copilot en VS Code |
|---|---|---|
| Instrucciones | `CLAUDE.md`, que incluye este archivo | Este archivo |
| Skills | `.claude/skills/`, enlace a `.github/skills/` | `.github/skills/` |
| Formato y lint | Además, un hook local lo corre en cada edición (`.claude/hooks/gd-check.sh`) | A mano, como dice `implement-task` |
| MCP `godot` | `.mcp.json` | `.vscode/mcp.json`; pide la ruta de Godot la primera vez |
| GodotPrompter | Plugin `godot-prompter@skillsmith` | No disponible |
| Terminal | bash | Git Bash (`.vscode/settings.json`), así los comandos de las skills funcionan igual |

Lo que es propio de una sola máquina (rutas, una copia del juego en otra PC, scripts personales) va en la memoria o las instrucciones personales de cada agente, nunca en este archivo.

## Principios del flujo

1. **Spike solo con incertidumbre relevante**: feel desconocido de mecánica central; ≥2 enfoques técnicos y elegir mal es caro; dudas de viabilidad/rendimiento; integración nueva. Si no, directo a spec.
   - Cuenta como el único trabajo abierto (ver "Directores"). Un spike está abierto si existe una branch `spike/*` (local o remota) o algún archivo en `specs/spikes/`; deja de estarlo cuando `close-spike` termina. Sin límite de tiempo: lo que lo acota es su alcance (pregunta, alternativas y criterios de salida). Al cumplirse los criterios de salida, proponé cerrar; si aparece algo fuera del alcance, anotalo y proponé si se suma o va al backlog. Cierra su director.
   - El código de un spike **nunca llega a `develop` ni a `main`**: vive en `prototypes/spike_NNN/` en la branch `spike/NNN-*`.
2. **Todo spike termina en una decisión** en `specs/decisions/`, que luego actualiza GDD / arquitectura / spec. Las decisiones técnicas importantes fuera de spikes también se registran.
3. **Verificación en capas**; cada criterio declara la suya:
   - `[unit]`: gdUnit4 sobre lógica pura. Lo cierra el agente.
   - `[manual]`: resultado objetivo jugando. Lo cierra el director.
   - `[feel]`: subjetivo. **El agente nunca lo marca como cumplido.**
4. **Smoke run antes de entregar**: correr el juego vía MCP y confirmar consola sin errores antes de pedir playtest.
5. **Las specs son la fuente de verdad.** No cambies criterios, GDD ni decisiones aprobadas: si la spec es incorrecta o inviable, detenete y proponé el cambio.
6. **Trazabilidad**: criterios con ID (`F003-AC02`). Tests lo citan en el nombre (`test_f003_ac02_...`), tasks lo referencian, playtest lo marca. GDD → (spike → decisión) → spec → plan → tasks → tests/playtest → PR.
7. **Documentación mínima suficiente.** Features chicas sin incertidumbre usan la vía liviana (un solo `spec.md` con sección "Plan y tasks", más su `playtest.md`). Vía completa si toca >1 sistema, crea un sistema nuevo o tiene `[feel]`.
8. **Niveles**: no edites `.tscn` en `game/levels/` salvo pedido explícito. Excepción: las salas de prueba de `game/levels/test/` las crea y edita el agente.
9. **Tuning**: todo valor ajustable vive en un Resource `.tres` en `game/data/`. El agente crea el `.tres` inicial de un Resource nuevo con los valores de la spec; desde ahí los valores los decide solo un director: los cambia él en el inspector o le dicta al agente el valor exacto.
10. **Vivos vs registros**: vivos (`gdd/`, `architecture.md`, `spec.md`, `INDEX.md`, `backlog.md`) reflejan la verdad actual y nunca contienen ideas descartadas, decisiones reemplazadas ni preguntas resueltas. Registros (spikes, decisiones) no se editan una vez cerrados; al vencer van a `specs/archive/`. **Nada se borra**: se mueve a `archive/` o queda en git; lo descartado va en una línea a `specs/discarded.md`.
11. **Consolidar es parte de terminar**: nada está cerrado hasta que sus resultados se consolidaron en los documentos vivos.
12. **Aprobación explícita**: solo cuenta un mensaje en el chat del director que corresponda que apruebe eso concreto. Citalo en el commit o el PR. Silencio, falta de objeciones o un "ok" a otra cosa no es aprobación.
13. **Ante error, conflicto o precondición incumplida**: detenete y reportá qué falló, qué no hiciste y qué opciones hay. No improvises una alternativa.
14. **Vigencia**: `AGENTS.md`, `.github/skills/` y `specs/templates/` mandan. `specs/HANDOFF.md` es un registro del diseño original; ante diferencias, no se aplica.

## Probar el juego

- **Cómo se prueba**: el director juega la versión de la branch de la feature. Por defecto, en la misma máquina: dejá el repo en esa branch, con todo commiteado, y abrí el juego con `godot --path .`. Si un director prueba en otra máquina, cómo llevarle la copia va en las instrucciones personales de su agente.
- **Qué pedirle**: explicá en el chat los pasos de `playtest.md`, uno por criterio, y qué tiene que ver en cada uno.
- **Cómo registrar el resultado**: el director te cuenta cómo le fue, con sus palabras. Vos lo anotás en la sección "Resultados" de `playtest.md`: por criterio, cumplido o no, con lo que dijo y la fecha. **Nunca deduzcas un resultado que el director no dijo**; si falta alguno, preguntá. `playtest.md` es la fuente de verdad que lee `close-feature`.

## Cuidados con git y GitHub

Los hace el agente, porque los directores no entran a GitHub:

- **Antes de mergear un PR**, en un comando aparte, compará `gh pr view <N> --json headRefOid` con `git rev-parse HEAD`. Si no coinciden, el push todavía no llegó: esperá y volvé a mirar.
- **Antes de un paso posterior a un merge**, confirmá con `gh pr view <N> --json state` que el PR que esperás figura `MERGED`.
- **Antes de borrar una branch mergeada**, en un comando aparte, `git log origin/develop..<branch>` tiene que salir vacío. Leé la salida antes de borrar, y borrá con `git branch -d`, nunca con `-D`. No encadenes el chequeo con el borrado.

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
- Textos: nunca escritos directo (excepción: el overlay de debug, herramienta de desarrollo, va en castellano sin traducir); cada texto visible es una etiqueta (`MENU_PLAY`) traducida en `game/i18n/texts.csv` (columnas `es`, `en`). Los nodos con texto fijo se traducen solos; el texto armado por código usa `tr()`.

## Nombres del juego

- **Cellwars 2D**: solo donde lo ve el jugador (título del menú, de la ventana, página de itch.io).
- **`CW_2D`**: todo lo técnico, sin espacios: directorio de datos del jugador, nombres de archivos exportados (`CW_2D-v0.1.0-windows.zip`), identificadores y prefijos.

## Estructura del repo

```
project.godot        # en la raíz
AGENTS.md            # estas reglas · CLAUDE.md las incluye para Claude Code
specs/               # tiene .gdignore
  gdd/ (vision.md, controls.md, mechanics/, art-direction.md)
  INDEX.md · architecture.md · backlog.md · discarded.md
  templates/ · spikes/ · decisions/ · features/NNN-nombre/ · archive/{spikes,decisions,features}/
game/ systems/ entities/ world/ levels/ ui/ i18n/ data/ art/ debug/ main.tscn
test/                # gdUnit4
addons/              # gdUnit4
prototypes/          # solo en branches spike/*
.github/skills/      # skills de proceso, compartidas
.claude/ settings.json · hooks/ · agents/ · skills (enlace a .github/skills)
.vscode/ mcp.json · settings.json   # para Copilot
.mcp.json            # MCP para Claude Code
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

Los criterios de aceptación viven en el cuerpo con su ID, no en el frontmatter. Las specs y los spikes llevan en el encabezado la línea `- Director: <nombre>`.

**Numeración**: el siguiente número libre se calcula mirando `specs/`, `specs/archive/` **y** las branches (`git branch -a --list 'spike/*' 'feat/*'`) y tags `archive/spike-*`, porque un spike o feature en curso solo existe en su branch.

## Permisos sobre artefactos

| Artefacto | El agente puede | Aprueba / modifica |
|---|---|---|
| GDD | Proponer cambios | Los dos directores, de acuerdo |
| Decisiones | Redactar propuesta | Director del spike o la feature; las del flujo, los dos de acuerdo (aprobada no se edita; se reemplaza con una nueva) |
| `spec.md` | Redactar borrador | Director de la feature; una vez aprobada el agente solo propone |
| `plan.md`, `tasks.md` | Redactar y actualizar | Director de la feature revisa |
| Código, tests | Implementar | Revisión en PR |
| `playtest.md` | Generar los pasos y anotar los resultados que dice el director | Director de la feature cierra `[manual]` y `[feel]` |
| Niveles, `.tres` de tuning | No tocar salvo pedido (excepciones: crear el `.tres` inicial de un Resource nuevo; las salas de prueba de `game/levels/test/`) | Directores |
| Consolidación y archivo | Vía `close-spike`, `close-feature`, `curate-specs`, siempre por PR | Director que corresponda. **El agente nunca borra: mueve a `archive/`** |
| `INDEX.md`, `discarded.md` | Actualizar al consolidar | Director que corresponda |

## Ciclo de vida de los documentos

| Documento | Abierto | Al cerrarse |
|---|---|---|
| Spike (doc) | En la branch `spike/NNN-*`: `draft` (definición) → `approved` (en ejecución) → `done` (informe listo) | Decisión aprobada → `close-spike` lo lleva a `develop` por PR, ya en `archive/spikes/` |
| Spike (código) | `prototypes/spike_NNN/` en `spike/NNN-*` | Tag `archive/spike-NNN` + branch borrada (local y remota, con confirmación) |
| Decisión | `draft` (propuesta) en `specs/decisions/` | `approved` queda; `superseded` → `archive/decisions/` y los vivos apuntan a la nueva |
| Spec | En la branch `feat/NNN-*`: `draft` → `approved` → `in-progress` | `done` (ver regla abajo), consolidada *as-built*, queda en `features/` |
| Plan, tasks, playtest | Junto a la spec | `close-feature` → `archive/features/` |
| Feature descartada | — | Carpeta a `archive/features/` + línea en `discarded.md` |

**Spec as-built**: estado `done` solo si todos los criterios se cumplieron o cada desviación tiene aceptación explícita del director (registrada en "Notas finales"); criterios con resultado final, sin preguntas abiertas, tuning referenciando el `.tres` (no números copiados), sección corta "Notas finales".

## Git

Modelo `develop` + `main` (decisión `D0001`):

- `develop`: integración. Toda branch de trabajo sale de `develop` actualizado y vuelve por PR a `develop` (`gh pr create --base develop`).
- `main`: solo releases. PR `develop` → `main` titulado `release: vX.Y.Z` y, tras el merge, tag anotado `vX.Y.Z` en `main`; los builds de itch.io salen de un tag. El agente nunca abre un release sin pedido explícito.
- Hotfix: `hotfix/<nombre>` desde `main` → PR a `main` + tag de parche → merge de `main` a `develop`.
- Branches: `spike/NNN-nombre` (no se mergean; solo los docs llegan a `develop`), `feat/NNN-nombre`, `docs/*`, `chore/*`.
- **Un PR por feature.** Al terminar, el agente avisa: *"Todo finalizado, espero tu test y confirmación para mergear."*, y le explica en el chat qué probar. El director juega, le cuenta los resultados y confirma; el agente los anota en `playtest.md`, hace el cierre (`close-feature`) como último commit de esa misma branch y mergea. Si el PR se mergeó antes, el cierre va en un PR chico aparte.
- Los PRs los abre y los mergea el agente, con la confirmación del director en el chat. No se usan las issues de GitHub: el avance de cada feature vive en su `tasks.md`.
- Commits convencionales: `feat:`, `fix:`, `spike:`, `docs:`, `chore:`.
