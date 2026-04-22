extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 2

var jumps_left = MAX_JUMPS
var dash_meter = 100.0 # might change

var is_dashing = false
var can_dash = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		jumps_left = MAX_JUMPS

	if Input.is_action_just_pressed("jump") and jumps_left >= 1:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		$Sprite2D.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_dash_duration_timeout() -> void:
	$DashDuration.stop()
	is_dashing = false


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
