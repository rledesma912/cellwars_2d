---
id: S001
type: spike
status: done
superseded_by:
links: { gdd: [G001], decisions: [D0002, D0003], spike: }
updated: 2026-10-25
---

# Spike 001: Movimiento y peso del soldado

- Branch: `spike/001-movimiento-y-peso`
- Tipo: gameplay
- Origen: GDD `vision.md` § Pilares ("Control preciso y deliberado") / feature 003 (movimiento base)

## Definición (se aprueba antes de empezar)

- Pregunta: ¿qué estilo de movimiento hace sentir al soldado "con peso y compromiso, sin inercia excesiva ni respuestas instantáneas", y con qué valores?
- Motivo: es la mecánica central y su feel no se conoce. Hoy el rectángulo de la F003 arranca y frena en seco. Las salas, las trampas y el combate se diseñan alrededor de cómo se mueve el soldado (qué tan lejos salta, cuánto tarda en frenar, si puede corregir en el aire), así que elegir mal sale caro después.
- Alcance:
  - Entra:
    - Caminar/correr con aceleración y frenado.
    - Darse vuelta.
    - Salto con preparación (anticipación) y aterrizaje (recuperación).
    - Control en el aire.
    - Salto variable (más alto si se mantiene apretado).
    - *Coyote time* (poder saltar unos instantes después de pisar el vacío).
    - *Jump buffer* (si apretás salto un instante antes de tocar el piso, salta igual al tocarlo).
    - Una silueta animada provisoria hecha por el agente, con los estados quieto, arrancar, correr, frenar, girar, preparar salto, en el aire y aterrizar. Sirve para sentir la anticipación y la recuperación, no como arte final.
    - Chequeo liviano de lectura visual: cómo se ve la silueta a 640×360 escalado ×2/×3 y con `snap_2d_transforms_to_pixel` (pendientes de `architecture.md`). Como no hay cámara que se mueva, solo se mira si la silueta tiembla o se ve borrosa.
  - No entra:
    - Colgarse de bordes, trepar, agacharse, rodar, dash.
    - Combate, daño y muerte.
    - Arte final y sonido.
    - Cámara y paso de sala.
    - Tocar el código del juego en `game/`.
  - Sin límite de tiempo: cierra cuando se cumplen los criterios de salida y el desarrollador lo decide.
- Alternativas a evaluar (las tres en el mismo prototipo, cambiando con las teclas 1, 2 y 3 sin reiniciar):
  - **A. Moderno con peso**: física de plataformas actual (tipo *Celeste* o *Hollow Knight*, pero más pesado). Aceleración y frenado cortos, control completo en el aire, salto variable, coyote time y jump buffer. Responde siempre; el peso sale de las curvas de velocidad.
  - **B. Cinemático comprometido**: estilo *Prince of Persia* / *Flashback*. Cada acción se compromete al empezar: preparación visible antes de saltar, arco de salto fijo sin control en el aire, pasos de arranque y de frenado, giro que tarda. Altura de salto fija.
  - **C. Híbrido**: la base de A con compromiso de B. Preparación corta antes de saltar, control en el aire reducido (puede corregir, no revertir), recuperación breve al aterrizar de alto, giro con un frame de transición.
- Criterios de salida:
  - Las tres variantes andan en una copia de la sala de prueba de la F003, más tres desafíos chicos: saltar el precipicio, aterrizar en una plataforma de 2 baldosas y darse vuelta para escapar.
  - Cada variante tiene sus valores en un `.tres` editable desde el inspector, y el overlay F3 muestra la variante activa, la velocidad, el estado de la silueta y los timers (coyote, buffer, preparación, recuperación).
  - El desarrollador jugó las tres y eligió una (o una mezcla), con valores de tuning que le funcionan.
  - Quedan registradas las distancias resultantes con esos valores: salto máximo en horizontal y en vertical, y distancia de frenado. Las necesita el diseño de las salas.
  - Queda registrado si 640×360 con snap a píxel se ve bien con la silueta animada, o si hace falta revisarlo.
- Destino del código: descartar (por defecto). La lógica que funcione se reescribe con tests en la feature que siga.

## Qué se construyó

Prototipo en `prototypes/spike_001/` (escena `spike_001.tscn`):

- `spike_motor.gd`: motor de lógica pura con estados (enum): quieto, correr, frenar, girar, preparar salto, en el aire, recuperarse. Mismo motor para todas las variantes; cambian los valores.
- `spike_movement_config.gd` + `variant_a.tres`, `variant_b.tres`, `variant_c.tres`, `variant_c48.tres`: un Resource por variante.
- `soldier.tscn`: `CharacterBody2D` con un `AnimatedSprite2D` cuyas animaciones elige el estado del motor; la preparación, el giro y la recuperación se estiran para durar lo que dice el `.tres`.
- Tres aspectos intercambiables (tecla S): silueta provisoria (`silhouette.png`, generada con `make_silhouette.py`), Elyon a 40 px y Elyon a 48 px (`elyon_40.png`, `elyon_48.png`).
- `challenge_room.tscn`: sala de desafíos (bloques de 1, 2 y 3 baldosas, borde para frenar, caída de 180 px, pasillo, huecos de 3 y 4 baldosas con plataforma de 2).
- `comfy/`: flujo de imágenes con ComfyUI local por su API HTTP:
  - `make_poses.py`: esqueletos OpenPose de los 21 cuadros a partir de las poses de la silueta;
  - `sdxl_pose_run.py`: SDXL + ControlNet OpenPose (pose) + IP-Adapter (diseño, con `elyon_ref_hemofusil.png` como referencia) + LoRA Pixel Art XL;
  - `kontext_run.py`: Flux Kontext Dev (usado para crear la referencia con el Hemofusil);
  - `anim_sprites.py` y `build_frames.gd`: hoja de sprites con escala y paleta comunes y su `SpriteFrames`.
