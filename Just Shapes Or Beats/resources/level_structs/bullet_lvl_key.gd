class_name BulletLevelKey
extends BaseLevelKey


@export var type: int = 0 # (int, "Square", "Circle", "Square With Stripes")

@export var bullet_or_floor: int = 0 # (int, "Bullet", "Dance Floor")
@export var position_x: String = "0"
@export var position_y: String = "0"
@export var speed_x: String = "0"
@export var speed_y: String = "0"
@export var size: String = "16"
@export var rotation_degrees: String = "0"
@export var torque_degrees: String = "0"
@export var sin_x: float = 0
@export var sin_y: float = 0
@export var sin_freq: float = 0
@export var sin_lifetime: String = "0"
@export var sin_rotates: bool = false
@export var dance_floor_warn_time: float = 0
@export var dance_floor_here_time: float = 0


@export var drawing_extra: Array
