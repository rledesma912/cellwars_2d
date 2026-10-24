---
id: F002
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-24
---

# Tasks: feature 002

- [ ] T1 Flujo de pantallas: estado Opciones y tests (cubre: F002-AC09)
- [ ] T2 `PlayerSettings` en lógica pura y tests (cubre: F002-AC01, F002-AC02, F002-AC03, F002-AC04, F002-AC05)
- [ ] T3 `SettingsStore`: leer y guardar en dos pasos, con tests (cubre: F002-AC06, F002-AC07, F002-AC08)
- [ ] T4 Traducciones: `game/i18n/texts.csv`, registro en el proyecto, textos de F001 pasados a etiquetas, carpeta `i18n/` documentada (cubre: F002-AC13)
- [ ] T5 Botón B del gamepad en `ui_cancel` (cubre: F002-AC14)
- [ ] T6 Escena `OptionsMenu` con bip de prueba (cubre: F002-AC10, F002-AC11, F002-AC12, F002-AC17)
- [ ] T7 `MainMenu`: botón Opciones y foco al volver (cubre: F002-AC10, F002-AC14)
- [ ] T8 `Main`: cargar, aplicar y guardar la configuración; conectar Opciones; smoke run (cubre: F002-AC11 a F002-AC16)
- [ ] T9 Playtest: `playtest.md` y PR (cubre: F002-AC10 a F002-AC17)

Los tests de gdUnit4 incluyen el ID en el nombre, por ejemplo `test_f002_ac01_defaults`.
