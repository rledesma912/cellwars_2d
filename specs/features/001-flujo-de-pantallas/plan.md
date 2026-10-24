---
id: F001
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-10-23
---

# Plan: feature 001

## Decisiones de diseño

Cada elección no obvia, con la alternativa descartada y el porqué.

1. **El flujo es una máquina de estados enum en lógica pura** (`ScreenFlow`, `RefCounted`), no una FSM de nodos.
   - Son 3 estados sin lógica de entrada/salida propia. La FSM de nodos (un nodo por estado) conviene para personajes con mucho comportamiento por estado; acá sería ceremonia.
   - Al ser `RefCounted` sin árbol, las transiciones se testean con gdUnit4 sin abrir escenas (AC01–AC07).
2. **`main.tscn` queda siempre cargada y cambia sus hijos**, en lugar de usar `get_tree().change_scene_to_file()`.
   - `change_scene_to_file()` destruye la escena actual entera, así que el estado del flujo tendría que vivir en un autoload. `architecture.md` permite como máximo un autoload de estado global y no conviene gastarlo en esto.
   - Con `Main` como raíz persistente, el flujo vive en un solo lugar: `Main` instancia la pantalla que toca dentro de un nodo contenedor y libera la anterior.
3. **La pausa usa la pausa nativa de Godot** (`get_tree().paused = true`) más `process_mode`, en lugar de que cada nodo chequee "¿estoy en pausa?".
   - Cuando el árbol está pausado, Godot deja de llamar `_process`/`_physics_process`/input en los nodos con `process_mode` *pausable*.
   - **Trampa de Godot**: `process_mode` por defecto es `INHERIT` (copia el del padre). Como `Main` necesita `ALWAYS` (tiene que escuchar Esc para despausar), sus hijos también serían `ALWAYS`. Por eso la escena de juego declara explícitamente `PROCESS_MODE_PAUSABLE`.
4. **El menú de pausa es un `CanvasLayer`** instanciado una vez en `Main` y oculto, en lugar de un `Control` dentro de la escena de juego.
   - Un `CanvasLayer` se dibuja en su propia capa, encima del juego, sin depender de cámaras.
   - Como la escena de juego se destruye al volver al menú, si la pausa viviera adentro se iría con ella. Vive en `Main` y la reutilizamos.
5. **Los menús usan contenedores** (`CenterContainer` + `VBoxContainer`), sin posiciones a mano. Así se centran solos a cualquier tamaño de ventana.
6. **Navegación con las acciones `ui_*` que trae Godot** (`ui_up`, `ui_down`, `ui_accept`). Los `Button` ya responden a ellas cuando tienen foco, para teclado y gamepad. Cada menú llama `grab_focus()` en su primer botón al abrirse (AC08, AC10).
7. **Acción nueva `pause`**: Esc + botón Start del gamepad. No reusamos `ui_cancel` (que también trae Esc) para no mezclar "volver atrás en un menú" con "pausar" cuando haya submenús (F002).
8. **Pantallas en una carpeta nueva `game/screens/`**: menú principal, menú de pausa y la escena de juego placeholder. Hoy la estructura solo tiene `entities/` para escenas, y un menú no es una entidad del juego. **Requiere tu aprobación**: si la aprobás, actualizo `CLAUDE.md`, `godot-conventions`, `architecture.md` y el README en esta misma branch.

## Árbol de escenas

```
Main (Node) · main.gd · process_mode ALWAYS
├── Screen (Node)                         # contenedor: acá se instancia la pantalla actual
│   └── (MainMenu o GameScreen, uno por vez)
└── PauseMenu (instancia de pause_menu.tscn) · visible = false

MainMenu (Control, Full Rect) · main_menu.gd
└── CenterContainer (Full Rect)
    └── VBoxContainer
        ├── TitleLabel (Label)            "Cellwars 2D"
        ├── PlayButton (Button)           "Jugar"
        └── QuitButton (Button)           "Salir"

GameScreen (Node2D) · game_screen.gd · process_mode PAUSABLE
├── PlaceholderLabel (Label)              "Escena de juego (placeholder)"
└── ElapsedLabel (Label)                  "Tiempo: 12.3 s" (se congela en pausa; vuelve a 0 al reiniciar)

PauseMenu (CanvasLayer, layer 10) · pause_menu.gd
└── Dim (ColorRect, Full Rect, negro semitransparente)
    └── CenterContainer (Full Rect)
        └── VBoxContainer
            ├── TitleLabel (Label)        "Pausa"
            ├── ResumeButton (Button)     "Continuar"
            └── MenuButton (Button)       "Volver al menú"
```

