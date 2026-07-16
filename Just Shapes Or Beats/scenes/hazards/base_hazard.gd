extends Node2D
class_name BaseHazard








export var wind_affected: bool = true





var spawn_time_offset: float
var end_time_offset: float


func _physics_process(delta):
	if wind_affected:
		position += GameMethods.get_wind() * delta




func _is_player_hit(_player: Player) -> bool:
	return false



func _spawn():
	pass



func _end():
	pass

