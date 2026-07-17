extends Node

class ExprBaseInst:
	func if3(t, condition: bool, f):
		return t if condition else f


const COLOR_TRUE_HOT_PINK := Color("e31c79")
const COLOR_HAZARD_BLACK := Color.BLACK

static var PLAYER_COLORS := PackedColorArray([
	Color(0, 1, 1),
	Color(1, 1, 0),
])

static var POOL_VEC2_CENTERED_SQUARE := PackedVector2Array([
	Vector2(-1, 1),
	Vector2(1, 1),
	Vector2(1, -1),
	Vector2(-1, -1),
])

static var POOL_VEC2_HALF_CENTERED_SQUARE := PackedVector2Array([
	Vector2(-0.5, 0.5),
	Vector2(0.5, 0.5),
	Vector2(0.5, -0.5),
	Vector2(-0.5, -0.5),
])

const WARNING_GRADIENT = preload("res://resources/warn_hazard_gradient.tres")

const PLAYER_TEXTURES = [
	[
		preload("res://images/player_square.svg"),
		preload("res://images/player_square_inside.svg"),
		preload("res://images/player_square_big.svg"),
	],
	[
		preload("res://images/player_triangle.svg"),
		preload("res://images/player_triangle_inside.svg"),
		preload("res://images/player_triangle_big.svg"),
	],
]

var EXPR_EXTRA := ExprBaseInst.new()

@onready var DESPAWN_AREA: Rect2 = get_viewport().get_visible_rect().grow(250)


func array_unique(arr: Array) -> Array:
	var arr_unique: Array = []
	for i in arr:
		if i not in arr_unique:
			arr_unique.append(i)
	return arr_unique


func array_remove_multi(arr: Array, idxs: Array, idxs_sorted: bool = false) -> void:
	if !idxs_sorted and !array_is_sorted(idxs):
		idxs.sort()

	for i in idxs.size():
		arr.remove_at(idxs[i] - i)


func array_is_sorted(arr: Array) -> bool:
	for i in range(arr.size() - 1):
		if arr[i] > arr[i + 1]:
			return false
	return true


func vec2_fit_in_rect(vec: Vector2, rect: Rect2) -> Vector2:
	if rect.has_point(vec):
		return vec

	var sliding_vec := vec
	sliding_vec.x = clamp(sliding_vec.x, rect.position.x, rect.end.x)
	sliding_vec.y = clamp(sliding_vec.y, rect.position.y, rect.end.y)
	return sliding_vec


func vec2_home(pos_from: Vector2, pos_to: Vector2, dir: Vector2, delta: float) -> float:
	return vec2_move_toward(
		dir,
		pos_from.direction_to(pos_to),
		delta
	).angle()


func vec2_move_toward(from: Vector2, to: Vector2, delta: float) -> Vector2:
	if delta == 0.0:
		return from

	if delta > 0:
		if from == to:
			return from
	else:
		if from == -to:
			return from

	var dir: float = sign(from.dot(to.orthogonal()))

	if dir == 0:
		if (from.dot(to) >= 0 and delta > 0) or (from.dot(to) <= 0 and delta < 0):
			return from

	var vec := from

	if dir > 0:
		vec = vec.rotated(delta)
	else:
		vec = vec.rotated(-delta)

	if dir != 0 and dir != sign(vec.dot(to.orthogonal())):
		if delta > 0:
			vec = to
		else:
			vec = -to

	return vec


func input_better_get_vec(format: String, mode_2d: bool = true) -> Vector2:
	var vec := Vector2(
		Input.get_action_strength(format % "right") - Input.get_action_strength(format % "left"),
		Input.get_action_strength(format % "down") - Input.get_action_strength(format % "up")
	)

	if !mode_2d:
		vec.y *= -1

	if vec.length() > 1.0:
		vec = vec.normalized()

	return vec


func phys_2d_server_shape_create(type: int) -> RID:
	match type:
		PhysicsServer2D.SHAPE_SEGMENT:
			return PhysicsServer2D.segment_shape_create()

		PhysicsServer2D.SHAPE_CIRCLE:
			return PhysicsServer2D.circle_shape_create()

		PhysicsServer2D.SHAPE_RECTANGLE:
			return PhysicsServer2D.rectangle_shape_create()

		PhysicsServer2D.SHAPE_CAPSULE:
			return PhysicsServer2D.capsule_shape_create()

		PhysicsServer2D.SHAPE_CONVEX_POLYGON:
			return PhysicsServer2D.convex_polygon_shape_create()

		PhysicsServer2D.SHAPE_CONCAVE_POLYGON:
			return PhysicsServer2D.concave_polygon_shape_create()

		_:
			push_error("Invalid PhysicsServer2D shape type.")
			return RID()


func hazards_get_warning_color(
	lifetime: float,
	warn_time: float,
	warning_speed: float = 1.5
) -> Color:
	var color := WARNING_GRADIENT.sample(fmod(lifetime * warning_speed, 1.0))

	color.a = remap(
		lifetime,
		0.0,
		warn_time,
		0.0,
		0.5
	)

	color.a = min(color.a, 0.5)
	return color


func fract(value: float) -> float:
	return value - floor(value)


func f_pingpong(value: float, length: float) -> float:
	if length == 0.0:
		return 0.0
	return abs(fract((value - length) / (length * 2.0)) * length * 2.0 - length)
