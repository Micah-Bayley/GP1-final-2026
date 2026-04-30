extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 2

var jumps_left = MAX_JUMPS
var dash_meter = 100.0 # might change

var is_dashing = false
var can_dash = true
var is_dying = false

enum State { IDLE, RUNNING, JUMPING, FALLING, DASHING, DYING, ATTACKING }
var active_state = State.IDLE

enum PowerState { NORMAL, INVINCIBLE, FAST, INFDASH }
var active_powerstate = PowerState.NORMAL

func _process(delta: float) -> void:
	if global_position.x < 0:
		print("Game lost")

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
		
	update_state()
	update_animation()
	move_and_slide()

func update_state():
	if is_dying:
		active_state = State.DYING
		return
	
	if abs(velocity.x) > 0.05 and is_on_floor():
		active_state = State.RUNNING
		return
		
	if not is_on_floor():
		if velocity.y < -0.05:
			active_state = State.JUMPING
			return
		elif velocity.y > 0.05:
			active_state = State.FALLING
			return
	
	active_state = State.IDLE
	return

func update_animation():
	match active_state:
		State.IDLE:
			$AnimationPlayer.play("idle")
		State.RUNNING:
			$AnimationPlayer.play("running")
		State.JUMPING:
			$AnimationPlayer.play("jumping")
		State.FALLING:
			$AnimationPlayer.play("falling")
		State.DASHING:
			$AnimationPlayer.play("dashing")
		State.ATTACKING:
			$AnimationPlayer.play("attacking")
		State.DYING:
			$AnimationPlayer.play("dying")

func _on_dash_duration_timeout() -> void:
	$DashDuration.stop()
	is_dashing = false


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
