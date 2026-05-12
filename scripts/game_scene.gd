extends Node2D

var count = 3
var timer = Timer.new()
var current_song;

@onready var playlist = get_node("Music")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.name = "countdownTimer"
	var children = get_children()
	for c in children:
		if c.name == "CanvasLayer" or c.name == "countdownTimer":
			continue
		c.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(timer)
	timer.start(1)
	timer.connect("timeout", timer_timeout)
	
		
func timer_timeout():
	count -= 1
	$CanvasLayer/CountdownContainer/Countdown.text = str(count)
	if count == 0:
		$CanvasLayer/CountdownContainer/Countdown.text = ""
		for c in get_children():
			c.process_mode = Node.PROCESS_MODE_ALWAYS
		timer.queue_free()
		return
	timer.start(1)
