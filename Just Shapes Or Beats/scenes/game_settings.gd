extends Node





enum {
	INPUT_CONFIG_SINGLE, 
	INPUT_CONFIG_MULTI_ASYM, 
	INPUT_CONFIG_MULTI_SYM, 
}


var photosens_mode: bool = false
var screen_shake: bool = true
var sound_volume: float = 1
var music_volume: float = 1
var input_config: int = 0


func update_volumes():
	AudioServer.set_bus_volume_db(3, linear2db(sound_volume))
	AudioServer.set_bus_volume_db(1, linear2db(music_volume))
