@tool
class_name CustomNodeLevelKey
extends NodeSpawnLevelKey


@export var _scene: PackedScene: set = set__scene
@export var _extras: Dictionary: set = set__extras


func set__scene(val):
	_scene = val
	scene = val


func set__extras(val):


	_extras = val
	extras = val

