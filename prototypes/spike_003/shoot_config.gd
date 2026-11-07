## Parámetros del disparo del prototipo S003 (solo del spike: no llega a develop).
##
## Se editan en el inspector abriendo shoot_config.tres. Los tres enums también se
## pueden cambiar jugando, con las teclas 1, 2 y 3 (ver spike_003.gd), para comparar
## rápido; lo que cambies así no se guarda en el .tres.
class_name ShootConfig
extends Resource

## Cómo responde el gatillo.
enum Mode {
	SEMI,  ## Tiro a tiro: un disparo por cada vez que se aprieta.
	AUTO,  ## Automático: dispara mientras el botón siga apretado.
	BURST,  ## Ráfaga: cada apretón suelta burst_count disparos seguidos.
}

## Qué sale del arma.
enum Delivery {
	RAY,  ## Rayo instantáneo: pega en el mismo paso; se ve un destello corto.
	PROJECTILE,  ## Proyectil visible que viaja a projectile_speed.
}

## Qué pasa si se aprieta disparar mientras corre.
enum RunRule {
	FORBID,  ## No dispara: hay que frenar primero (el apretón se pierde).
	BRAKE_THEN_SHOOT,  ## Frena solo y dispara al quedar quieto.
	INSTANT_STOP,  ## Corta la carrera en seco y dispara en ese mismo paso.
}

@export_group("Variantes")
@export var mode: Mode = Mode.SEMI
@export var delivery: Delivery = Delivery.RAY
@export var run_rule: RunRule = RunRule.BRAKE_THEN_SHOOT

# @export_range con "suffix:s" muestra la unidad en el inspector; no cambia el valor.
@export_group("Cadencia")
## Tiro a tiro: tiempo mínimo entre un disparo y el siguiente.
@export_range(0.02, 2.0, 0.01, "suffix:s") var semi_interval := 0.25
## Automático: tiempo entre disparos mientras se mantiene apretado.
@export_range(0.02, 2.0, 0.01, "suffix:s") var auto_interval := 0.14
## Ráfaga: cuántos disparos salen por apretón.
@export_range(1, 10, 1) var burst_count := 3
## Ráfaga: tiempo entre los disparos de una misma ráfaga.
@export_range(0.02, 1.0, 0.01, "suffix:s") var burst_spacing := 0.07
## Ráfaga: pausa desde el último disparo de una ráfaga hasta poder empezar otra.
@export_range(0.02, 2.0, 0.01, "suffix:s") var burst_pause := 0.45
## Después de cada disparo, Elyon se queda plantado este tiempo (no corre ni salta).
@export_range(0.0, 1.0, 0.01, "suffix:s") var shot_recovery := 0.12

@export_group("Alcance")
## Distancia máxima del disparo, desde la boca del arma.
@export_range(20.0, 1400.0, 10.0, "suffix:px") var shot_range := 360.0
## Solo proyectil: velocidad de viaje.
@export_range(50.0, 4000.0, 10.0, "suffix:px/s") var projectile_speed := 900.0
## Solo rayo: cuánto se ve el destello.
@export_range(0.01, 0.5, 0.01, "suffix:s") var ray_flash_time := 0.06

@export_group("Pose")
## Cuánto sigue en pose de tiro (apuntando) después del último disparo antes de
## volver a quieto. Mantener apretado disparar también la sostiene.
@export_range(0.0, 3.0, 0.05, "suffix:s") var aim_pose_time := 0.6
## Dibuja una línea celeste sobre el caño (ayuda para ver de dónde sale el tiro).
@export var show_aim_line := false

# Posición de la boca del arma respecto de los pies de Elyon, mirando a la derecha
# (x positivo = adelante, y negativo = arriba). Mirando a la izquierda se espeja x.
# Medidas sobre el cuadro "hold" de cada animación de disparo.
@export_group("Boca del arma")
@export var muzzle_forward := Vector2(35, -54)
@export var muzzle_up := Vector2(18, -62)
@export var muzzle_down := Vector2(32, -23)
