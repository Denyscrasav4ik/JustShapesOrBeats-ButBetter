extends Camera2D


const HALF_PUSH_TIME = 0.05

var shake_tween: Tween
var push_offsets: Dictionary = {}
var shake_force: float = 0


func _ready():
	GameMethods.var_camera_push = push_camera
	GameMethods.var_camera_shake = shake_camera


func _process(_delta):
	offset = Vector2()
	for i in push_offsets.values():
		offset += i

	if shake_force != 0.0:
		offset += Vector2(randf_range( - shake_force, shake_force), randf_range( - shake_force, shake_force))




func push_camera(vec: Vector2):
	if not GameSettings.screen_shake: return

	var string = _random_string()
	while string in push_offsets:
		string = _random_string()

	push_offsets[string] = Vector2.ZERO

	var path = NodePath("push_offsets:%s" % string)
	var tween = create_tween()

	tween.tween_property(self, path, vec, HALF_PUSH_TIME)
	tween.tween_property(self, path, Vector2.ZERO, HALF_PUSH_TIME)

	tween.tween_callback(_remove_dict.bind(string))



func shake_camera(force: float, time: float, decay: bool = true):
	if not GameSettings.screen_shake: return

	if shake_tween and shake_tween.is_running():
		shake_tween.kill()

	shake_force = force
	if decay:
		shake_tween = create_tween()
		var __ = shake_tween.tween_property(self, "shake_force", 0.0, time)
	else:
		get_tree().create_timer(time, false).timeout.connect(reset_shake_force, CONNECT_ONE_SHOT)


func reset_shake_force():
	shake_force = 0


func _remove_dict(string: String):
	var __ = push_offsets.erase(string)



func _random_string() -> String:
	return "h" + str(randi())
