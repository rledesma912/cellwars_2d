---
id: F002
type: feature
status: done
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-24
---

# Plan: feature 002

## Decisiones de diseño

Cada elección no obvia, con la alternativa descartada y el porqué.

1. **La configuración se guarda en JSON (`settings.json`), no con `ConfigFile` (`settings.cfg`).**
   - `ConfigFile` es la herramienta típica de Godot para opciones, pero su formato de texto puede describir objetos de Godot (`Object(...)`) que el motor arma al leer el archivo. Con un archivo manipulado eso es una puerta abierta.
   - JSON, por diseño, solo puede contener datos simples (números, texto, verdadero/falso, listas). Encaja con el pedido de guardado **seguro** de la spec.
   - **Requiere un ajuste chico en la spec**: el nombre del archivo pasa de `settings.cfg` a `settings.json`.
   - Los archivos `.tres` también quedan descartados para esto: pueden ejecutar código al cargarse.
2. **Dos clases de lógica pura separadas**: `PlayerSettings` (los valores y sus reglas: límites, idioma por defecto, conversión a decibeles) y `SettingsStore` (leer y escribir el archivo).
   - Así las reglas se prueban sin tocar el disco, y el guardado se prueba aparte con archivos temporales.
   - Descartado: una sola clase que haga todo; mezclaría reglas con archivos y los tests serían más frágiles.
3. **Sin autoload**: `Main` crea la configuración al arrancar, la aplica y se la pasa a la pantalla de opciones.
   - La alternativa típica es un autoload `Settings` accesible desde cualquier lado. Hoy solo la usan `Main` y Opciones, así que no hace falta; `architecture.md` limita los autoloads y conviene reservarlos.
4. **La pantalla de opciones no cambia la configuración**: igual que los otros menús, avisa ("movieron el volumen a 70") y `Main` decide: actualiza `PlayerSettings`, aplica el cambio y guarda solo si cambió.
5. **Guardado en dos pasos**: se escribe `settings.json.tmp`, se cierra, y se renombra a `settings.json`. Renombrar es instantáneo para el sistema operativo: o queda el archivo viejo entero o el nuevo entero, nunca uno a medias.
6. **El volumen se aplica al bus `Master`** (el canal de audio general de Godot) con `linear_to_db()`. En 0 % el bus se **silencia** (`set_bus_mute`) en vez de calcular decibeles, porque `linear_to_db(0)` da "menos infinito".
7. **Traducciones en CSV con etiquetas** (`game/i18n/texts.csv`), registrado en la configuración del proyecto. Los botones y textos muestran la traducción solos si su texto es una etiqueta; el contador de la partida, que arma su texto por código, usa `tr()`.
   - Idioma de respaldo del proyecto: inglés (si falta una traducción en español, muestra la inglesa).
   - Los archivos `.translation` que Godot genera al importar el CSV ya están en `.gitignore`: se regeneran solos.
8. **Selector de idioma con `OptionButton`** (una lista desplegable) con "Español" y "English". Los nombres de idioma no se traducen: cada uno se muestra en su propio idioma, que es la práctica habitual.
9. **El bip de prueba es un archivo WAV corto** generado una vez (tono de 880 Hz, 0,12 s, con fundido para que no haga clic). Lo reproduce la pantalla de opciones después de avisar el cambio de volumen, así ya suena con el volumen nuevo.
10. **Esc / botón B en Opciones**: la pantalla escucha la acción `ui_cancel` y avisa "volver". Se agrega el botón B del gamepad a `ui_cancel`, que de fábrica solo tiene Esc.
11. **Carpeta nueva `game/i18n/`** para las traducciones. Se documenta en `CLAUDE.md`, `godot-conventions` y README.

## Árbol de escenas

