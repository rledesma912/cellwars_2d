## Qué animación muestra el soldado y a qué velocidad (D0003).
##
## Lógica pura: el nodo Player le pasa el estado del motor y la velocidad, y reproduce
## lo que esto devuelve en su AnimatedSprite2D. Los nombres son los de las animaciones
## de game/art/elyon/elyon_frames.tres.
##
## Regla "el motor manda los tiempos y la animación se adapta": el giro, la preparación,
## la recuperación, rodar y morir duran lo que dice el .tres, tenga el dibujo los
## cuadros que tenga. morir_caida es la excepción: es un golpe seco, y estirarlo con
## death_time le quitaría el impacto.
class_name PlayerAnimation
extends RefCounted

## Por debajo de esta fracción de run_speed, correr se ve como "arrancar".
const FULL_RUN_FRACTION := 0.7


## Animación para el estado del motor y la velocidad actual. "blocked" es el resultado
## de is_blocked: contra una pared, correr se ve quieto (el motor no se entera).
static func pick(
	state: PlayerMotor.State,
	velocity: Vector2,
	run_speed: float,
	blocked: bool,
	fall_severity := PlayerMotor.FallSeverity.NORMAL,
	on_floor := false,
) -> StringName:
	match state:
		PlayerMotor.State.RUN:
			if blocked:
				return &"quieto"
			if absf(velocity.x) < run_speed * FULL_RUN_FRACTION:
				return &"arrancar"
			return &"correr"
		PlayerMotor.State.BRAKE:
			return &"frenar"
		PlayerMotor.State.TURN:
			return &"girar"
		PlayerMotor.State.JUMP_PREP:
			return &"preparar"
		PlayerMotor.State.AIR:
			return _air(velocity, fall_severity)
		PlayerMotor.State.LAND:
			return &"aterrizar"
		PlayerMotor.State.ROLL:
			return &"rodar"
		PlayerMotor.State.DEAD:
			return _dead(fall_severity, on_floor)
		_:
			return &"quieto"


## Cuánto tiene que durar una animación según el .tres, o 0 si va a su ritmo natural.
static func duration_for(animation: StringName, config: PlayerMovementConfig) -> float:
	match animation:
		&"girar":
			return config.turn_time
		&"preparar":
			return config.jump_prep_time
		&"aterrizar":
			return config.land_recovery_time
		&"rodar":
			return config.roll_time
		&"morir":
			return config.death_time
		_:
			return 0.0


## true si toca una pared y la dirección apretada apunta hacia ella. La normal de una
## pared apunta hacia afuera: dirección y normal de signo contrario es "hacia la pared".
static func is_blocked(on_wall: bool, wall_normal_x: float, direction: float) -> bool:
	return on_wall and direction * wall_normal_x < 0.0


## true si la animación se queda en su último cuadro en vez de reiniciarse: las dos
## muertes dejan a Elyon en el piso hasta volver a la entrada.
static func holds_last_frame(animation: StringName) -> bool:
	return animation == &"morir" or animation == &"morir_caida"


## Velocidad de reproducción para que "frame_count" cuadros a "fps" duren "duration" s.
## Una animación de N cuadros a F fps dura N/F s; reproducida a (N/F) / T dura T s.
## Sin duración (0) o con datos inválidos, velocidad normal (1).
static func speed_for(frame_count: int, fps: float, duration: float) -> float:
	if duration <= 0.0 or fps <= 0.0 or frame_count <= 0:
		return 1.0
	return (frame_count / fps) / duration


static func _air(velocity: Vector2, fall_severity: PlayerMotor.FallSeverity) -> StringName:
	# En Godot el eje Y crece hacia abajo: velocidad Y negativa es subir.
	if velocity.y < 0.0:
		return &"subir"
	return &"caer" if fall_severity == PlayerMotor.FallSeverity.NORMAL else &"caer_largo"


# Una caída mortal sigue en caer_largo hasta tocar el piso: morir_caida es el golpe, y
# no puede verse flotando. Cualquier otra muerte se desploma donde está, con morir.
static func _dead(fall_severity: PlayerMotor.FallSeverity, on_floor: bool) -> StringName:
	if fall_severity != PlayerMotor.FallSeverity.LETHAL:
		return &"morir"
	return &"morir_caida" if on_floor else &"caer_largo"
