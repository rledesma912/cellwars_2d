---
name: godot-conventions
description: Convenciones de código y de estructura de cellwars_2d (lógica pura + nodo fino + Resource, ubicación de archivos, nombres, tests). Consultala antes de escribir o revisar cualquier .gd, .tscn o .tres del proyecto; la usan implement-task, plan-feature y spike.
---

# Convenciones Godot de cellwars_2d

Fuente de verdad vigente: `specs/architecture.md`. Esta skill la baja a reglas operativas. Si chocan, manda `architecture.md`.

Antes de implementar un sistema de Godot, invocá además la skill `godot-prompter:*` del dominio (p. ej. `player-controller`, `resource-pattern`, `state-machine`) y reportá el patrón elegido y el descartado.

- Si el patrón ya está fijado en `architecture.md`, en una decisión aprobada o en el `plan.md` de la feature, y sus supuestos no cambiaron, no vuelvas a consultarla: seguí lo documentado.
- Si una recomendación de GodotPrompter contradice `architecture.md` o una decisión aprobada, **señalá el conflicto y pedí una decisión**. No cambies la arquitectura por tu cuenta.

## Dónde va cada cosa

| Qué | Dónde | Tipo |
|---|---|---|
| Reglas de juego (motor de movimiento, daño, timers) | `game/systems/<sistema>/` | `RefCounted` con `class_name`, sin acceso al árbol |
| Escenas y scripts de nodos | `game/entities/<entidad>/` | Nodo fino: lee input, llama a la lógica, aplica el resultado |
| Definición de parámetros | `game/systems/<sistema>/<x>_config.gd` | `Resource` con `class_name` y `@export` tipados |
| Valores de tuning | `game/data/<x>.tres` | Instancia del Resource. **La crea el agente una vez con valores iniciales; después la edita solo el desarrollador** |
| Niveles | `game/levels/` | **No tocar** salvo pedido explícito |
| Debug overlay | `game/debug/` | Cada sistema nuevo agrega sus líneas |
| Tests | `test/` espejo de `game/systems/` (`test/player/player_motor_test.gd`) | `extends GdUnitTestSuite` |
| Prototipos de spike | `prototypes/spike_NNN/` | Solo en branches `spike/*`, nunca en `develop` ni en `main` |

## Reglas

1. **Lógica pura sin árbol.** Una clase de `game/systems/` no usa `get_node`, `Input`, `get_tree()`, señales de nodos ni autoloads. Recibe todo por parámetro (input ya leído, `on_floor`, `delta`) y devuelve el resultado. Si necesita estado (timers), lo guarda como campo.
2. **Nodo sin reglas.** Un script de `game/entities/` no tiene `if` de gameplay: traduce input a un valor, llama a la lógica y aplica (`velocity = ...; move_and_slide()`).
3. **Nada de números mágicos de tuning.** Todo valor ajustable es un `@export` de un Resource. Constantes físicas no ajustables (p. ej. tamaño de tile) van como `const` documentada.
4. **Física en `_physics_process`** (60 ticks). Nada de movimiento en `_process`.
5. **Señales para comunicar sistemas.** Evitar `get_node()` con rutas largas; preferir `@export var x: NodeType` o `%NombreUnico`. Autoloads: como máximo un bus de eventos y el estado global.
6. **Tipado estático siempre**: parámetros, retornos y variables (`var speed: float`, `:=` cuando el tipo es obvio).
7. **Comentarios didácticos**: el desarrollador está aprendiendo GDScript. Toda decisión de Godot no obvia lleva un comentario breve explicando el porqué (no el qué).

## Nombres

- Archivos y carpetas: `snake_case` (`player_motor.gd`, `player_movement.tres`).
- `class_name`: `PascalCase` igual al archivo (`PlayerMotor`).
- Señales: verbo en pasado (`jumped`, `landed`, `health_changed`).
- Privados: prefijo `_` (`_coyote_timer`).
- Tests: archivo `<clase>_test.gd`; función `test_<id_criterio>_<comportamiento>` en minúsculas, p. ej. `test_f001_ac01_coyote_time_allows_late_jump`. Tests sin criterio (utilidades): `test_<comportamiento>`.

## Verificación

- Formato y lint los aplica el hook en cada Write/Edit de `.gd`. Si el hook devuelve errores de `gdlint`, corregilos antes de seguir.
- Unit tests: `godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test -c` (exit 0 = todo pasó).
- Smoke run: MCP `godot` → `run_project`, `get_debug_output`, `stop_project`. Consola sin `ERROR`/`SCRIPT ERROR`.
- Archivos nuevos `.gd`/`.tscn`: después de crearlos, `godot --headless --import` genera sus `.uid`, que **se commitean**.
- Nunca editar a mano `.godot/` ni `*.import`.
