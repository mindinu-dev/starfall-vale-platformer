extends CharacterBody2D

@export var base_speed: float = 110.0
@export var max_speed: float = 230.0
@export var speed_ramp_rate: float = 55.0     # How fast top speed builds the longer you run
@export var accel: float = 750.0              # Acceleration toward target speed
@export var stop_decel: float = 260.0         # Lower = longer glide/coast when releasing keys
@export var air_accel: float = 480.0          # Mid-air steering acceleration
@export var air_stop_decel: float = 120.0     # Mid-air horizontal drag (low = keeps jump momentum)

@export var jump_velocity: float = -260.0
@export var double_jump_velocity: float = -230.0
@export var max_air_jumps: int = 1
@export var jump_horizontal_boost: float = 25.0 # Extra push in current move direction on jump

@export var min_run_anim_scale: float = 0.8
@export var max_run_anim_scale: float = 2.2
@export var log_stop_behavior: bool = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var current_speed: float = 110.0
var air_jumps_left: int = 1
var _was_moving: bool = false
var _last_stop_type: String = "none"

func _physics_process(delta: float) -> void:
	# Reset double jump when grounded
	if is_on_floor():
		air_jumps_left = max_air_jumps
	else:
		velocity += get_gravity() * delta

	var direction := Input.get_axis("move_left", "move_right")
	var is_holding_move := direction != 0.0

	# Horizontal speed ramp + velocity-based momentum & stopping
	if is_holding_move:
		current_speed = move_toward(current_speed, max_speed, speed_ramp_rate * delta)
		var rate := accel if is_on_floor() else air_accel
		velocity.x = move_toward(velocity.x, direction * current_speed, rate * delta)
		_was_moving = true
	else:
		current_speed = move_toward(current_speed, base_speed, speed_ramp_rate * 1.5 * delta)
		var prev_vx := velocity.x
		var decel := stop_decel if is_on_floor() else air_stop_decel
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)

		# Report how the player came to a stop based on entry velocity
		if _was_moving and abs(prev_vx) > 1.0 and abs(velocity.x) <= 1.0:
			velocity.x = 0.0
			_was_moving = false
			var speed_ratio := clampf(abs(prev_vx) / max_speed, 0.0, 1.0)
			if speed_ratio > 0.75:
				_last_stop_type = "long_slide (high-speed coast)"
			elif speed_ratio > 0.35:
				_last_stop_type = "medium_roll (moderate-speed stop)"
			else:
				_last_stop_type = "short_settle (low-speed stop)"

			if log_stop_behavior:
				print("Stopped from speed %.1f -> %s" % [abs(prev_vx), _last_stop_type])

	# Ground jump & double jump (carries current horizontal velocity for longer jumps at higher speed)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
			_apply_jump_horizontal_charge(direction)
			_play_jump_anim()
		elif air_jumps_left > 0:
			air_jumps_left -= 1
			velocity.y = double_jump_velocity
			_apply_jump_horizontal_charge(direction)
			_play_jump_anim()

	# Flip sprite toward movement direction
	if direction != 0.0:
		anim.flip_h = direction < 0.0

	# Scale run animation playback rate with horizontal speed
	if anim.animation == "run":
		var speed_factor := clampf(abs(velocity.x) / max_speed, 0.0, 1.0)
		anim.speed_scale = lerpf(min_run_anim_scale, max_run_anim_scale, speed_factor)
	else:
		anim.speed_scale = 1.0

	# Animation state selection
	if not is_on_floor():
		if anim.sprite_frames and anim.sprite_frames.has_animation("jump") and anim.animation != "jump":
			anim.play("jump")
	elif abs(velocity.x) > 6.0:
		if anim.animation != "run":
			anim.play("run")
	else:
		if anim.animation != "idle":
			anim.play("idle")

	move_and_slide()

func _apply_jump_horizontal_charge(direction: float) -> void:
	# If holding left/right while jumping, add a small charge in that direction;
	# if already moving fast (like coasting), add a tiny nudge along current velocity sign
	var charge_dir := direction
	if charge_dir == 0.0 and abs(velocity.x) > 10.0:
		charge_dir = signf(velocity.x)

	if charge_dir != 0.0 and jump_horizontal_boost != 0.0:
		velocity.x += charge_dir * jump_horizontal_boost
		velocity.x = clampf(velocity.x, -max_speed * 1.15, max_speed * 1.15)

func _play_jump_anim() -> void:
	if anim.sprite_frames and anim.sprite_frames.has_animation("jump"):
		anim.play("jump")

func get_stop_status() -> String:
	return _last_stop_type  
