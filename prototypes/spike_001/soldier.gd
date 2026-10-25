## Spike 001: el soldado. Nodo fino: lee input, llama al motor, se mueve y elige animación.
##
## La animación es un AnimatedSprite2D (cuadro por cuadro, como se dibuja el pixel art)
## manejado desde el estado del motor. AnimationPlayer se suma cuando haya que mover
## otras cosas en sincronía (hitboxes, sonidos); para la silueta no hace falta.
class_name Spike001Soldier
extends CharacterBody2D

const SPEED_FOR_FULL_RUN := 0.7
const LAND_FLASH_TIME := 0.08

var motor: Spike001Motor
## Mediciones para el overlay: último salto, última frenada.
var last_jump_distance: float = 0.0
var last_jump_height: float = 0.0
var last_brake_distance: float = 0.0

var _takeoff: Vector2
var _peak_y: float
var _brake_start_x: float = NAN
var _land_flash: float = 0.0

@onready var _sprite: AnimatedSprite2D = %Sprite
@onready var _shape: CollisionShape2D = %Shape


## Cambia el aspecto: cuadros de animación, dónde están los pies en cada cuadro y el
## alto del cuerpo de colisión (40 px la silueta y Elyon 40; 48 px Elyon 48).
func set_look(frames: SpriteFrames, feet_in_frame: Vector2, body_height: float) -> void:
	var anim := _sprite.animation
	_sprite.sprite_frames = frames
	_sprite.offset = -feet_in_frame
	_sprite.play(anim)
	var rect := _shape.shape as RectangleShape2D
	rect.size.y = body_height
	_shape.position.y = -body_height / 2.0


func set_config(config: Spike001Config) -> void:
	if motor == null:
		motor = Spike001Motor.new(config)
	else:
		motor.config = config


func _physics_process(delta: float) -> void:
	var input := (
		Spike001Input
		. new(
			Input.get_axis("move_left", "move_right"),
			Input.is_action_just_pressed("jump"),
			Input.is_action_pressed("jump"),
		)
	)
	var before := motor.state
	var start := position
	velocity = motor.step(velocity, input, is_on_floor(), delta)
	move_and_slide()
	_measure(before, start)
	_animate(delta)


func reset_to(feet_position: Vector2) -> void:
	position = feet_position
	velocity = Vector2.ZERO
	motor.reset()


func get_bounds() -> Rect2:
	var size := (_shape.shape as RectangleShape2D).size
	return Rect2(position - Vector2(size.x / 2.0, size.y), size)


func _measure(before: Spike001Motor.State, start: Vector2) -> void:
	# El despegue se mide desde donde estaba antes de moverse en ese paso.
	if motor.just_jumped:
		_takeoff = start
		_peak_y = start.y
	if motor.state == Spike001Motor.State.AIR:
		_peak_y = minf(_peak_y, position.y)
	if motor.just_landed and _takeoff != Vector2.ZERO:
		last_jump_distance = absf(position.x - _takeoff.x)
		last_jump_height = _takeoff.y - _peak_y
		_takeoff = Vector2.ZERO
	# Frenada: desde que suelta (o pide el lado contrario) hasta que queda quieto.
	if before == Spike001Motor.State.RUN and motor.state == Spike001Motor.State.BRAKE:
		_brake_start_x = position.x
	if motor.state == Spike001Motor.State.IDLE and not is_nan(_brake_start_x):
		last_brake_distance = absf(position.x - _brake_start_x)
		_brake_start_x = NAN
	elif motor.state not in [Spike001Motor.State.BRAKE, Spike001Motor.State.IDLE]:
		_brake_start_x = NAN


func _animate(delta: float) -> void:
	_sprite.flip_h = motor.facing < 0
	_land_flash = LAND_FLASH_TIME if motor.just_landed else maxf(_land_flash - delta, 0.0)
	var cfg := motor.config
	match motor.state:
		Spike001Motor.State.IDLE:
			_play("aterrizar" if _land_flash > 0.0 else "quieto")
		Spike001Motor.State.RUN:
			var slow := absf(velocity.x) < cfg.run_speed * SPEED_FOR_FULL_RUN
			_play("arrancar" if slow else "correr")
		Spike001Motor.State.BRAKE:
			_play("frenar")
		Spike001Motor.State.TURN:
			_play("girar", cfg.turn_time)
		Spike001Motor.State.JUMP_PREP:
			_play("preparar", cfg.jump_prep_time)
		Spike001Motor.State.LAND:
			_play("aterrizar", cfg.land_recovery_time)
		_:
			_play("subir" if velocity.y < 0.0 else "caer")


## Reproduce una animación. Si se pasa "duration", la estira o acorta para que dure
## eso: así la preparación del salto se ve igual de larga que jump_prep_time.
func _play(anim: StringName, duration: float = 0.0) -> void:
	if _sprite.animation == anim and _sprite.is_playing():
		return
	var speed := 1.0
	if duration > 0.0:
		var frames := _sprite.sprite_frames
		var natural := frames.get_frame_count(anim) / frames.get_animation_speed(anim)
		speed = natural / duration
	_sprite.play(anim, speed)


func get_debug_info() -> Dictionary:
	var cfg := motor.config
	return {
		"variante": cfg.variant_name,
		"estado": Spike001Motor.State.keys()[motor.state],
		"velocidad": "(%.0f, %.0f)" % [velocity.x, velocity.y],
		"timer estado": "%.2f" % motor.get_timer(),
		"coyote / buffer": "%.2f / %.2f" % [motor.get_coyote(), motor.get_buffer()],
		"último salto":
		(
			"%.0f px lejos, %.0f px alto (%.1f / %.1f baldosas)"
			% [
				last_jump_distance,
				last_jump_height,
				last_jump_distance / 20.0,
				last_jump_height / 20.0
			]
		),
		"última caída": "%.0f px" % motor.last_fall_height,
		"última frenada": "%.0f px" % last_brake_distance,
	}
