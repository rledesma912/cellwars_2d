---
id: F012
type: feature
status: draft
superseded_by:
links: { gdd: [G001, G003], decisions: [D0006, D0007], spike: S003 }
updated: 2026-11-20
---

# Tasks: feature 012 (disparo)

- [ ] T1 `ShootConfig` (`game/systems/combat/shoot_config.gd`) y `game/data/shoot.tres` con los valores del spike (cubre: F012-AC03, F012-AC06)
- [ ] T2 `ShootLogic` y sus tests: ángulo, dirección, boca, gatillo automático con tope, situaciones y tiempo de pose (cubre: F012-AC01, F012-AC02, F012-AC03, F012-AC04, F012-AC05, F012-AC06)
- [ ] T3 `ProjectileFlight` y sus tests: tramo por paso, resguardo y fin al alcance (cubre: F012-AC07)
- [ ] T4 Input map: acción `shoot` (`J`, `X`, botón X) y `dash` al botón B; nombre de la capa 1 de física; `architecture.md` y `CLAUDE.md` al día (cubre: F012-AC08)
- [ ] T5 Hoja Elyon2 en `game/art/elyon/` (desde el tag `archive/spike-003`) y `PlayerAnimation.shot_animation` con su test; revisar duraciones y pies (cubre: F012-AC15, F012-AC16)
- [ ] T6 `Projectile` (escena y nodo) con rayo por tramo (cubre: F012-AC13)
- [ ] T7 Player dispara: lee el input, llama a `ShootLogic`, emite `shot_fired`, pose de disparo de pie, línea `Gun` y líneas de F3 (cubre: F012-AC09, F012-AC10, F012-AC11, F012-AC12, F012-AC15, F012-AC17)
- [ ] T8 World: contenedor `Projectiles`, crea el proyectil al recibir `shot_fired` y lo vacía al cambiar de sala y al volver a la entrada (cubre: F012-AC13, F012-AC14)
- [ ] T9 Mapa del código en `architecture.md` (sistema `combat`, señal `shot_fired`, entidad `Projectile`)
- [ ] T10 Smoke run y playtest: `playtest.md` y PR con el checklist (cubre: F012-AC08 a F012-AC18)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f012_ac03_auto_fires_seven_shots_in_sixty_steps`.
