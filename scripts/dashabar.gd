extends ProgressBar

var pos_offset = Vector2(-115, 80)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = get_global_mouse_position() + pos_offset
	visible = value != 100

func update_value(current_val):
	value = 100 - current_val
