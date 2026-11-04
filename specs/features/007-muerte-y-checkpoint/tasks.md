---
id: F007
type: feature
status: draft
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0005], spike: }
updated: 2026-11-04
---

# Tasks: feature 007

- [x] T1 Config "Muerte" y estado `DEAD` del motor, con sus tests (cubre: F007-AC01, F007-AC02, F007-AC03, F007-AC04)
- [x] T2 `LevelProgress.checkpoint()` y `apply(VOID)` sin reinicio, con sus tests (cubre: F007-AC06)
- [x] T3 Arte `morir` en `elyon.png` y `elyon_frames.tres`, regla en `PlayerAnimation`, con sus tests (cubre: F007-AC05)
- [x] T4 `Player`: `die`, `is_dead`, señal `death_finished`, último cuadro de `morir`, nombre en el overlay (cubre: F007-AC07, F007-AC08)
- [x] T5 Escena `MortalZone` (cubre: F007-AC07, F007-AC14)
- [x] T6 `World`: el vacío mata, ignora bordes mientras está muerto, vuelve al checkpoint (cubre: F007-AC09, F007-AC10, F007-AC11)
- [ ] T7 Zonas en las tres salas de prueba (cubre: F007-AC12)
- [ ] T8 Smoke run, copia de prueba y playtest (cubre: F007-AC07, F007-AC08, F007-AC09, F007-AC10, F007-AC11, F007-AC12, F007-AC13, F007-AC14)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f007_ac04_dying_again_keeps_remaining_time`.
