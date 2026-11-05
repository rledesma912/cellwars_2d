---
name: spike
description: Abre y conduce un spike (investigación de alcance acotado, sin límite de tiempo) en cellwars_2d - redacta la definición, pide aprobación, crea la branch spike/NNN-*, construye el prototipo mínimo, escribe el informe y propone la decisión. Usala cuando el director pida un spike o cuando spec-feature detecte incertidumbre relevante.
---

# Spike

Plantilla: `specs/templates/spike.md`. Decisión: `specs/templates/decision.md`.

## 0. Precondiciones (si alguna falla, detenete y avisá)

- **Un solo trabajo abierto** (ver "Directores" en `AGENTS.md`): `git fetch` y verificá que no exista ninguna branch `feat/*` ni `spike/*` (`git branch -a --list '*feat/*' '*spike/*'`) ni archivos en `specs/spikes/` (salvo `.gitkeep`). Si hay uno, decile al director quién lo tiene (línea `Director:` de su documento) y qué falta para cerrarlo, y detenete. Un spike en `done` esperando decisión o consolidación **sigue abierto**: si es tuyo, proponé terminarlo (decisión + `close-spike`).
- **Working tree limpio** y `develop` al día con `origin/develop`.
- **Justificación**: se cumple al menos uno de los criterios del principio 1 de `AGENTS.md` (feel desconocido de mecánica central; ≥2 enfoques y elegir mal es caro; viabilidad/rendimiento; integración nueva). Si no, recomendá ir directo a `spec-feature`.
- **No descartado**: buscá el tema en `specs/discarded.md`. Si aparece, solo seguís si hay un motivo nuevo, y lo escribís en "Motivo".

## 1. Definición

1. Número: siguiente `NNN` libre mirando `specs/archive/spikes/`, las branches `spike/*` y los tags `archive/spike-*` (3 dígitos, desde `001`). Id `SNNN`.
2. Creá la branch `spike/NNN-<nombre>` desde `develop` y en ella `specs/spikes/NNN-<nombre>.md` desde la plantilla, `status: draft`. Completá solo frontmatter, encabezado (con `- Director: <nombre>`, quien lo pidió) y **Definición**:
   - Pregunta en una frase, criterios de salida observables, alternativas a comparar. Sin timebox: el alcance es el límite.
   - Leé antes el GDD relevante (`specs/gdd/`) y `architecture.md`.
3. Commit `spike: definición SNNN` y push (así el spike queda visible como abierto).
4. Explicá la definición en el chat, en lenguaje llano, y **pedí la aprobación explícita** de su director. No escribas código hasta tenerla. Si el director la rechaza, la branch queda para que él decida (no la borres).

## 2. Ejecución (en la branch del spike)

1. Al aprobarse: `status: approved`, `updated`, commit.
2. Prototipo mínimo en `prototypes/spike_NNN/` (escena propia, ejecutable con `run_project` + `scene`). Es código descartable: priorizá velocidad de iteración, pero seguí la forma lógica pura + Resource cuando lo que se mide es tuning (así los valores se trasladan).
3. Valores de tuning en un Resource `.tres` dentro de `prototypes/spike_NNN/` para que el director itere en el inspector.
4. Smoke run vía MCP antes de pedir que pruebe. Pedí playtest con qué mirar y qué variantes comparar.
5. **Alcance**: cuando se cumplan los criterios de salida, proponé cerrar. Si surge algo fuera de la pregunta o de las alternativas, no lo sumes por tu cuenta: anotalo y proponé (a) sumarlo al spike o (b) mandarlo al backlog. Decide el director.

## 3. Informe y decisión

1. Completá en el doc del spike: Qué se construyó, Evidencia y findings (incluí lo que dijo el director en el playtest), Valores de tuning que funcionaron, Riesgos, Recomendación, Siguiente paso. `status: done`.
2. Redactá la decisión `specs/decisions/NNNN-<titulo>.md` desde la plantilla (id `DNNNN`, 4 dígitos, siguiente libre mirando `specs/decisions/`, `archive/decisions/` y las branches abiertas), `status: draft`, `links.spike: SNNN`. Opciones con pros/contras basados en la evidencia; Consecuencias = lista concreta de qué documentos vivos cambiar.
3. Commiteá en la branch (`spike: informe SNNN y propuesta DNNNN`) y pushea.
4. Explicale la decisión en el chat, en lenguaje llano, y pedile al director del spike que la apruebe. Con la aprobación explícita, seguí con la skill `close-spike`. Hasta entonces el spike sigue abierto.

## Reglas

- Nunca marcar `[feel]` como cumplido; registrá lo que reporta el director.
- El código de `prototypes/` nunca llega a `develop` ni a `main`.
- No modifiques GDD ni `architecture.md` durante el spike: eso lo hace `close-spike`.
