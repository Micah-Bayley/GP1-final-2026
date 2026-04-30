extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SettingsManager.get_setting("graphics", "fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_replay_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