El contador de tiempo de `GameScreen` existe solo para poder ver en el playtest que la pausa congela la escena (AC10, AC11) y que "Volver al menú" la reinicia (AC12).

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/flow/screen_flow.gd` (`ScreenFlow`) | Lógica pura | Estados `MENU`/`PLAYING`/`PAUSED`, eventos `PLAY`/`PAUSE`/`RESUME`/`TO_MENU`, tabla de transiciones; emite `state_changed`. Ignora eventos inválidos. |
| `game/main.gd` | Nodo | Crea el `ScreenFlow`, traduce señales de los menús y la acción `pause` a eventos, y aplica cada cambio de estado: instanciar o liberar pantallas, `get_tree().paused`, mostrar u ocultar la pausa. "Salir" llama `get_tree().quit()`. |
| `game/screens/main_menu/main_menu.gd` | Nodo | Emite `play_requested` / `quit_requested` desde sus botones; foco inicial en "Jugar". |
| `game/screens/pause_menu/pause_menu.gd` | Nodo | `open()` / `close()`; emite `resume_requested` / `menu_requested`; foco en "Continuar" al abrir. |
| `game/screens/game_screen/game_screen.gd` | Nodo (placeholder) | Muestra el tiempo transcurrido. Se reemplaza por las salas en F003. |
| `project.godot` | Config | Acción `pause` (Esc, Start). |

## Señales

| Señal | Emisor | Receptor | Payload |
|---|---|---|---|
| `state_changed` | `ScreenFlow` | `Main` | `from: ScreenFlow.State, to: ScreenFlow.State` |
| `play_requested` | `MainMenu` | `Main` | — |
| `quit_requested` | `MainMenu` | `Main` | — |
| `resume_requested` | `PauseMenu` | `Main` | — |
| `menu_requested` | `PauseMenu` | `Main` | — |

Los menús no saben nada del flujo: solo avisan "apretaron tal botón" (señal hacia arriba) y `Main` decide. `Main` llama métodos hacia abajo (`pause_menu.open()`).

## Qué se testea con gdUnit4

`test/flow/screen_flow_test.gd`:

- AC01 `test_f001_ac01_starts_in_menu`
- AC02 `test_f001_ac02_play_from_menu_goes_to_playing`
- AC03 `test_f001_ac03_pause_from_playing_goes_to_paused`
- AC04 `test_f001_ac04_resume_or_pause_from_paused_goes_to_playing`
- AC05 `test_f001_ac05_to_menu_from_paused_goes_to_menu`
- AC06 `test_f001_ac06_invalid_event_keeps_state` (recorre todas las combinaciones estado × evento que no están en la tabla)
- AC07 `test_f001_ac07_notifies_once_per_change_and_never_on_ignored` (conecta un lambda que junta los pares `from`/`to` emitidos)

## Impacto en overlay debug

Ninguno: el overlay todavía no existe (fuera de alcance en la spec).

## Riesgos

- **Gamepad con stick en los menús**: las acciones `ui_*` por defecto de Godot incluyen el pad direccional; si el stick analógico no navega, se agregan sus ejes a `ui_up`/`ui_down` en `project.godot`. Se verifica en el playtest (AC14).
- **Pausa con `process_mode` mal heredado**: si `GameScreen` no queda en `PAUSABLE`, el contador no se congela. Lo detecta AC10.
- **Doble disparo de Esc**: un botón con foco no consume `pause`, así que el evento llega a `Main` vía `_unhandled_input`. Si el evento se procesara dos veces en un frame, la pausa abriría y cerraría sola; AC10 y el caso límite de Esc rápido lo cubren.