```
Main (Node) · main.gd                     # cambia: carga, aplica y guarda la configuración
├── Screen (Node)
│   └── (MainMenu, OptionsMenu o World, uno por vez)
└── PauseMenu (instancia)

MainMenu (Control) · main_menu.gd         # cambia: botón Opciones y foco al volver
└── CenterContainer
    └── VBoxContainer
        ├── TitleLabel (Label)            "Cellwars 2D"
        ├── PlayButton (Button)           MENU_PLAY
        ├── OptionsButton (Button)        MENU_OPTIONS
        └── QuitButton (Button)           MENU_QUIT

OptionsMenu (Control, Full Rect) · options_menu.gd
├── CenterContainer (Full Rect)
│   └── VBoxContainer
│       ├── TitleLabel (Label)            OPTIONS_TITLE
│       ├── FullscreenCheck (CheckButton) OPTIONS_FULLSCREEN
│       ├── VolumeRow (HBoxContainer)
│       │   ├── VolumeLabel (Label)       OPTIONS_VOLUME
│       │   ├── VolumeSlider (HSlider)    0–100, paso 10
│       │   └── VolumeValue (Label)       "70 %"
│       ├── LanguageRow (HBoxContainer)
│       │   ├── LanguageLabel (Label)     OPTIONS_LANGUAGE
│       │   └── LanguageSelect (OptionButton)  Español / English
│       └── BackButton (Button)           OPTIONS_BACK
└── TestBeep (AudioStreamPlayer)          test_beep.wav, bus Master
```

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/settings/player_settings.gd` (`PlayerSettings`) | Lógica pura | Valores (pantalla completa, volumen, idioma) con sus reglas: límites, idioma por defecto según el sistema, volumen a decibeles; los cambios devuelven si cambió algo. |
| `game/systems/settings/settings_store.gd` (`SettingsStore`) | Lógica pura con archivos | Lee `settings.json` validando el tipo de cada valor (si falta, está roto o un valor es inválido, usa el de fábrica) y lo escribe en dos pasos. Recibe la ruta por parámetro para poder probarlo con archivos temporales. |
| `game/systems/flow/screen_flow.gd` | Lógica pura | Suma el estado `OPTIONS` y los eventos `OPEN_OPTIONS` y `BACK`. |
| `game/main.gd` | Nodo | Al arrancar: carga y aplica la configuración. Muestra Opciones cuando corresponde. Ante cada aviso de Opciones: actualiza, aplica y guarda si cambió. |
| `game/ui/main_menu/main_menu.gd` | Nodo | Botón Opciones (`options_requested`) y `focus_options()` para volver con el foco ahí. |
| `game/ui/options_menu/options_menu.gd` | Nodo | Muestra los valores actuales, avisa cada cambio y "volver"; reproduce el bip. |
| `game/world/world.gd` | Nodo | El contador usa `tr("WORLD_ELAPSED")`. |
| `game/i18n/texts.csv` | Datos | Tabla de traducciones `keys,es,en`. |
| `project.godot` | Config | Traducciones registradas, idioma de respaldo `en`, botón B en `ui_cancel`. |

## Señales

| Señal | Emisor | Receptor | Payload |
|---|---|---|---|
| `options_requested` | `MainMenu` | `Main` | — |
| `fullscreen_toggled` | `OptionsMenu` | `Main` | `enabled: bool` |
| `volume_changed` | `OptionsMenu` | `Main` | `percent: int` |
| `language_selected` | `OptionsMenu` | `Main` | `code: String` (`"es"` / `"en"`) |
| `back_requested` | `OptionsMenu` | `Main` | — |

## Qué se testea con gdUnit4

`test/settings/player_settings_test.gd`:

- AC01 `test_f002_ac01_defaults`
- AC02 `test_f002_ac02_volume_is_clamped`
- AC03 `test_f002_ac03_volume_to_db`
- AC04 `test_f002_ac04_default_language_from_system`
- AC05 `test_f002_ac05_setting_same_value_reports_no_change`

`test/settings/settings_store_test.gd` (usa una carpeta temporal dentro de `user://` que se borra después de cada test):

- AC06 `test_f002_ac06_save_and_load_round_trip`
- AC07 `test_f002_ac07_missing_or_invalid_file_uses_defaults`
- AC08 `test_f002_ac08_save_leaves_no_temp_and_ignores_stale_temp`

`test/flow/screen_flow_test.gd`:

- AC09 `test_f002_ac09_options_from_menu_and_back`
- La tabla de transiciones válidas del test de F001-AC06 suma las dos nuevas (si no, ese test marcaría como "inválido" algo que ahora es válido).

## Impacto en overlay debug

Ninguno: el overlay todavía no existe.

## Riesgos

- **Renombrar sobre un archivo existente en Windows**: si el sistema no deja reemplazar al renombrar, se borra el viejo y se renombra (queda un instante sin archivo; si justo se corta, al abrir se usan valores por defecto, nunca un archivo a medias). Se verifica en Linux; en Windows queda para cuando haya exportación.
- **Pantalla completa con Wayland**: el cambio de modo de ventana puede comportarse distinto que en X11. Lo detecta AC11 en el playtest.
- **Textos más largos en un idioma**: los contenedores se ajustan solos; si algo se desborda, se ve en AC13.
