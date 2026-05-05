extends Node2D

signal laser_touch

# Despawn when this far left of origin (adjust to your screen width)
@export var despawn_x := -800.0

var _speed := 300.0

func set_scroll_speed(s: float):
	_speed = s

func _process(delta):
	position.x -= _speed * delta
	if position.x < despawn_x:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("laser_touch")
		queue_free()
