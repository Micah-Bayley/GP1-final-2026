extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("Body enetered")
	if body.has_method("add_dash"):
		body.add_dash()
		queue_free()
