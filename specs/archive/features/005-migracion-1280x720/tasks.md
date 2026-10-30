---
id: F005
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0004], spike: S002 }
updated: 2026-10-29
---

# Tasks: feature 005

- [x] T1 `RoomGeometry` a 64 × 36 y `project.godot`: viewport 1280×720, `canvas_items` fraccional, aspecto `keep`, snap en `false`. Tests de sala actualizados (cubre: F005-AC01, F005-AC03)
- [x] T2 `PixelScale` (lógica pura) con su test (cubre: F005-AC02)
- [x] T3 Shader `sharp_pixel`, material compartido, uniform global en `project.godot` y `Main` que publica la escala al arrancar y al cambiar el tamaño de la ventana. Línea "escala pixel art" en F3 (cubre: F005-AC04, F005-AC05)
- [x] T4 Valores por defecto de `PlayerMovementConfig` × 2,2, `player_movement.tres` con los mismos valores y tests (cubre: F005-AC07, F005-AC08, F005-AC10)
- [x] T5 Elyon de 99 px: imágenes y `SpriteFrames` en `game/art/elyon/`, sprite, offset, colisión de 44 × 106 y material en `player.tscn` (cubre: F005-AC06, F005-AC09)
- [x] T6 Sala de prueba al doble (64 × 36, `Spawn` en (80, 680), fondo 1280×720) con el material en las baldosas (cubre: F005-AC06, F005-AC11, F005-AC12)
- [x] T7 Menús principal, pausa y opciones, y overlay de debug al doble (cubre: F005-AC13, F005-AC14, F005-AC15)
- [ ] T8 Playtest: `playtest.md` y PR con el checklist (cubre: F005-AC03 a AC06 y AC09 a AC17 jugando)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f005_ac02_pixel_scale_for_window`.
