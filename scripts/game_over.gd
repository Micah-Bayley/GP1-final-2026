extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SettingsManager.get_setting("graphics", "fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	if SettingsManager.get_setting("player", "high_score"):
		$CanvasLayer/Main/VBoxContainer/HighScore/HighScoreValue.text = str(int(round(SettingsManager.get_setting("player", "high_score")))) + " m"
	$CanvasLayer/Main/VBoxContainer/Score/ScoreValue.text = str(int(round(Player.score))) + " m"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_replay_pressed() -> void:
	SceneManager.change_scene("res://scenes/game_scene.tscn")


func _on_main_menu_pressed() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn")
