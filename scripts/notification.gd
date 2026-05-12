extends Label

@onready var starting_pos = $"..".position

var displaying = false
var queue = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not displaying and len(queue) > 0:
		displaying = true
		text = queue[0]
		var modulate_tween = get_tree().create_tween()
		var tween = get_tree().create_tween()
		tween.tween_property($"..","position",Vector2($"..".position.x,400),1.5)
		modulate_tween.tween_property($"..","modulate",Color(1,1,1,0),1.5)
		tween.connect("finished", display_finished)
		print(queue[0])
		queue.remove_at(0)

func display(text):
	queue.append(text)
	
func display_finished():
	displaying = false
	$"..".position = starting_pos
	$"..".modulate = Color(1,1,1,1)
	text = ""
