## Parámetros ajustables del movimiento del personaje.
##
## Es un Resource: se guarda como archivo .tres (game/data/player_movement.tres) y
## se edita en el inspector de Godot sin tocar código. PlayerMotor solo lo lee.
class_name PlayerMovementConfig
extends Resource

## Velocidad al caminar, en píxeles por segundo (igual en el piso y en el aire).
@export_range(0.0, 500.0, 1.0, "suffix:px/s") var run_speed: float = 140.0
## Altura máxima del salto, en píxeles (20 px = 1 baldosa).
@export_range(1.0, 300.0, 1.0, "suffix:px") var jump_height: float = 80.0
## Segundos que tarda el salto en llegar a su punto más alto.
@export_range(0.05, 2.0, 0.01, "suffix:s") var time_to_apex: float = 0.35
## Velocidad máxima de caída, en píxeles por segundo.
@export_range(1.0, 2000.0, 1.0, "suffix:px/s") var max_fall_speed: float = 600.0

# La gravedad y la velocidad de salto no se ajustan a mano: salen de la altura y
# del tiempo, que son más fáciles de pensar ("salta 4 baldosas en 0,35 s").
# Son las fórmulas del tiro vertical: h = v·t / 2 y v = g·t.


## Aceleración hacia abajo, en px/s².
func get_gravity() -> float:
	return 2.0 * jump_height / (time_to_apex * time_to_apex)


## Velocidad hacia arriba al empezar el salto, en px/s (positiva; el motor la invierte,
## porque en Godot el eje Y crece hacia abajo).
func get_jump_velocity() -> float:
	return 2.0 * jump_height / time_to_apex
