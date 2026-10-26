## Qué animación muestra el soldado y a qué velocidad (D0003).
##
## Lógica pura: el nodo Player le pasa el estado del motor y la velocidad, y reproduce
## lo que esto devuelve en su AnimatedSprite2D. Los nombres son los de las animaciones
## de game/art/elyon/elyon_48_frames.tres.
##
## Regla "el motor manda los tiempos y la animación se adapta": el giro, la preparación
## y la recuperación duran lo que dice el .tres, tenga el dibujo los cuadros que tenga.
class_name PlayerAnimation
extends RefCounted

## Por debajo de esta fracción de run_speed, correr se ve como "arrancar".
const FULL_RUN_FRACTION := 0.7


## Animación para el estado del motor y la velocidad actual.
static func pick(state: PlayerMotor.State, velocity: Vector2, run_speed: float) -> StringName:
	match state:
		PlayerMotor.State.RUN:
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
			# En Godot el eje Y crece hacia abajo: velocidad Y negativa es subir.
			return &"subir" if velocity.y < 0.0 else &"caer"
		PlayerMotor.State.LAND:
			return &"aterrizar"
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
		_:
			return 0.0


## Velocidad de reproducción para que "frame_count" cuadros a "fps" duren "duration" s.
## Una animación de N cuadros a F fps dura N/F s; reproducida a (N/F) / T dura T s.
## Sin duración (0) o con datos inválidos, velocidad normal (1).
static func speed_for(frame_count: int, fps: float, duration: float) -> float:
	if duration <= 0.0 or fps <= 0.0 or frame_count <= 0:
		return 1.0
	return (frame_count / fps) / duration
