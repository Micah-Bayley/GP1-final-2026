extends ProgressBar

@onready var player = $"../../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = player.air_dashes
	player.connect("dash_changed", update_dashes)

func update_dashes(dashes: int):
	max_value = player.air_dashes
	value = dashes
