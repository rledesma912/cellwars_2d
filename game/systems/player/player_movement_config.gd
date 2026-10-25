## Parámetros ajustables del movimiento del soldado (D0003).
##
## Es un Resource: se guarda como archivo .tres (game/data/player_movement.tres) y
## se edita en el inspector de Godot sin tocar código. PlayerMotor solo lo lee.
## Los valores por defecto son los de la spec F004 (los que funcionaron en el spike 001).
class_name PlayerMovementConfig
extends Resource

# @export_group agrupa los parámetros en secciones plegables del inspector.
@export_group("Suelo")
## Velocidad máxima al correr, en píxeles por segundo.
@export_range(0.0, 500.0, 1.0, "suffix:px/s") var run_speed: float = 135.0
## Tiempo para pasar de quieto a velocidad máxima. 0 = arranca en seco.
@export_range(0.0, 1.0, 0.01, "suffix:s") var accel_time: float = 0.15
## Tiempo para frenar desde velocidad máxima. 0 = frena en seco.
@export_range(0.0, 1.0, 0.01, "suffix:s") var decel_time: float = 0.12
## Tiempo quieto que tarda en darse vuelta. 0 = gira al instante.
@export_range(0.0, 1.0, 0.01, "suffix:s") var turn_time: float = 0.08

@export_group("Salto")
## Altura con el botón sostenido, en píxeles (20 px = 1 baldosa).
@export_range(1.0, 300.0, 1.0, "suffix:px") var jump_height: float = 52.0
## Altura con un toque corto. Igual a jump_height = salto de altura fija.
@export_range(1.0, 300.0, 1.0, "suffix:px") var min_jump_height: float = 30.0
## Segundos que tarda el salto lleno en llegar a su punto más alto.
@export_range(0.05, 2.0, 0.01, "suffix:s") var time_to_apex: float = 0.36
## Gravedad al caer comparada con la de subida. Más de 1 = cae más rápido (más peso).
@export_range(0.5, 4.0, 0.05) var fall_gravity_scale: float = 1.25
## Velocidad máxima de caída, en píxeles por segundo.
@export_range(1.0, 2000.0, 1.0, "suffix:px/s") var max_fall_speed: float = 600.0
## Preparación antes de despegar (anticipación). 0 = despega al apretar.
@export_range(0.0, 0.5, 0.01, "suffix:s") var jump_prep_time: float = 0.07

@export_group("Aire")
## Cuánto puede cambiar la velocidad en el aire: 1 = como en el piso, 0 = arco fijo.
@export_range(0.0, 1.0, 0.05) var air_control: float = 0.5

@export_group("Aterrizaje")
## Caída mínima, en píxeles, para que el aterrizaje cueste una recuperación.
@export_range(0.0, 400.0, 1.0, "suffix:px") var hard_landing_height: float = 100.0
## Tiempo sin control al aterrizar de alto. 0 = sin recuperación.
@export_range(0.0, 1.0, 0.01, "suffix:s") var land_recovery_time: float = 0.15

@export_group("Ayudas")
## Tiempo para poder saltar después de pisar el vacío.
@export_range(0.0, 0.3, 0.01, "suffix:s") var coyote_time: float = 0.08
## Si se aprieta salto este tiempo antes de tocar el piso, salta igual al tocarlo.
@export_range(0.0, 0.3, 0.01, "suffix:s") var jump_buffer_time: float = 0.1

# La gravedad y las velocidades no se ajustan a mano: salen de alturas y tiempos,
# que son más fáciles de pensar ("salta 52 px en 0,36 s").
# Son las fórmulas del tiro vertical: h = v·t / 2, v = g·t y v² = 2·g·h.


## Aceleración hacia abajo mientras sube, en px/s².
func get_gravity() -> float:
	return 2.0 * jump_height / (time_to_apex * time_to_apex)


## Aceleración hacia abajo mientras cae, en px/s².
func get_fall_gravity() -> float:
	return get_gravity() * fall_gravity_scale


## Velocidad hacia arriba al empezar el salto lleno, en px/s (positiva; el motor la
## invierte, porque en Godot el eje Y crece hacia abajo).
func get_jump_velocity() -> float:
	return 2.0 * jump_height / time_to_apex


## Velocidad de subida que, sin más impulso, llega justo a min_jump_height.
## Al soltar el botón subiendo más rápido que esto, la subida se corta a este valor.
func get_release_velocity() -> float:
	return sqrt(2.0 * get_gravity() * min_jump_height)


## Aceleración al arrancar en el piso, en px/s². Con tiempo 0 es infinita (en seco).
func get_accel_rate() -> float:
	return _rate_for(accel_time)


## Desaceleración al frenar en el piso, en px/s². Con tiempo 0 es infinita (en seco).
func get_decel_rate() -> float:
	return _rate_for(decel_time)


# Aceleración que recorre de 0 a run_speed en "seconds".
func _rate_for(seconds: float) -> float:
	return run_speed / seconds if seconds > 0.0 else INF
