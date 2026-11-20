## Parámetros ajustables del disparo de Elyon (D0006, D0007; spec F012).
##
## Es un Resource: se guarda como game/data/shoot.tres y se edita en el inspector sin
## tocar código. ShootLogic y ProjectileFlight solo lo leen. Los valores por defecto
## son los que funcionaron en el spike S003.
class_name ShootConfig
extends Resource

@export_group("Gatillo")
## Automático: tiempo entre un tiro y el siguiente mientras se mantiene apretado.
## También es el tope: soltar y volver a apretar no dispara más rápido.
@export_range(0.05, 0.5, 0.01, "suffix:s") var fire_interval: float = 0.14

@export_group("Proyectil")
## Velocidad de viaje del proyectil.
@export_range(300.0, 2000.0, 10.0, "suffix:px/s") var projectile_speed: float = 900.0
## Distancia máxima que recorre desde la boca del arma.
@export_range(100.0, 1280.0, 10.0, "suffix:px") var shot_range: float = 360.0

@export_group("Ángulos")
## Tiro hacia arriba, en grados desde la horizontal (de pie, corriendo y en el aire).
@export_range(20.0, 70.0, 1.0, "suffix:°") var aim_up_angle: float = 40.0
## Tiro hacia abajo de pie y corriendo, en grados desde la horizontal.
@export_range(10.0, 45.0, 1.0, "suffix:°") var aim_down_angle: float = 20.0
## Tiro hacia abajo en el aire: más empinado que en el piso.
@export_range(10.0, 90.0, 1.0, "suffix:°") var air_aim_down_angle: float = 45.0

@export_group("Pose")
## Cuánto sigue en pose de tiro después del último disparo (mantener apretado también
## la sostiene). De pie se ve la animación de disparo; en movimiento, la línea del arma.
@export_range(0.0, 2.0, 0.05, "suffix:s") var aim_pose_time: float = 0.6

# Posición de la boca del arma respecto de los pies de Elyon, mirando a la derecha
# (x positivo = adelante, y negativo = arriba). Mirando a la izquierda se espeja x.
# Dependen del dibujo de Elyon2 (spike S003), no son tuning de juego.
@export_group("Boca del arma")
@export var muzzle_forward: Vector2 = Vector2(33, -52)
@export var muzzle_up: Vector2 = Vector2(26, -66)
@export var muzzle_down: Vector2 = Vector2(29, -42)
