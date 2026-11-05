---
id: D0006
type: decision
status: approved
superseded_by:
links: { gdd: [], decisions: [D0001], spike: }
updated: 2026-11-05
---

# 0006: Dos directores, cada uno con su agente

- Origen: pedido del desarrollador (fuera de spikes y features). Aprobada en la conversación del 2026-11-05 ("Aprobado, arrancá"), después de elegir: decide quien pide la feature y la visión se acuerda entre los dos, una feature o spike por vez, y Copilot en VS Code sobre Windows.

## Contexto

Hasta ahora el juego lo dirigía una sola persona, con Claude Code, y la prueba de cada feature se tildaba en el checklist del PR de GitHub. El desarrollador va a compartir el proyecto con su hijo, que va a tener el mismo rol, no es técnico, probablemente no entre a GitHub y va a usar GitHub Copilot en VS Code sobre Windows. Las reglas vivían en `CLAUDE.md` y las skills en `.claude/skills/`. Según la documentación de VS Code (noviembre de 2026), Copilot lee `AGENTS.md` y busca las skills en `.github/skills/`, pero no confirma que lea `CLAUDE.md` ni `.claude/skills/`.

## Opciones consideradas

- **Mantener el flujo y que el hijo use GitHub**: no cambia nada, pero le pide a alguien no técnico leer PRs y tildar en GitHub, y las reglas no le llegan a Copilot.
- **Copiar las reglas para cada agente**: funciona enseguida, pero con dos copias que se van a desincronizar.
- **Reglas y skills compartidas, y todo en el chat**: una sola copia que leen los dos agentes, y el director solo habla con su agente. Cuesta adaptar las skills, y parte de la configuración de VS Code está en preview.

## Decisión

Reglas y skills compartidas, y todo en el chat:

- **Directores**: el director de una feature o un spike es quien lo pidió, y queda escrito en su documento. Aprueba la spec, el plan y la decisión, prueba y confirma el cierre. El GDD y las reglas del flujo se cambian solo con el acuerdo de los dos.
- **Un solo trabajo abierto a la vez entre los dos**: una feature o un spike.
- **Todo en el chat**: el agente explica en lenguaje llano lo que pide aprobar, guía la prueba y anota los resultados que le cuenta el director en `playtest.md`, que reemplaza al checklist del PR como fuente de verdad. Los PRs los abre y los mergea el agente, con la confirmación del director.
- **Una sola copia de las reglas**: `AGENTS.md`, que `CLAUDE.md` incluye. Las skills, en `.github/skills/`, con un enlace desde `.claude/skills`.
- **Formato del código**: paso explícito de `implement-task` (`gdformat` y `gdlint`). El hook de Claude Code pasa a la configuración local, para que Copilot en Windows no intente correrlo.
- **Copilot**: `.vscode/mcp.json` para correr Godot y `.vscode/settings.json` para usar Git Bash como terminal.

## Consecuencias (qué se actualiza: GDD, architecture.md, specs)

- `CLAUDE.md` pasa a `AGENTS.md`, con las secciones nuevas "Directores", "Cómo hablarle al director", "Herramientas por agente", "Probar el juego" y "Cuidados con git y GitHub". `CLAUDE.md` queda como un enlace a ese archivo, con lo propio de Claude Code.
- Las skills se mueven a `.github/skills/`: "desarrollador" pasa a "director", con la verificación de un solo trabajo abierto en `spec-feature` y `spike`, y `playtest-checklist` y `close-feature` usando los resultados de `playtest.md`.
- Plantillas `spec.md`, `spike.md` y `playtest.md`: línea `Director:` y sección "Resultados".
- `README.md`: guía para sumarse como director.
- Para verificar con la primera feature del segundo director, porque se configuró a partir de la documentación, sin probarlo: que Copilot cargue `AGENTS.md` y las skills, que el MCP de Godot arranque en Windows y que los comandos de las skills corran en Git Bash.
- Fuera del repo (lo hace el desarrollador): dar al segundo director acceso de escritura al repo en GitHub.
