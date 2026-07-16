tool
class_name CustomNodeLevelKey
extends NodeSpawnLevelKey


export var _scene: PackedScene setget set__scene
export var _extras: Dictionary setget set__extras


func set__scene(val):
	_scene = val
	scene = val


func set__extras(val):


	_extras = val
	extras = val

