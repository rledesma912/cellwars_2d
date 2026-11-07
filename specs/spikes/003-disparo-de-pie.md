---
id: S003
type: spike
status: approved         # draft (definición) → approved (en curso) → done (informe listo) → archivado por close-spike
superseded_by:
links: { gdd: [G001], decisions: [D0003, D0005], spike: }
updated: 2026-11-07
---

# Spike 003: disparo de pie

- Branch: `spike/003-disparo-de-pie`
- Tipo: gameplay
- Origen: GDD `vision.md` § Pilares ("Combate cuerpo a cuerpo y a distancia") y § Preguntas abiertas (arsenal); backlog

## Definición (se aprueba antes de empezar)

- Pregunta: ¿qué forma de disparar de pie (modo de disparo, cadencia, rayo o proyectil, alcance) se siente deliberada y legible para Elyon, en línea con el pilar de "control preciso y deliberado"?
- Motivo: disparar es la mecánica central de combate y todavía no sabemos cómo se siente. Hay varias formas razonables y elegir mal es caro, porque el spike de combate contra el primer enemigo, el diseño de las salas y el arte dependen de esto. La pregunta abierta de `vision.md` sobre el arsenal también se responde (al menos en parte) acá.
- Alcance:
  - Entra: disparar **quieto** (Elyon parado en el piso) en tres ángulos: adelante, 45° arriba y 45° abajo. El ángulo cambia de golpe, sin interpolar: se elige con `move_up` / `move_down` en el momento. Alcance corto. Comparar las alternativas de abajo. Observar qué pasa si se intenta disparar mientras se corre, para decidir la regla (ver alternativas).
  - Para probar hace falta un blanco: en la sala de prueba del prototipo hay **blancos quietos** que reaccionan al impacto (parpadean o desaparecen). No tienen vida, no atacan y no son enemigos: eso queda para el spike de combate.
  - No entra: disparar en el aire, agachado o rodando; munición y arsenal de varias armas; daño y vida; enemigos; sonido; importar el arte final de `cw2d-art` (el prototipo usa greybox: una línea o un rectángulo que marca el ángulo del arma sobre el sprite actual, como pide `CLAUDE.md` hasta pasar el `[feel]`); botón definitivo del input map.
  - Sin límite de tiempo: se cierra cuando se cumplan los criterios de salida y lo decidas vos.
- Criterios de salida:
  1. Jugaste las tres variantes de modo de disparo (tiro a tiro, automático, ráfaga) y elegiste una, o descartaste las tres con un motivo.
  2. Comparaste rayo instantáneo y proyectil visible, y elegiste uno.
  3. Quedaron en un `.tres` valores de cadencia, alcance (y velocidad del proyectil, si gana el proyectil) que te resultan buenos.
  4. Hay una regla elegida para "disparar corriendo".
  5. Quedó anotado lo que reportes del `[feel]` (yo no lo marco como cumplido).
- Alternativas a evaluar:
  - **Modo de disparo**: (a) tiro a tiro, un disparo por cada vez que se aprieta el botón, con una cadencia máxima; (b) automático, dispara mientras el botón está apretado, a cadencia fija; (c) ráfaga, cada vez que se aprieta salen N disparos seguidos y después hay una pausa.
  - **Qué sale del arma**: (a) rayo instantáneo (pega en el mismo cuadro, con un destello corto que muestra la línea; en Godot se resuelve con un `RayCast2D` o una consulta de rayo); (b) proyectil visible que viaja a una velocidad configurable (un `Area2D` que avanza en cada paso de física).
  - **Disparar corriendo**: (a) no se puede: hay que frenar primero; (b) apretar disparar frena a Elyon y dispara al terminar de frenar; (c) disparar interrumpe la carrera en seco y dispara al instante. Se prueban las tres con una opción en el `.tres`.
  - En el prototipo se cambia de variante desde el inspector, editando el `.tres` (`ShootConfig`, solo del prototipo), sin tocar código.
- Detalles del prototipo:
  - Va en `prototypes/spike_003/`, con una escena propia que reusa la escena `Player` actual y una sala de prueba con blancos.
  - El botón de disparo se registra **en tiempo de ejecución** desde el prototipo (`InputMap.add_action`), sin tocar `project.godot`. Como propuesta para probar: `J` / `X` en teclado y el botón izquierdo del frente (X en Xbox) en gamepad.
  - El overlay F3 muestra el modo, el ángulo, la cadencia y el tiempo hasta el próximo disparo.
- Destino del código: descartar (por defecto). Lo que sirve de ese código son los valores del `.tres` y la forma de la lógica pura, que pasan a la spec de la feature.

## Qué se construyó

## Evidencia y findings

## Valores de tuning que funcionaron

| Parámetro | Valor | Nota |
|---|---|---|

## Riesgos y limitaciones

## Recomendación

## Siguiente paso

- [ ] Decisión DNNNN → actualizar GDD / arquitectura / spec
- [ ] Otro spike (qué incertidumbre queda)
- [ ] Descartar la idea (motivo)
