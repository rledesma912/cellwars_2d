---
id: G001
type: gdd
status: draft
superseded_by:
links: { gdd: [], decisions: [], spike: }
updated: 2026-10-23
---

# Visión: Cellwars 2D

## Premisa

Un soldado de un escuadrón de glóbulos blancos, equipado con un traje futurista, debe atravesar el interior de un cuerpo humano para alcanzar refugios seguros en cada nivel. Bacterias y virus le bloquean el paso y debe combatirlos o evitarlos. El juego transcurre en un escenario biológico: pasillos, cavernas y tejidos del organismo.

## Pilares

**Control preciso y deliberado**: Cada salto y cada ataque deben sentirse intencionales. El personaje responde con peso y compromiso, sin inercia excesiva ni respuestas instantáneas. Si morís, es porque calculaste mal, no porque el control te traicionó. Esto implica animaciones con frames de anticipación y recuperación, y hitboxes legibles.

**Pantallas cortas, avance por salas**: El personaje comienza desde distintos lados de la pantalla y recorre pasillos y cavernas conectadas. Cada pantalla es un desafío autocontenido con sus propias trampas, enemigos y salida. El avance es lineal, sin caminos alternativos: la exploración consiste en leer y memorizar cada sala.

**Combate cuerpo a cuerpo y a distancia**: El soldado puede golpear con su traje y disparar. El combate no es masivo: los encuentros son uno a uno o contra grupos pequeños, y la posición importa tanto como la velocidad de reacción. Se prioriza la lectura del enemigo sobre la ejecución frenética.

**Mortalidad alta, checkpoints frecuentes**: El jugador muere fácilmente ante trampas y enemigos. Sin embargo, el castigo es mínimo: cada sala es un checkpoint, así que al morir se reinicia desde la entrada de la sala, sin repetir secciones largas. La dificultad viene del diseño de las salas, no de la distancia entre checkpoints.

## Experiencia buscada

Tensión contenida y fluidez. El jugador siente que cada pantalla es un pequeño rompecabezas de movimiento y combate: leer el terreno, identificar la ruta, ejecutar con precisión. La muerte es parte del aprendizaje, no un castigo frustrante.

Loop central: entrar a una sala (checkpoint) → identificar amenazas y ruta → ejecutar saltos y combates → alcanzar la salida → sala siguiente. En la última sala del nivel, la salida es el refugio.

## Estructura y núcleo de gameplay

**Estructura**: Niveles lineales divididos en pantallas fijas (sin scroll continuo). Cada nivel representa una zona del cuerpo (órgano, tejido, conducto) y termina al alcanzar un refugio en su última sala. Cada sala es un checkpoint.

**Núcleo**: Plataformas + combate. El peso está repartido: las plataformas exigen precisión y timing; el combate exige posicionamiento y lectura de patrones. No hay énfasis en combos ni en acción frenética.

**Progresión**: El personaje no gana habilidades nuevas a lo largo del juego. Lo que cambia es la complejidad de las salas y la agresividad de los enemigos. El conocimiento del jugador es la única progresión real.

## Público y dificultad

**Público**: Jugadores que crecieron con los cinematic platformers de los 90 (Prince of Persia, Another World, Flashback) o que disfrutan de juegos de plataformas exigentes con ritmo pausado. No es para quien busca acción rápida o narrativa dominante.

**Dificultad**: Alta, pero justa. Las muertes son frecuentes y el aprendizaje es por repetición. No hay opciones de accesibilidad en la v1: la dificultad es parte de la identidad del juego.

## Plataformas y meta

**Plataformas**: PC (Windows/Linux). Control con teclado y gamepad.

**Meta**: Proyecto de aprendizaje y homenaje a los clásicos del género. Distribución gratuita en itch.io.

## Alcance de la primera versión

3 niveles (zonas del cuerpo), cada uno con aproximadamente 8–10 pantallas. Un total estimado de 30–40 minutos de juego para un jugador que ya conoce los niveles. Sin jefes en la v1: el desafío está en las salas, no en enfrentamientos únicos.

## No-objetivos

Sin diálogos ni historia hablada. Sin cinemáticas extensas (las animaciones de muerte y transición son suficientes). Sin habilidades desbloqueables ni inventario. Sin multijugador. Sin generación procedural. Sin scroll continuo: el juego es de pantalla fija.

## Referencias

**Prince of Persia (1989)**: La vulnerabilidad del protagonista, el peso de cada acción, las trampas mortales que exigen memorización y timing. El combate de esgrima uno a uno. No: la ambientación medieval ni el límite de tiempo global.

**Another World (1991)**: La ausencia de HUD y texto, la narrativa contada a través del entorno, la sensación de hostilidad del mundo. Las animaciones rotoscopiadas que dan peso al personaje. No: la resolución de puzzles crípticos sin pistas.

**Flashback (1992)**: El combate con arma de fuego, la exploración de pantallas conectadas, la presentación cinematográfica. La idea de un soldado en un entorno hostil con identidad propia. No: la estructura de aventura con objetos y pistas narrativas.

## Preguntas abiertas

- ¿Qué arsenal tiene el soldado? ¿Un solo arma o varias, con munición limitada o infinita?
- ¿Cómo funciona la vida? ¿Muero de un golpe o aguanto varios? Si aguanto varios, ¿cómo lo muestro sin HUD?
- ¿Qué conjunto de movimientos tiene el personaje: agacharse, rodar, colgarse de bordes? (Lo empieza a responder el Spike 001.)
- ¿Los enemigos tienen patrones fijos o alguna variación?
- ¿Cuántos tipos de enemigos entran en la v1?
- ¿Los refugios son solo el final del nivel o tienen alguna otra función (narrativa o mecánica)?
- Por ahora cada sala es un checkpoint. ¿Alguna sala va a necesitar un checkpoint intermedio, o conviene espaciarlos más?
- ¿La estética es biológica explícita (tejidos, órganos) o más abstracta y tecnológica?
