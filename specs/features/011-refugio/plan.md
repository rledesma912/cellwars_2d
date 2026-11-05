---
id: F011
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-11-04
---

# Plan: feature 011

## Árbol de escenas

```
Main (Node)
├── Screen (Node)
│   └── World (Node2D)                       # emite level_completed
├── PauseMenu (CanvasLayer)
└── LevelCompleteMenu (CanvasLayer)          # nuevo: game/ui/level_complete_menu/
    ├── Dim (ColorRect)
    └── CenterContainer
        └── VBoxContainer
            ├── TitleLabel (Label)           # LEVEL_COMPLETE_TITLE
            └── ToMenuButton (Button)        # LEVEL_COMPLETE_TO_MENU

TestRoom3 (Node2D)
├── Background (ColorRect)
├── RefugeMarker (ColorRect)                 # nuevo: gris verdoso, sin colisión
└── Tiles (TileMapLayer)
```

## Scripts y responsabilidades

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `game/systems/rooms/level_progress.gd` | Lógica pura | `finishes_level(outcome)` dice si ese borde termina el nivel. `apply` deja de volver a la sala 1 desde la salida de la última |
| `game/systems/flow/screen_flow.gd` | Lógica pura | Suma el estado `LEVEL_COMPLETE` y el evento `LEVEL_COMPLETED`, con sus transiciones |
| `game/world/world.gd` | Nodo | Pregunta `finishes_level` y emite `level_completed` |
| `game/main.gd` | Nodo | Conecta `level_completed` con `ScreenFlow`. En `LEVEL_COMPLETE`, pausa y abre el cartel; al volver al menú, lo cierra |
| `game/ui/level_complete_menu/level_complete_menu.gd` | Nodo | Muestra el cartel y avisa qué botón se apretó |
| `game/i18n/texts.csv` | Datos | `LEVEL_COMPLETE_TITLE` y `LEVEL_COMPLETE_TO_MENU` |
| `game/levels/test/test_room_3.tscn` | Sala de prueba | Marca de la salida |

### Decisiones de diseño

Los patrones ya están fijados en `architecture.md`: menús en un `CanvasLayer` que no deciden el flujo, una tabla de transiciones en `ScreenFlow` y pausa con `get_tree().paused`. Por eso no hace falta consultar otra guía de Godot.

**`LevelProgress.finishes_level()` en lugar de un `Outcome` nuevo.**
`RoomExits` traduce un borde a un resultado solo con datos de la sala, y no sabe si es la última. `LevelProgress` sí conoce el índice, así que la regla va ahí. `apply()` devuelve `null` en ese caso, como cuando no cambia de sala.

**`World` avisa con una señal, `level_completed`.**
Descarté que `World` llamara a `Main`: un hijo no debería conocer a su padre. Es el mismo criterio que usan los menús y `death_finished`, porque las señales avisan hacia arriba.

**Un cartel propio, en lugar de reutilizar `PauseMenu`.**
Tienen otro título y otros botones. Reutilizarlo obligaría a ocultar "Continuar" y a llenar `PauseMenu` de condiciones. El costo es una escena chica más, con la misma forma.

**El cartel va en `Main`, no en `World`.**
Tiene que seguir respondiendo con el juego en pausa, y `World` se congela. `PauseMenu` ya vive ahí, con `PROCESS_MODE_ALWAYS`, por el mismo motivo.

**La marca es un `ColorRect` en la sala, sin entidad nueva.**
Descarté una entidad como `MortalZone` porque la marca no tiene comportamiento: lo que termina el nivel es cruzar el borde. Queda antes de `Tiles`, y por eso se dibuja detrás de Elyon y de las baldosas. Con `mouse_filter` en `Ignore`, como `Background`, no le quita clics a nadie. Es provisoria hasta que haya arte.

## Señales

| Señal | Emisor | Receptor | Payload |
|---|---|---|---|
| `level_completed` | `World` | `Main`, que manda `ScreenFlow.Event.LEVEL_COMPLETED` | Ninguno |
| `menu_requested` | `LevelCompleteMenu` | `Main`, que manda `ScreenFlow.Event.TO_MENU` | Ninguno |

## Qué se testea con gdUnit4

| Criterio | Test | Archivo |
|---|---|---|
| AC01 | `test_f011_ac01_last_exit_finishes_level_without_changing_room` | `level_progress_test.gd` |
| AC01 | `test_f011_ac01_single_room_level_finishes` | `level_progress_test.gd` |
| AC02 | `test_f011_ac02_other_borders_do_not_finish_level` | `level_progress_test.gd` |
| AC03 | `test_f011_ac03_level_complete_flow` | `screen_flow_test.gd` |
| AC04 | `test_f011_ac04_level_complete_ignores_other_events` | `screen_flow_test.gd` |
| AC04 | `test_f011_ac04_level_completed_only_while_playing` | `screen_flow_test.gd` |

`test_f006_ac02_list_edges` se ajusta: la salida de la última sala ya no vuelve a la sala 1 (F011-AC01). El caso de la entrada de la sala 1 sigue igual.

## Impacto en overlay debug

Sin líneas nuevas. El overlay sigue visible con el cartel abierto, porque corre en `PROCESS_MODE_ALWAYS`.

## Riesgos

- **`probar_en_laptop.sh` abre `world.tscn` directo, sin `Main`.** Así no hay cartel: nadie escucha la señal y Elyon sigue de largo fuera de la pantalla. AC05 a AC08 se prueban entrando por el menú, con `~/godot --path ~/cw2d_prueba`, y el playtest lo va a indicar.
- **Un paso de más.** Pausar en medio de un paso puede dejar correr ese paso a `Player`. No se ve, porque Elyon ya está fuera de la pantalla. Si la señal saliera dos veces, `ScreenFlow` ignora la segunda (AC04).
- **Traducción nueva.** Los `.translation` no se versionan: la copia de la laptop tiene que reimportarse para ver los textos, igual que en F002.
