extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 2
const MAX_AIR_DASHES = 3

var jumps_left = MAX_JUMPS
var air_dashes_left = MAX_AIR_DASHES

@export var dash_speed = 800.0
@export var dash_duration = 0.15
@export var dash_cooldown = 0.5

var dash_time_left = 0.0
var dash_cooldown_left = 0.0
var dash_direction = Vector2.ZERO

var is_dying = false

enum State { IDLE, RUNNING, JUMPING, FALLING, DASHING, DYING, ATTACKING }
var active_state = State.IDLE

enum PowerState { NORMAL, INVINCIBLE, FAST, INFDASH }
var active_powerstate = PowerState.NORMAL

func _physics_process(delta: float) -> void:
	
	handle_landing_mechanics(delta)
	
	#cooldown timer
	if dash_cooldown_left > 0:
		dash_cooldown_left -= delta
	
	#if dashing
	if dash_time_left >0:
		dash_time_left -= delta
		velocity = dash_direction * dash_speed
	else:
		handle_jump()
		handle_movement()
		handle_dash_check()
		
	update_state()
	update_animation()
	move_and_slide()

func handle_landing_mechanics(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		jumps_left = MAX_JUMPS
		air_dashes_left = MAX_AIR_DASHES


func handle_jump():
	if Input.is_action_just_pressed("jump") and jumps_left >= 1:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1


func handle_movement():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		$Sprite2D.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func handle_dash_check():
	if Input.is_action_just_pressed("LMB") and dash_cooldown_left <= 0 and air_dashes_left > 0:
		start_dash()
		air_dashes_left -= 1


func start_dash():
	var mouse_pos = get_global_mouse_position()
	dash_direction = (mouse_pos - global_position).normalized()
	
	dash_time_left = dash_duration
	dash_cooldown_left = dash_cooldown

func update_state():
	if is_dying:
		active_state = State.DYING
		return
	
	if dash_time_left > 0:
		active_state = State.DASHING
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
