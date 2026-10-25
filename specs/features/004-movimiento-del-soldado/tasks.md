---
id: F004
type: feature
status: approved
superseded_by:
links: { gdd: [G001], decisions: [D0002, D0003], spike: S001 }
updated: 2026-10-25
---

# Tasks: feature 004

- [x] T1 `PlayerMovementConfig` con los parámetros nuevos, sus valores derivados y los valores por defecto de la spec; tests de config actualizados (cubre: F004-AC17)
- [ ] T2 `PlayerInput` con `jump_held`; `PlayerMotor` con estados para el piso: arrancar, frenar, girar quieto y girar corriendo; tests (cubre: F004-AC01, F004-AC02, F004-AC03, F004-AC04)
- [ ] T3 Salto en el motor: preparación, salto lleno, toque corto, soltar subiendo, caída más pesada, sin doble salto, mantener no repite; tests (cubre: F004-AC05, F004-AC06, F004-AC07, F004-AC08, F004-AC09, F004-AC10, F004-AC11)
- [ ] T4 Ayudas, aire y aterrizaje en el motor: coyote time, jump buffer, control reducido sin darse vuelta, aterrizaje normal y pesado, más los tests de los casos límite (cubre: F004-AC12, F004-AC13, F004-AC14, F004-AC15, F004-AC16)
- [ ] T5 `PlayerAnimation` (qué animación según el estado y velocidad para durar un tiempo); tests (cubre: F004-AC18, F004-AC19)
- [ ] T6 Arte provisorio y nodo:
  - `game/art/elyon/` con la tira y su `SpriteFrames`;
  - `player.tscn` con `AnimatedSprite2D` y cuerpo de 20 × 48;
  - `player.gd` con input sostenido, animación y `reset_to` del motor;
  - líneas nuevas en el overlay F3.

  (cubre: F004-AC20, F004-AC22, F004-AC23)
- [ ] T7 `game/data/player_movement.tres` con los valores iniciales (cambio único autorizado), simulación de la sala de prueba de entrada a salida apretando teclas y smoke run (cubre: F004-AC21, F004-AC24)
- [ ] T8 Playtest: checklist en el PR (cubre: F004-AC20, F004-AC21, F004-AC22, F004-AC23, F004-AC24, F004-AC25, F004-AC26)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f004_ac12_coyote_time_allows_late_jump`.
