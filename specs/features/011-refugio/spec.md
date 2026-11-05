---
id: F011
type: feature
status: draft
superseded_by:
links: { gdd: [G001], decisions: [], spike: }
updated: 2026-11-04
---

# Feature 011: Refugio al final del nivel

- Origen: GDD `vision.md` ("En la última sala del nivel, la salida es el refugio") y backlog.
- Vía: completa (toca salas, flujo de pantallas e interfaz)

## Objetivo

Hoy un nivel no termina: la salida de la última sala lleva a la entrada de la sala 1, de forma provisoria (F006). Con esta feature, esa salida es el refugio. Al cruzarla, la partida se congela y aparece el cartel "Refugio alcanzado", con un botón para volver al menú. Se completa así el ciclo del juego: entrar, recorrer las salas y llegar a un final.

## Fuera de alcance

- Pasar al nivel siguiente: el juego tiene un solo nivel.
- Guardar el progreso, y mostrar tiempo o cantidad de muertes.
- Arte, sonido, música o animación del refugio y de Elyon al llegar.
- Otra función del refugio además de terminar el nivel, como descansar o contar historia.
- La secuencia de cómic al terminar un nivel, que sigue en el backlog.

## Criterios de aceptación

**Reglas**

- F011-AC01 [unit] Salir por la salida de la última sala da "nivel terminado", sin cambiar de sala. Vale también para un nivel de una sola sala. Reemplaza el comportamiento provisorio de F006-AC02.
- F011-AC02 [unit] Lo demás no cambia: la salida de otra sala lleva a la siguiente, y la entrada de la sala 1 vuelve a su entrada (F006-AC01 y F006-AC02).
- F011-AC03 [unit] En `ScreenFlow`, terminar el nivel pasa de jugando a "nivel completado", y volver al menú pasa de "nivel completado" al menú.
- F011-AC04 [unit] En "nivel completado" se ignoran pausar, continuar y jugar. Terminar el nivel solo tiene efecto mientras se está jugando.

**Jugando**

- F011-AC05 [manual] Al cruzar la salida de la sala 3, Elyon deja de moverse, la sala queda congelada y aparece el cartel "Refugio alcanzado" con el botón "Volver al menú".
- F011-AC06 [manual] Con el cartel abierto, Esc o Start no abren la pausa, y el botón responde con teclado, gamepad y mouse.
- F011-AC07 [manual] Al volver al menú y elegir Jugar, la partida empieza de cero: entrada de la sala 1, quieto (overlay: `sala` dice "1 / 3" y `checkpoint` dice "sala 1").
- F011-AC08 [manual] El título y el botón del cartel están traducidos al cambiar entre español e inglés.
- F011-AC09 [manual] La salida de la sala 3 se distingue con un rectángulo gris verdoso, sin colisión, que Elyon atraviesa.

## Casos límite

- Muere y su cuerpo cruza la salida: no cuenta como llegar, porque mientras está muerto `World` ignora los bordes (F007).
- Llega corriendo o saltando: termina igual, en cuanto sale entero de la pantalla, sin importar cómo llega.
- Una última sala con la salida abajo: cruzarla termina el nivel, sea cual sea la altura de la caída, porque Elyon nunca toca el piso. Las salas de prueba tienen la salida a la derecha, así que hoy no pasa.
- Vuelve a una sala anterior y regresa: el nivel termina recién al cruzar la salida de la última.
- Sale por la entrada de la sala 1: sigue volviendo a esa entrada, de forma provisoria (F006-AC02).

## Parámetros de tuning (Resource)

Sin tuning nuevo.

## Preguntas abiertas

1. **¿Adónde lleva el cartel?** Propuesta: al menú principal, porque es un final claro y deja listo el lugar para el nivel siguiente. La alternativa es un segundo botón, "Jugar de nuevo", que vuelva a la sala 1, como hace hoy la salida.
2. **¿La salida se marca?** Propuesta: sí, con el rectángulo gris verdoso de F011-AC09, que es greybox hasta que haya arte. Sin marca, se llega al final sin saber que esa salida termina el nivel. La alternativa es no marcarla y quitar ese criterio.
