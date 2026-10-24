---
id: S001
type: spike
status: approved
superseded_by:
links: { gdd: [G001], decisions: [D0002], spike: }
updated: 2026-10-24
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

- `spike_motor.gd`: motor de lógica pura con estados (enum): quieto, correr, frenar, girar, preparar salto, en el aire, recuperarse. Mismo motor para las tres variantes; cambian los valores.
- `spike_movement_config.gd` + `variant_a.tres`, `variant_b.tres`, `variant_c.tres`: un Resource por variante, editable desde el inspector.
- `soldier.tscn`: `CharacterBody2D` de 20 × 40 px con un `AnimatedSprite2D`. Las animaciones se eligen según el estado del motor; la preparación, el giro y la recuperación se estiran para durar lo que dice el `.tres`.
- `silhouette.png` y `silhouette_frames.tres`: silueta provisoria de 32 × 48 por cuadro, generada con `make_silhouette.py`.
- `challenge_room.tscn`: sala de desafíos. Entra por arriba a la izquierda y sale por abajo a la derecha. Tiene:
  - bloques de 1, 2 y 3 baldosas de alto;
  - un borde para medir la frenada;
  - una caída de 180 px;
  - un pasillo para ir y volver;
  - huecos de 3 y 4 baldosas con una plataforma de 2 en el medio.
- Teclas del prototipo: 1/2/3 variante, Tab sala (la de prueba de la F003 o la de desafíos), R reinicia, P snap a píxel, F3 datos con las mediciones del último salto, caída y frenada.
- `elyon_prompts.md`: prompts para generar a Elyon en pixel art a 40 y 48 px (modelos de difusión en general y Flux Kontext en ComfyUI).

## Evidencia y findings

Parcial (2026-10-24; el spike sigue abierto):

- **Variante elegida: C (híbrido)**, con los valores de arranque de `variant_c.tres`. El desarrollador: *"El híbrido logra el equilibrio de un movimiento moderno y el feeling de peso del soldado, me gusta."* Después confirmó que los valores le quedan bien.
- **Snap a píxel**: activarlo o desactivarlo (tecla P) no cambia nada visible a 640×360 con la silueta animada.
- Mediciones por simulación con los valores de arranque:

| Variante | Salto corriendo (largo / alto) | Toque corto | Frenada | Giro |
|---|---|---|---|---|
| A | 93 / 60 px | 29 px | 3 px | inmediato |
| B | 102 / 60 px | 60 px (fija) | 13 px | 0,28 s |
| C | 97 / 60 px | 38 px | 5 px | 0,1 s |

- Regla propuesta para la decisión: **el motor manda los tiempos y la animación se adapta** (se estira o acorta para durar lo que dice el `.tres`), al revés que en *Prince of Persia*.
- Fuera del alcance original, aceptado para revisar dentro del spike: **el tamaño del soldado**.
  - Con 3 pisos por sala (100 px de aire por piso), el soldado más su salto deben entrar en 100 px. Las opciones son 40 px de alto (salto de 60 px) o 48 px (salto de unos 52 px).
  - Para decidir, el desarrollador genera imágenes de Elyon en pixel art a 40 y 48 px con ComfyUI (Flux Kontext Dev, local) y el agente las pone a tamaño real en el prototipo.

## Valores de tuning que funcionaron

| Parámetro | Valor | Nota |
|---|---|---|

## Riesgos y limitaciones

## Recomendación

## Siguiente paso

- [ ] Decisión DNNNN → actualizar GDD / arquitectura / spec
- [ ] Otro spike (qué incertidumbre queda)
- [ ] Descartar la idea (motivo)
