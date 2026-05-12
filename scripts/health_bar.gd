extends ProgressBar

@onready var player = $"../../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = player.health
	player.connect("health_changed", update_health)

func update_health(health: int):
	
	value = health
