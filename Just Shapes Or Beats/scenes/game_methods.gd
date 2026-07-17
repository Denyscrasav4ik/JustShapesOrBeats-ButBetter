extends Node

var var_get_wind: Callable
var var_camera_push: Callable
var var_camera_shake: Callable
var var_get_lo_lev_haz: Callable
var var_get_current_time: Callable
var var_set_music_pause: Callable
var var_screen_flash: Callable
var var_is_pause_acceptable: Callable
var var_get_players: Callable


func _no_func_ref() -> void:
	if get_meta("warnings", 0) < 25:
		push_warning("Callable missing or invalid")
	set_meta("warnings", get_meta("warnings", 0) + 1)


func get_wind() -> Vector2:
	if var_get_wind.is_valid():
		return var_get_wind.call()
	_no_func_ref()
	return Vector2.ZERO


func camera_push(vec: Vector2) -> void:
	if var_camera_push.is_valid():
		var_camera_push.call(vec)
	else:
		_no_func_ref()


func camera_shake(force: float, time: float, decay: bool = true) -> void:
	if var_camera_shake.is_valid():
		var_camera_shake.call(force, time, decay)
	else:
		_no_func_ref()


func get_lo_lev_haz() -> LowLevelHazards:
	if var_get_lo_lev_haz.is_valid():
		return var_get_lo_lev_haz.call()
	_no_func_ref()
	return null


func get_current_time() -> float:
	if var_get_current_time.is_valid():
		return var_get_current_time.call()
	_no_func_ref()
	return 0.0


func get_players() -> Array:
	if var_get_players.is_valid():
		return var_get_players.call()
	_no_func_ref()
	return []


func set_music_pause(paused: bool) -> void:
	if var_set_music_pause.is_valid():
		var_set_music_pause.call(paused)
	else:
		_no_func_ref()


func screen_flash(time: float = 0.1, intensity: float = 1.0) -> void:
	if var_screen_flash.is_valid():
		var_screen_flash.call(time, intensity)
	else:
		_no_func_ref()


func is_pause_acceptable() -> bool:
	if var_is_pause_acceptable.is_valid():
		return var_is_pause_acceptable.call()
	_no_func_ref()
	return true
