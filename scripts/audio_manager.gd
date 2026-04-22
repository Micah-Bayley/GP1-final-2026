extends Node

const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"

var volumes = {
	"Master" : 0.8,
	"Music" : 0.8,
	"SFX" : 0.8
}

func apply_volumes():
	var bus_index = AudioServer.get_bus_index(BUS_MASTER)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volumes[BUS_MASTER]))
	var music_index = AudioServer.get_bus_index(BUS_MUSIC)
	AudioServer.set_bus_volume_db(music_index, linear_to_db(volumes[BUS_MUSIC]))
	var sfx_index = AudioServer.get_bus_index(BUS_SFX)
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(volumes[BUS_SFX]))

func set_volume(bus: String, value: float):
	volumes[bus] = clamp(value, 0, 1)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
