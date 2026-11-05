# CLAUDE.md — cellwars_2d

Las reglas del proyecto están en `AGENTS.md`, compartidas con GitHub Copilot (decisión `D0006`). Claude Code las carga desde acá:

@AGENTS.md

## Solo para Claude Code

- Las skills de proceso están en `.github/skills/`; `.claude/skills` es un enlace a esa carpeta. Editalas siempre en `.github/skills/`.
- El hook de formato (`.claude/hooks/gd-check.sh`) se configura en `.claude/settings.local.json`, que no se versiona, para que Copilot en Windows no intente correrlo. Igual seguí el paso de formato de `implement-task`.
- Antes de implementar un sistema de Godot, usá la skill `godot-prompter:*` del dominio, como dice `godot-conventions`.
