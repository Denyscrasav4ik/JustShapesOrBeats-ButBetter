@tool
extends NodeSpawnLevelKey
class_name BulletPulseLevelKey








@export var base_rotation: String = "0": set = set_base_rotation
func set_base_rotation(val):
	base_rotation = val
	update_extras()


@export var amount: int: set = set_amount
func set_amount(val):
	amount = val
	update_extras()


@export var bullet_type: int: set = set_bullet_type
func set_bullet_type(val):
	bullet_type = val
	update_extras()


@export var bullet_speed: float: set = set_bullet_speed
func set_bullet_speed(val):
	bullet_speed = val
	update_extras()


@export var bullet_size: float: set = set_bullet_size
func set_bullet_size(val):
	bullet_size = val
	update_extras()


@export var bullet_extras: Dictionary: set = set_bullet_extras
func set_bullet_extras(val):
	bullet_extras = val
	update_extras()


func update_extras():
	extras = {
		rotation = base_rotation,
		__torque = TAU / amount if amount != 0 else 0.0,
		__amount = amount,
		__bullet_type = bullet_type,
		__bullet_speed = bullet_speed,
		__bullet_size = bullet_size,
		__bullet_extras = bullet_extras
	}


func _init():
	scene = preload("res://scenes/hazards/spinner_pulse.tscn")
	update_extras()
