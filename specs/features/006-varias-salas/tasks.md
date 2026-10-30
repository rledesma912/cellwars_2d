---
id: F006
type: feature
status: approved
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0004], spike: }
updated: 2026-10-30
---

# Tasks: feature 006 — varias salas y el paso entre ellas

- [x] T1 `RoomGeometry`: enum `Edge` y `crossed_edge()`; `is_outside_room()` reescrita encima. Tests primero. (cubre: F006-AC03)
- [x] T2 `LevelProgress` con `apply(outcome) -> RoomChange`: avance, vuelta, bordes de la lista y si conserva el movimiento. Tests primero. (cubre: F006-AC01, F006-AC02, F006-AC05)
- [x] T3 `RoomExits`: `resolve()`, `arrival()`, `opposite()` y `validate()`. Tests primero. (cubre: F006-AC04, F006-AC05, F006-AC06)
- [x] T4 `LevelData` (Resource) y `Room` (script de la raíz de una sala). `test_room.tscn` pasa a `test_room_1.tscn` con `Entrance`/`Exit` y sus lados (izquierda → derecha). (cubre: F006-AC07)
- [x] T5 Salas `test_room_2.tscn` (izquierda → abajo) y `test_room_3.tscn` (arriba → derecha) en greybox, 3 pisos y escalones de hasta 4 baldosas, con las aberturas alineadas. `test_level.tres` con las 3. Test de validación del nivel real. (cubre: F006-AC06, F006-AC07)
- [ ] T6 `World`: carga el nivel, cambia de sala al cruzar, precarga las vecinas, resetea en el vacío y en los bordes de la lista. Línea "sala: N / M" en F3. Smoke run. (cubre: F006-AC08, F006-AC09, F006-AC10, F006-AC11, F006-AC12, F006-AC13)
- [ ] T7 Playtest y PR. (cubre: F006-AC07, F006-AC08, F006-AC09, F006-AC10, F006-AC11, F006-AC12, F006-AC13, F006-AC14)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f006_ac03_crossed_edge`.
