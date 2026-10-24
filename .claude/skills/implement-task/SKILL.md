---
name: implement-task
description: Implementa una task de una feature de cellwars_2d - primero los tests [unit] con gdUnit4, después el código, después smoke run vía MCP. Usala para cada task de tasks.md (o de "Plan y tasks" en la vía liviana).
---

# Implement task

Convenciones: skill `godot-conventions` (leela antes de escribir código).

Precondiciones: spec `approved` o `in-progress`; estás en la branch `feat/NNN-<nombre>`. Si la spec está `approved`, pasala a `in-progress` en la primera task.

## Pasos

1. **Leé** la task, los criterios que cubre y la sección del plan correspondiente. Invocá la skill `godot-prompter:*` del dominio y reportá el patrón elegido antes de construir, si no está ya decidido en el plan.
2. **Tests primero** (si la task cubre criterios `[unit]`):
   - En `test/` espejo de `game/systems/`, un test por criterio: `test_fnnn_acnn_<comportamiento>`.
   - Corré la suite y confirmá que los nuevos fallan por la razón esperada (no por error de parseo).
3. **Implementación**: lógica pura en `game/systems/`, nodo fino en `game/entities/`, parámetros en el Resource. Comentarios breves en decisiones de Godot no obvias.
   - Si hace falta un `.tres` nuevo en `game/data/`, crealo con los valores iniciales de la spec. Uno existente no se toca.
   - No edites `game/levels/` salvo que la task lo pida explícitamente.
   - Si un sistema nuevo tiene estado visible, agregá sus líneas al overlay F3.
4. **Verificación**:
   - Hook de formato/lint sin errores.
   - `godot --headless --import` si creaste `.gd`/`.tscn` (genera `.uid`).
   - Suite completa: `godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test -c` → exit 0.
   - Smoke run vía MCP (`run_project`, `get_debug_output`, `stop_project`): consola sin errores.
5. **Cierre de la task**: marcá `[x]` en `tasks.md`; commit convencional (`feat: ...` / `fix: ...`) que cite la task y los criterios (`T3, F001-AC02`).

## Si algo no encaja

- La spec es incorrecta o inviable → detenete y proponé el cambio. No modifiques criterios.
- El plan no funciona → actualizá `plan.md` explicando el cambio y avisá.
- Nunca marques `[manual]` ni `[feel]` como cumplidos.

Cuando todas las tasks de código estén cerradas, seguí con `playtest-checklist`.
