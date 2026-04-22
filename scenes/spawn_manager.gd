extends Node2D

@onready var terrain = preload("res://Scenes/terrain.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var instance = terrain.instantiate()
	add_child(instance)
	instance.global_position = $SpawnPoint.global_position
