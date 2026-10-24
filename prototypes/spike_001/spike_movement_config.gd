## Spike 001: parámetros de una variante de movimiento (A, B o C).
##
## Las tres variantes usan el mismo motor; lo que cambia son estos números. Cada
## variante es un .tres en esta carpeta, editable desde el inspector.
class_name Spike001Config
extends Resource

## Nombre que muestra el overlay (F3).
@export var variant_name: String = "A"

@export_group("Suelo")
## Velocidad máxima al correr.
@export_range(0.0, 400.0, 1.0, "suffix:px/s") var run_speed: float = 140.0
## Tiempo para pasar de quieto a velocidad máxima. 0 = arranca en seco.
@export_range(0.0, 1.0, 0.01, "suffix:s") var accel_time: float = 0.1
## Tiempo para frenar desde velocidad máxima. 0 = frena en seco.
@export_range(0.0, 1.0, 0.01, "suffix:s") var decel_time: float = 0.08
## Tiempo quieto que tarda en darse vuelta. 0 = gira al instante (sin frenar antes).
@export_range(0.0, 1.0, 0.01, "suffix:s") var turn_time: float = 0.0

@export_group("Salto")
## Altura con el botón mantenido.
@export_range(1.0, 200.0, 1.0, "suffix:px") var jump_height: float = 60.0
## Altura con un toque corto. Igual a jump_height = salto de altura fija.
@export_range(1.0, 200.0, 1.0, "suffix:px") var min_jump_height: float = 25.0
## Tiempo hasta el punto más alto.
@export_range(0.05, 1.0, 0.01, "suffix:s") var time_to_apex: float = 0.35
## Gravedad al caer comparada con la de subida. Más de 1 = cae más rápido (más peso).
@export_range(0.5, 4.0, 0.05) var fall_gravity_scale: float = 1.4
@export_range(1.0, 1500.0, 1.0, "suffix:px/s") var max_fall_speed: float = 600.0
## Preparación antes de despegar (anticipación). 0 = despega al apretar.
@export_range(0.0, 0.5, 0.01, "suffix:s") var jump_prep_time: float = 0.0

@export_group("Aire")
## Cuánto se puede cambiar la velocidad en el aire: 1 = como en el piso, 0 = arco fijo.
@export_range(0.0, 1.0, 0.05) var air_control: float = 1.0
## Si en el aire puede ir para el lado contrario al que saltó.
@export var air_can_reverse: bool = true

@export_group("Aterrizaje")
## Caída mínima para que el aterrizaje cueste una recuperación.
@export_range(0.0, 400.0, 1.0, "suffix:px") var hard_landing_height: float = 100.0
## Tiempo sin control al aterrizar de alto (recuperación). 0 = sin recuperación.
@export_range(0.0, 1.0, 0.01, "suffix:s") var land_recovery_time: float = 0.0

@export_group("Ayudas")
## Tiempo para poder saltar después de pisar el vacío.
@export_range(0.0, 0.3, 0.01, "suffix:s") var coyote_time: float = 0.1
## Si se aprieta salto este tiempo antes de tocar el piso, salta igual al tocarlo.
@export_range(0.0, 0.3, 0.01, "suffix:s") var jump_buffer_time: float = 0.12


func get_gravity() -> float:
	return 2.0 * jump_height / (time_to_apex * time_to_apex)


func get_fall_gravity() -> float:
	return get_gravity() * fall_gravity_scale


func get_jump_velocity() -> float:
	return 2.0 * jump_height / time_to_apex


## Velocidad de subida que deja, si se suelta el botón, una altura de min_jump_height.
## Sale de v² = 2·g·h.
func get_release_velocity() -> float:
	return sqrt(2.0 * get_gravity() * min_jump_height)


## Aceleración (px/s²) que corresponde a recorrer 0 → run_speed en "seconds".
func rate_for(seconds: float) -> float:
	return run_speed / seconds if seconds > 0.0 else INF
