extends Node2D

@onready var dash_pickup = preload("res://scenes/pickups/dash_pickup.tscn")
@onready var heal_pickup = preload("res://scenes/pickups/heal_pickup.tscn")
@onready var invincible_pickup = preload("res://scenes/pickups/invincible_pickup.tscn")

func _ready() -> void:
	randomize()
	var n = randi_range(0, 2)
	var instance : Node2D
	
	match n:
		0:
			instance = dash_pickup.instantiate()
		1:
			instance = heal_pickup.instantiate()
		2:
			instance = invincible_pickup.instantiate()
	add_child(instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
