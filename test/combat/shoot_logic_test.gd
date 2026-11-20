# Tests de ShootLogic (F012). Se simula en pasos de 1/60 s, como corre la física de Godot.
extends GdUnitTestSuite

const DT := 1.0 / 60.0
const READY := ShootLogic.Stance.READY
const MOVING := ShootLogic.Stance.MOVING
const AIR := ShootLogic.Stance.AIR
const BUSY := ShootLogic.Stance.BUSY

var _config: ShootConfig
var _shoot: ShootLogic


func before_test() -> void:
	_config = ShootConfig.new()
	_shoot = ShootLogic.new(_config)


# Un paso con el botón: held = sigue apretado, pressed = se apretó en este paso.
func _step(held: bool, pressed: bool, stance: ShootLogic.Stance = READY) -> bool:
	return _shoot.step(held, pressed, stance, DT)


func test_f012_ac01_aim_from_up_down() -> void:
	assert_int(ShootLogic.aim_from(true, false)).is_equal(ShootLogic.Aim.UP)
	assert_int(ShootLogic.aim_from(false, true)).is_equal(ShootLogic.Aim.DOWN)
	assert_int(ShootLogic.aim_from(true, true)).is_equal(ShootLogic.Aim.FORWARD)
	assert_int(ShootLogic.aim_from(false, false)).is_equal(ShootLogic.Aim.FORWARD)


func test_f012_ac02_direction_by_aim_facing_and_air() -> void:
	var tolerance := Vector2(0.001, 0.001)
	assert_vector(ShootLogic.direction(ShootLogic.Aim.FORWARD, 1, _config, false)).is_equal_approx(
		Vector2(1, 0), tolerance
	)
	assert_vector(ShootLogic.direction(ShootLogic.Aim.UP, -1, _config, false)).is_equal_approx(
		Vector2(-0.766, -0.643), tolerance
	)
	assert_vector(ShootLogic.direction(ShootLogic.Aim.DOWN, 1, _config, false)).is_equal_approx(
		Vector2(0.940, 0.342), tolerance
	)
	assert_vector(ShootLogic.direction(ShootLogic.Aim.DOWN, 1, _config, true)).is_equal_approx(
		Vector2(0.707, 0.707), tolerance
	)


func test_f012_ac03_auto_fires_seven_shots_in_sixty_steps() -> void:
	var shots: Array[int] = []
	for i in 60:
		if _step(true, i == 0):
			shots.append(i)
	assert_array(shots).contains_exactly([0, 9, 18, 27, 36, 45, 54])


func test_f012_ac04_repress_does_not_beat_cadence() -> void:
	assert_bool(_step(true, true)).is_true()
	# Suelta en los pasos 1 y 2 y vuelve a apretar en el 3.
	_step(false, false)
	_step(false, false)
	var first_after := -1
	for i in range(3, 20):
		if _step(true, i == 3):
			first_after = i
			break
	assert_int(first_after).is_equal(9)


func test_f012_ac05_stance_for_motor_states() -> void:
	var expected := {
		PlayerMotor.State.IDLE: READY,
		PlayerMotor.State.RUN: MOVING,
		PlayerMotor.State.BRAKE: MOVING,
		PlayerMotor.State.AIR: AIR,
		PlayerMotor.State.TURN: BUSY,
		PlayerMotor.State.JUMP_PREP: BUSY,
		PlayerMotor.State.LAND: BUSY,
		PlayerMotor.State.ROLL: BUSY,
		PlayerMotor.State.DEAD: BUSY,
	}
	for state: PlayerMotor.State in expected:
		assert_int(ShootLogic.stance_for(state)).is_equal(expected[state])


func test_f012_ac05_fires_when_ready_moving_or_air() -> void:
	for stance in [READY, MOVING, AIR]:
		var shoot := ShootLogic.new(_config)
		assert_bool(shoot.step(true, true, stance, DT)).is_true()


func test_f012_ac05_no_fire_when_busy() -> void:
	for i in 60:
		assert_bool(_step(true, i == 0, BUSY)).is_false()


func test_f012_ac05_fires_when_back_from_busy() -> void:
	assert_bool(_step(true, true)).is_true()
	# Mantiene apretado mientras gira: no sale nada, aunque pase el intervalo.
	for i in 20:
		assert_bool(_step(true, false, BUSY)).is_false()
	# Primer paso en que puede: dispara en el acto.
	assert_bool(_step(true, false, MOVING)).is_true()


func test_f012_ac06_muzzle_mirrors_with_facing() -> void:
	assert_vector(ShootLogic.muzzle(ShootLogic.Aim.FORWARD, 1, _config)).is_equal(Vector2(33, -52))
	assert_vector(ShootLogic.muzzle(ShootLogic.Aim.FORWARD, -1, _config)).is_equal(
		Vector2(-33, -52)
	)
	assert_vector(ShootLogic.muzzle(ShootLogic.Aim.UP, -1, _config)).is_equal(Vector2(-26, -66))
	assert_vector(ShootLogic.muzzle(ShootLogic.Aim.DOWN, 1, _config)).is_equal(Vector2(29, -42))


func test_pose_lasts_aim_pose_time_after_last_shot() -> void:
	_step(true, true)
	assert_bool(_shoot.is_in_pose()).is_true()
	# 0,6 s son 36 pasos: en el 35 sigue en pose y en el 36 ya no.
	for i in 35:
		_step(false, false)
	assert_bool(_shoot.is_in_pose()).is_true()
	_step(false, false)
	assert_bool(_shoot.is_in_pose()).is_false()


func test_pose_ends_when_busy() -> void:
	_step(true, true)
	_step(false, false, BUSY)
	assert_bool(_shoot.is_in_pose()).is_false()
