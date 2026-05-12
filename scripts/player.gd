class_name Player
extends CharacterBody2D

signal health_changed
signal dash_changed

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_AIR_DASHES = 10
const MAX_JUMPS = 2
const MAX_HEALTH = 3

var air_dashes = 3
var jumps_left = MAX_JUMPS
var air_dashes_left = air_dashes

static var score := 0.0
var update_score = true
const PIXELS_PER_METER := 32.0

@export var health = MAX_HEALTH

@export var dash_speed = 800.0
@export var dash_duration = 0.15
@export var dash_cooldown = 0.2
@export var spawner : Node2D
@export var score_label : Label

@export var fast_powerup_speed_increase = 350.0

var dash_time_left = 0.0
var dash_cooldown_left = 0.0
var dash_direction = Vector2.ZERO
@onready var dash_bar = get_node("../CanvasLayer/dashUIcanvas/dashabar")

var is_dying = false
var is_invincible = false
enum State { IDLE, RUNNING, JUMPING, FALLING, DASHING, DYING, ATTACKING }
var active_state = State.IDLE

enum PowerState { NORMAL, INVINCIBLE, FAST, INFDASH }
var active_powerstate = PowerState.NORMAL

func _ready() -> void:
	score = 0

func _process(delta: float) -> void:
	if (global_position.x < -5 || health < 1) && !is_dying:
		die()
		is_dying = true
	if spawner and score_label and update_score:
		score += (spawner.scroll_speed * delta) / PIXELS_PER_METER
		score_label.text = "Score: " + str(int(round(score))) + "m"
	else:
		print("Please connect the spawner and the score label to the player script")
		
	if active_state == State.IDLE:
		position.x -= spawner.scroll_speed * delta

func _physics_process(delta: float) -> void:
	
	handle_landing_mechanics(delta)
	
	#cooldown timer
	if dash_cooldown_left > 0:
		dash_cooldown_left -= delta
	
	#if dashing
	dash_time_left -= delta
	if dash_time_left > 0:
		if dash_direction.x > 0:
			velocity = dash_direction * dash_speed
		else:
			velocity.x = dash_direction.x * (dash_speed + spawner.scroll_speed)
			velocity.y = dash_direction.y * dash_speed
		
		if active_powerstate == PowerState.FAST:
			velocity = dash_direction * (dash_speed + fast_powerup_speed_increase)
		else:
			velocity = dash_direction * dash_speed
		
		if active_powerstate != PowerState.INFDASH:
			update_dash_bar(dash_time_left * 500) # scale dash cooldown to percentage value
	else:
		if dash_time_left + delta > 0:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		handle_jump()
		handle_movement()
		handle_dash_check()
		
	update_state()
	update_animation()
	move_and_slide()
	
	powerup_debug()

func handle_landing_mechanics(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		jumps_left = MAX_JUMPS
		if dash_cooldown_left <= 0:
			air_dashes_left = air_dashes
			dash_changed.emit(air_dashes_left)


func handle_jump():
	if Input.is_action_just_pressed("jump") and jumps_left >= 1:
		
		#particle if air-jump
		if not is_on_floor():
			$DoubleJumpCloud.restart()
		
		$soundEffects/jump.play()
		velocity.y = JUMP_VELOCITY
		if not is_on_floor():
			jumps_left -= 2
			return
		jumps_left -= 1

func handle_movement():
	var direction := Input.get_axis("left", "right")
	if direction:
		if direction > 0:
			if active_powerstate == PowerState.FAST:
				velocity.x = (direction * SPEED) + fast_powerup_speed_increase
			else:
				velocity.x = direction * SPEED
		else:
			velocity.x = direction * (SPEED + spawner.scroll_speed)
		$Sprite2D.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
func handle_dash_check():
	if Input.is_action_just_pressed("LMB") and dash_cooldown_left <= 0 and air_dashes_left > 0:
		start_dash()
		$soundEffects/dash.play()
		if active_powerstate == PowerState.INFDASH:
			return
		air_dashes_left -= 1
		dash_changed.emit(air_dashes_left)

func powerup_debug():
	if Input.is_action_just_pressed("ui_left"):
		inf_dash()
	if Input.is_action_just_pressed("ui_right"):
		fast()

func start_dash():
	var mouse_pos = get_global_mouse_position()
	dash_direction = (mouse_pos - global_position).normalized()
	
	
	if dash_direction.x > 0 :
		$Sprite2D.scale.x = 1
	else:
		$Sprite2D.scale.x = -1
	
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
	
func on_player_laser_touch():
	if is_invincible:
		return
	health -= 1
	health_changed.emit(health)
	if $Sparks.emitting:
		$Sparks.restart()
	$Sparks.emitting = true
	
	$soundEffects/hurt.play()

func heal():
	health += 1
	health = clamp(health, 0, MAX_HEALTH)
	health_changed.emit(health)
	$"../CanvasLayer/MarginContainer3/Notification".display("1HP")
	$"../BuffSound".stop()
	$"../BuffSound".play()

func invincibility():
	is_invincible = true
	$InvincibilityTimer.start()
	modulate = Color.AQUAMARINE
	$"../BuffSound".stop()
	$"../BuffSound".play()
	$"../CanvasLayer/MarginContainer3/Notification".display("INVINCIBILITY")

func inf_dash():
	active_powerstate = PowerState.INFDASH
	$InfDashTimer.start()
	modulate = Color.PURPLE
	$"../BuffSound".stop()
	$"../BuffSound".play()
	$"../CanvasLayer/MarginContainer3/Notification".display("INFINITE_DASH")
	
func fast():
	active_powerstate = PowerState.FAST
	$FastTimer.start()
	modulate = Color.YELLOW
	$"../BuffSound".stop()
	$"../BuffSound".play()
	$"../CanvasLayer/MarginContainer3/Notification".display("SPEED")

func add_dash():
	air_dashes += 1
	air_dashes = clamp(air_dashes, 0, MAX_AIR_DASHES)
	$"../BuffSound".stop()
	$"../BuffSound".play()
	$"../CanvasLayer/MarginContainer3/Notification".display("AIR_DASH")
	dash_changed.emit(air_dashes_left)

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

func update_dash_bar(val):
	dash_bar.update_value(val)

func _on_invincibility_timer_timeout() -> void:
	is_invincible = false
	modulate = Color.WHITE

func _on_inf_dash_timer_timeout() -> void:
	
	# fail-safe incase player grabs a different power-up before
	# previous timer runs out.
	if active_powerstate == PowerState.INFDASH:
		active_powerstate = PowerState.NORMAL
		modulate = Color.WHITE

func _on_fast_timer_timeout() -> void:
	
	# fail-safe incase player grabs a different power-up before
	# previous timer runs out.
	if active_powerstate == PowerState.FAST:
		active_powerstate = PowerState.NORMAL
		modulate = Color.WHITE
		
func die():
	is_dying = true
	update_score = false
	
	velocity = Vector2.ZERO
	
	# Optional: stop movement/dashing
	dash_time_left = 0
	dash_cooldown_left = 999
	
	# Save the score if it is higher
	var high_score = SettingsManager.get_setting("player", "high_score")
	if score > high_score:
		SettingsManager.set_setting("player", "high_score", score)
		SettingsManager.save_settings()
		print(high_score)
	
	$AnimationPlayer.play("dying")
	
	await $AnimationPlayer.animation_finished
	
	SceneManager.change_scene("res://scenes/game_over.tscn")
