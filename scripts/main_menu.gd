extends Control

@onready
var flag_rect = $CanvasLayer/Options/VBoxContainer/SelectedLanguageBox/TextureRect

var is_exiting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_settings()
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_settings():
	AudioManager.set_volume("Master", SettingsManager.get_setting("audio", "master"))
	AudioManager.set_volume("Music", SettingsManager.get_setting("audio", "music"))
	AudioManager.set_volume("SFX", SettingsManager.get_setting("audio", "sfx"))
	$CanvasLayer/Options/VBoxContainer/MasterBox/MasterSlider.value = AudioManager.volumes["Master"] * 100
	$CanvasLayer/Options/VBoxContainer/MusicBox/MusicSlider.value = AudioManager.volumes["Music"] * 100
	$CanvasLayer/Options/VBoxContainer/SFXBox/SFXSlider.value = AudioManager.volumes["SFX"] * 100
	TranslationServer.set_locale(SettingsManager.get_setting("graphics", "language"))
	$CanvasLayer/Options/VBoxContainer/DisplayBox/CheckBox.button_pressed = SettingsManager.get_setting("graphics", "fullscreen")
	set_fullscreen()
	match SettingsManager.get_setting("graphics", "language"):
		"en": flag_rect.texture = load("res://assets/english_flag.webp")
		"fr": flag_rect.texture = load("res://assets/Flag_of_France_(1790–1794).svg.png")

func _on_save_button_pressed() -> void:
	$CanvasLayer/ClickSFX.play(0.01)
	SettingsManager.set_setting("graphics", "language", TranslationServer.get_locale())
	SettingsManager.set_setting("audio", "master", AudioManager.volumes["Master"])
	SettingsManager.set_setting("audio", "music", AudioManager.volumes["Music"])
	SettingsManager.set_setting("audio", "sfx", AudioManager.volumes["SFX"])
	SettingsManager.set_setting("graphics", "fullscreen", $CanvasLayer/Options/VBoxContainer/DisplayBox/CheckBox.button_pressed)
	SettingsManager.save_settings()
	$CanvasLayer/Options.visible = false
	$CanvasLayer/Main.visible = true


func _on_master_slider_value_changed(value: float) -> void:
	AudioManager.set_volume("Master", value / 100)
	AudioManager.apply_volumes()


func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_volume("Music", value / 100)
	AudioManager.apply_volumes()


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_volume("SFX", value / 100)
	AudioManager.apply_volumes()


func _on_english_pressed() -> void:
	$CanvasLayer/ClickSFX.play(0.01)
	TranslationServer.set_locale("en")
	flag_rect.texture = load("res://assets/english_flag.webp")


func _on_french_pressed() -> void:
	$CanvasLayer/ClickSFX.play(0.01)
	TranslationServer.set_locale("fr")
	flag_rect.texture = load("res://assets/Flag_of_France_(1790–1794).svg.png")

func set_fullscreen():
	if $CanvasLayer/Options/VBoxContainer/DisplayBox/CheckBox.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_check_box_pressed() -> void:
	$CanvasLayer/ClickSFX.play(0.01)
	set_fullscreen()
		


func _on_options_pressed() -> void:
	$CanvasLayer/Options.visible = true
	$CanvasLayer/Main.visible = false
	$CanvasLayer/ClickSFX.play(0.01)


func _on_play_pressed() -> void:
	$CanvasLayer/ClickSFX.play(0.01)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_exit_pressed() -> void:
	if not is_exiting:
		$CanvasLayer/ClickSFX.play(0.01)
	is_exiting = true
	await $CanvasLayer/ClickSFX.finished
	get_tree().quit()


func _on_tutorial_pressed() -> void:
	$CanvasLayer/ClickSFX.play(0.01)
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