- `elyon_prompts.md`: órdenes y aprendizajes para generar a Elyon con ComfyUI.
- Teclas: S aspecto, 1-4 variante, Tab sala, R reinicia, P snap a píxel, F3 datos (mediciones del último salto, caída y frenada).

## Evidencia y findings

- **Variante elegida: C (híbrido).** El desarrollador: *"El híbrido logra el equilibrio de un movimiento moderno y el feeling de peso del soldado, me gusta."* Los valores de arranque le quedaron bien.
- **Tamaño elegido: 48 px de alto con salto de 52 px.** Elyon a 40 px: *"Le falta definición"*. A 48 px: *"me gusta más el Elyon de 48"*; el salto de 52 *"está bien por ahora"*.
  - El desarrollador quiere mantener 3 pisos por sala (`D0002`: 100 px de aire por piso). Cuerpo + salto debe entrar en esos 100 px: 48 + 52 = 100, verificado por simulación.
  - Con salto de 52 px, un bloque de 3 baldosas (60 px) no se alcanza; 2 baldosas (40 px) sí.
- **Snap a píxel**: activarlo o desactivarlo no cambia nada visible a 640×360.
- Mediciones por simulación (pasos de 1/60 s):

| Variante | Salto corriendo (largo / alto) | Toque corto | Frenada | Giro |
|---|---|---|---|---|
| A moderno | 93 / 60 px | 29 px | 3 px | inmediato |
| B cinemático | 102 / 60 px | 60 px (fija) | 13 px | 0,28 s |
| C híbrido | 97 / 60 px | 38 px | 5 px | 0,1 s |
| **C 48 (elegida)** | **97 / 52 px** | **33 px** | **5 px** | **0,1 s** |

- **El motor manda los tiempos y la animación se adapta**: el prototipo estira o acorta la animación para que dure lo que dice el `.tres`. Así el control no depende de cuántos cuadros tenga el dibujo.
- **Generación de imágenes con IA (ComfyUI local, RTX 3060 12 GB):**
  - Kontext conserva el ángulo de la imagen de entrada: hace falta la vista de perfil. Agrega bien la mochila, la manguera y el arma, pero cambia las poses poco comunes (endereza el agachado) y varía el diseño entre cuadros: no sirve para animación.
  - SDXL + OpenPose respeta las poses (incluido el agachado) y mantiene la coherencia entre cuadros. No dibuja la manguera ni el arma si la referencia no las tiene: con la referencia generada por Kontext sí lo hace (la manguera, a veces).
  - El esqueleto debe ocupar ~60 % del alto de la imagen; al 80 % SDXL corta los pies.
  - Tiempos: ~40 s por cuadro con SDXL; ~3 min con Kontext.
  - Los cuadros salen con defectos (manguera intermitente, restos de fondo, casco algo grande): sirven para evaluar tamaño y como base, no como arte final.

## Valores de tuning que funcionaron

`prototypes/spike_001/variant_c48.tres`:

| Parámetro | Valor | Nota |
|---|---|---|
| run_speed | 135 px/s | |
| accel_time / decel_time | 0,15 / 0,12 s | arranque y frenado cortos |
| turn_time | 0,08 s | giro quieto |
| jump_height / min_jump_height | 52 / 30 px | salto variable |
| time_to_apex | 0,36 s | |
| fall_gravity_scale | 1,25 | cae algo más rápido de lo que sube |
| max_fall_speed | 600 px/s | |
| jump_prep_time | 0,07 s | anticipación |
| air_control / air_can_reverse | 0,5 / no | corrige en el aire, no se da vuelta |
| hard_landing_height / land_recovery_time | 100 px / 0,15 s | recuperación al caer de alto |
| coyote_time / jump_buffer_time | 0,08 / 0,1 s | |
| Cuerpo de colisión | 20 × 48 px | |

## Riesgos y limitaciones

- El salto de 52 px con el techo de 100 px deja la cabeza tocando justo el techo: cualquier aumento de altura del salto o del cuerpo choca. El desarrollador lo aceptó "por ahora".
- Los valores salen de jugar en dos salas de prueba; el ajuste fino va a seguir en el `.tres` del juego.
- 48 px puede quedarse corto de definición para el arte final; subirlo implicaría cambiar la resolución del juego (fuera de este spike).
- `ComfyUI_IPAdapter_plus` ya no tiene mantenimiento: puede romperse con versiones futuras de ComfyUI.

## Recomendación

Adoptar el movimiento híbrido (variante C) con un soldado de 48 px de alto y salto de 52 px, con la regla "el motor manda los tiempos". Implementarlo en una feature que reemplace el movimiento de la F003 por el motor con estados, con tests. Ver `D0003`.

## Siguiente paso

- [x] Decisión D0003 → actualizar arquitectura, `CLAUDE.md`, backlog
- [ ] Otro spike (qué incertidumbre queda)
- [ ] Descartar la idea (motivo)
