---
id: F003
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0002], spike: }
updated: 2026-10-24
---

# Tasks: feature 003

- [ ] T1 `PlayerMovementConfig` con valores derivados y test (cubre: F003-AC06)
- [ ] T2 `PlayerInput` y `PlayerMotor` en lógica pura, con tests (cubre: F003-AC01, F003-AC02, F003-AC03, F003-AC04, F003-AC05)
- [ ] T3 `RoomGeometry` con las medidas de D0002 y tests (cubre: F003-AC10)
- [ ] T4 Baldosa greybox, `TileSet` con colisión y sala de prueba `test_room.tscn` (cubre: F003-AC07, F003-AC09)
- [ ] T5 Escena `Player` y `player_movement.tres` inicial (cubre: F003-AC08, F003-AC13)
- [ ] T6 `World` arma la partida: sala, personaje en `Spawn`, reubicación al caer; se quitan las etiquetas `WORLD_*` (cubre: F003-AC07, F003-AC10, F003-AC11)
- [ ] T7 Overlay de debug con F3; smoke run (cubre: F003-AC12)
- [ ] T8 Playtest: `playtest.md` y PR (cubre: F003-AC07 a F003-AC13)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f003_ac03_jump_reaches_jump_height`.
