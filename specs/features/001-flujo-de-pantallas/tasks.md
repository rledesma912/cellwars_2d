---
id: F001
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-23
---

# Tasks: feature 001

- [ ] T1 Carpeta `game/screens/` en la estructura: `CLAUDE.md`, `godot-conventions`, `architecture.md` (y la acción `pause` en Input), README (cubre: —, condición del plan §8)
- [ ] T2 `ScreenFlow` en lógica pura + tests gdUnit4 (cubre: F001-AC01, F001-AC02, F001-AC03, F001-AC04, F001-AC05, F001-AC06, F001-AC07)
- [ ] T3 Acción `pause` en `project.godot` (Esc, Start) (cubre: F001-AC10, F001-AC11)
- [ ] T4 Escena `MainMenu` (cubre: F001-AC08, F001-AC13, F001-AC14)
- [ ] T5 Escena `GameScreen` placeholder con contador de tiempo (cubre: F001-AC09, F001-AC12)
- [ ] T6 Escena `PauseMenu` (cubre: F001-AC10, F001-AC11, F001-AC14)
- [ ] T7 `Main`: cablea flujo, pantallas, pausa y salir; smoke run vía MCP (cubre: F001-AC08 a F001-AC13, F001-AC15)
- [ ] T8 Playtest: `playtest.md` y PR (cubre: F001-AC08 a F001-AC15)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f001_ac01_starts_in_menu`.
