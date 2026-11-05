---
id: F010
type: feature
status: draft
superseded_by:
links: { gdd: [vision], decisions: [D0003, D0005], spike: }
updated: 2026-11-04
---

# Tasks: feature 010

- [x] T1 Parámetros `long_fall_height` y `lethal_fall_height` en `PlayerMovementConfig` (cubre: F010-AC01, F010-AC05)
- [x] T2 Muerte por altura en el motor: `DeathCause.FALL`, `FallSeverity`, altura congelada al morir y `reset_fall()` (cubre: F010-AC01, F010-AC02, F010-AC03, F010-AC04, F010-AC17)
- [x] T3 Arte nuevo en `elyon.png` y `elyon_frames.tres` (cubre: F010-AC09)
- [x] T4 `PlayerAnimation` elige `caer_largo` y `morir_caida`, con `holds_last_frame()` (cubre: F010-AC05, F010-AC06, F010-AC07, F010-AC08)
- [ ] T5 `Player` aplica lo anterior y suma la línea `caída` al overlay; `World` llama a `reset_fall()` al cruzar de sala (cubre: F010-AC06, F010-AC08, F010-AC17)
- [ ] T6 Sala de prueba con caída de dos pisos sobre piso común (cubre: F010-AC11)
- [ ] T7 Playtest en la copia de la laptop (cubre: F010-AC10, F010-AC11, F010-AC12, F010-AC13, F010-AC14, F010-AC15, F010-AC16, F010-AC18)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f010_ac01_lethal_landing_dies_with_death_time`.
