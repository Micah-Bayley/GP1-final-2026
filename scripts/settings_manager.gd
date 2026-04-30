extends Node

const SETTINGS_FILE := "user://ui_settings.cfg"
const SAVE_FILE := "user://ui_savegame.json"
const SAVE_FILE_ENCRYPT := "user://ui_savegame_encrypt.json"
const PATH_TO_ENCRYPT_KEY := "res://secret_key.res"

#var encryption: Encryption
var secret_key = "CASVDFdv%^&*(safdbfnmGBFNHF467nqbw53iRSDTBFHNG@#$%5butvh3e8wgeyrhb45@#$h23SVBS456n7e94!@#$%^8mstvercwjE"

var settings : Dictionary = {
	"audio": {
		"master": 1.0,
		"music": 1.0,
		"sfx": 1.0,
		"voice": 1.0
	},
	"graphics": {
		"language": "en",
		"fullscreen": false,
		"resolution": "1920x1080"
	},
	"controls": {
		"move_up": "w",
		"move_down": "s",
		"move_left": "a",
		"move_right": "d"
	},
	"gameplay": {
		"difficulty": 1,
		"show_tutorial": true
	}
}

enum DIFFICULTY {
	EASY,
	NORMAL,
	HARD
}
var current_game_difficulty: DIFFICULTY
var difficulty_label = ["EASY", "NORMAL", "HARD"]

var save_data := {}
var config = ConfigFile.new()


# Called when the autoload initializes
func _ready():
	#encryption = ResourceLoader.load(PATH_TO_ENCRYPT_KEY)
	#secret_key = encryption.key
	load_settings()
	load_game()
	#load_game_encrypted()

# ========== SETTINGS MANAGEMENT ==========

# Get a setting value
func get_setting(category: String, key: String):
	return settings.get(category, {}).get(key, null)

# Set a setting value and save it
func set_setting(category: String, key: String, value):
	if settings.has(category):
		settings[category][key] = value
		save_settings()

# Save settings to a file
func save_settings():
	for category in settings.keys():
		for key in settings[category].keys():
			config.set_value(category, key, settings[category][key])
	config.save(SETTINGS_FILE)

# Load settings from file
func load_settings():
	var err = config.load(SETTINGS_FILE)
	
	if err != OK:
		# First launch → create file with defaults
		save_settings()
	else:
		for category in settings.keys():
			for key in settings[category].keys():
				settings[category][key] = config.get_value(category, key, settings[category][key])
	load_difficulty()

func load_difficulty():
	var set_difficulty = int(settings["gameplay"]["difficulty"])
	current_game_difficulty = clamp(set_difficulty, 0, DIFFICULTY.size() - 1)
	
func change_difficulty(new_diff: DIFFICULTY):
	current_game_difficulty = new_diff
	set_setting("gameplay", "difficulty", new_diff)
	
# ========== SAVE / LOAD GAME DATA ==========

# Save game data to a JSON file
func save_game():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()

# Load game data from a JSON file
func load_game():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var parsed = JSON.parse_string(content)
			if parsed is Dictionary:
				save_data = parsed
			file.close()
	else:
		# First run defaults
		save_data = {
			"player": {
				"level": 1,
				"hp": 100
			}
	}
	save_game()

func save_game_encrypted():
	var file = FileAccess.open_encrypted_with_pass(SAVE_FILE_ENCRYPT, FileAccess.WRITE, secret_key)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_game_encrypted():
	if FileAccess.file_exists(SAVE_FILE_ENCRYPT):
		var file = FileAccess.open_encrypted_with_pass(SAVE_FILE_ENCRYPT, FileAccess.READ, secret_key)
		if file:
			var content = file.get_as_text()
			var parsed = JSON.parse_string(content)
			if parsed is Dictionary:
				save_data = parsed
			file.close()

# Reset save data
func reset_game_data():
	save_data = {}
	save_game()
	#save_game_encrypted()
