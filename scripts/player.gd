extends CharacterBody2D

@export var speed: float = 140.0
@export var accel: float = 800.0 # Lower = more slide/drift, Higher = snappier stop
@export var jump_velocity: float = -260.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, direction * speed, accel * delta)

	if direction != 0.0:
		anim.flip_h = direction < 0.0

	if not is_on_floor() and anim.sprite_frames and anim.sprite_frames.has_animation("jump"):
		if anim.animation != "jump":
			anim.play("jump")
	elif abs(velocity.x) > 8.0 and anim.animation != "run":
		anim.play("run")
	elif abs(velocity.x) <= 8.0 and anim.animation != "idle":
		anim.play("idle")

	move_and_slide()
