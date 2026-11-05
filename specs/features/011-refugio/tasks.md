---
id: F011
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-11-04
---

# Tasks: feature 011

- [x] T1 `LevelProgress.finishes_level()`, y `apply()` deja de volver a la sala 1 desde la última salida (cubre: F011-AC01, F011-AC02)
- [x] T2 Estado "nivel completado" en `ScreenFlow` (cubre: F011-AC03, F011-AC04)
- [ ] T3 Cartel `LevelCompleteMenu` con sus textos, señal de `World` y conexión en `Main` (cubre: F011-AC05, F011-AC06, F011-AC07, F011-AC08)
- [ ] T4 Marca de la salida en la sala 3 (cubre: F011-AC09)
- [ ] T5 Playtest entrando por el menú principal (cubre: F011-AC05, F011-AC06, F011-AC07, F011-AC08, F011-AC09)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f011_ac01_last_exit_finishes_level_without_changing_room`.
