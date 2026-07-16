extends Area2D
class_name Player



















signal drift_state_update(state)



const SPEED = 175

const DASH_MULTI = 3.3
const DASH_TIME = 0.65

const DASH_VALID_TIME = 0.23

const ROTATE_SPEED = 30
const DASH_BUFFER_FRAMES = 5

const BORDER_WIDHT = 10
const DASH_SQUISH = 1.6
const NORMAL_SQUISH = 1.3
const DASH_OFFSET = 6.0
const DASH_WHITE_SCALE = 0.5
const STUNNED_MOVE_SPEED = 350
const STUN_TIME = 0.75
const STUN_TORQUE = 50
const MERCY_INVI_TIME = 2.5

const DASH_CIRCLE_TIME = 0.2
const DASH_CURVE: Curve = preload("res://resources/player_dash_curve.tres")
const WHITE_SCALE_CURVE: Curve = preload("res://resources/player_white_scale_curve.tres")
const DRIFT_ACCEL = 15.0

const BEGONE_X = - 16
const DRIFT_TEXT_HALF_TIME = 0.25
const DRIFT_TEXT_OFFSET = 5


const _AM_PLAYER = 25






export var input_format: String = "%s1"
export var input_dash: String = "dash1"
export var player_index: int = 0


export var spawn_pos: Vector2


var dash_timer: SceneTreeTimer = null
var dash_buffer_left: int = 0
var area_count: int = 0
var mercy_invi: bool = false
var max_hp: int = 3
var hp: int = 3
var last_dir: Vector2 = Vector2.RIGHT
var stunned: bool = false
var drifting: bool = false

var mercy_by_rescue: bool = false
var drift_speed = 0.0
var check_rescue_every_frame: bool = false
var mercy_time_left: float = 0.0
var dashed_still: bool = false
var gone: bool = false
var times_hit: int = 0
var times_died: int = 0


onready var texture: Texture = TS.PLAYER_TEXTURES[player_index][0]
onready var inside_texture: Texture = TS.PLAYER_TEXTURES[player_index][1]
onready var window_rect: Rect2 = get_viewport_rect().grow( - BORDER_WIDHT)
onready var Sprites = $Sprites
onready var BaseSprite = $Sprites / BaseSprite
onready var WhiteSprite = $Sprites / WhiteSprite
onready var DashBurst = $DashBurst
onready var DashBurst2 = $DashBurst2
onready var MoveParti = $MoveParti
onready var DashCircle = $DashCircle
onready var BreakParti = $BreakParti
onready var InsideSprite = $Sprites / InsideSprite
onready var RescueArea = $RescueArea
onready var DriftLight = $DriftLight
onready var MercyCircle = $MercyCircle
onready var DieParti = $DieParti
onready var HelpDrift = $DriftLight / Help
onready var MY_COLOR = TS.PLAYER_COLORS[player_index]



func _ready():
	position = spawn_pos
	BaseSprite.texture = texture
	WhiteSprite.texture = texture
	InsideSprite.texture = inside_texture
	DashBurst.texture = texture
	DashBurst2.texture = texture
	MoveParti.texture = texture
	BreakParti.texture = texture
	DashCircle.set_as_toplevel(true)
	DashCircle.modulate.g8 = player_index
	
	var tween = create_tween().set_loops()
	tween.tween_property(HelpDrift, "modulate", MY_COLOR, DRIFT_TEXT_HALF_TIME)
	tween.parallel().\
	tween_property(
			HelpDrift, 
			"rect_position", 
			HelpDrift.rect_position + Vector2(0, - DRIFT_TEXT_OFFSET), 
			DRIFT_TEXT_HALF_TIME
	)
	tween.tween_property(HelpDrift, "modulate", Color.white, DRIFT_TEXT_HALF_TIME)
	tween.parallel().tween_property(HelpDrift, "rect_position", HelpDrift.rect_position, DRIFT_TEXT_HALF_TIME)
	update_hp()
	
	
	if GameVars.current_mode == GameVars.MODE_PARTY:
		max_hp *= 2
		hp = max_hp


func _physics_process(delta):
	
	if area_count < 0:
		area_count = 0
	
	if drifting:
		
		drift_speed += DRIFT_ACCEL * delta
		
		position.x -= drift_speed * delta
		
		position += GameMethods.get_wind() * delta
		mercy_invi = false
		stunned = false
		Sprites.scale = Vector2.ONE
		
		MoveParti.emitting = false
		dash_buffer_left = 0
		BaseSprite.scale = Vector2.ONE
		if position.x <= BEGONE_X:
			gone = true
		
		if check_rescue_every_frame:
			for i in RescueArea.get_overlapping_areas():
				if can_area_rescue(i):
					rescue()
		return
	
	if mercy_invi:
		BaseSprite.modulate.r = TS.f_pingpong(Time.get_ticks_msec() * 0.01, 1.0)
	else:
		BaseSprite.modulate.r = 1
	
	if stunned:
		
		position += - last_dir.normalized() * STUNNED_MOVE_SPEED * delta
		
		position += GameMethods.get_wind() * delta
		
		position = TS.vec2_fit_in_rect(position, window_rect)
		
		Sprites.rotation += STUN_TORQUE * delta
		Sprites.position = Vector2.ZERO
		Sprites.scale = Vector2.ONE
		
		MoveParti.emitting = false
		dash_buffer_left = 0
		BaseSprite.scale = Vector2.ONE
		return
	
	

	var dir: Vector2 = TS.input_better_get_vec(input_format)
	if dir != Vector2.ZERO:
		last_dir = dir
	
	if dashed_still and dir != Vector2.ZERO:
		dashed_still = false
	
	
	if area_count and not is_invincible():
		get_hit()
	
	
	if is_dash_pressed() and not is_dashing() and not stunned:
		if dir == Vector2.ZERO:
			dashed_still = true
		else:
			dashed_still = false

		dash_timer = get_tree().create_timer(DASH_TIME, false)
		var __ = dash_timer.connect("timeout", self, "stop_dashing")
		
		
		
		var target: Particles2D = DashBurst if not DashBurst.emitting else DashBurst2
		target.rotation = dir.angle_to_point(Vector2.ZERO)
		target.restart()
		
		
		DashCircle.position = position
		var tween = create_tween()
		DashCircle.modulate.r = 0
		tween.tween_property(DashCircle, "modulate:r", 1.0, DASH_CIRCLE_TIME)
	


	
	var extra_speed = 1
	
	if dash_timer and dash_timer.time_left >= 0:
		
		var dash_point = range_lerp(
				dash_timer.time_left, 
				DASH_TIME, 
				0, 
				0, 
				1
		)
		extra_speed *= lerp(1, DASH_MULTI, DASH_CURVE.interpolate_baked(dash_point))
		
		if dashed_still:
			dir = Vector2(0.85, rand_range( - 0.1, 0.1))
	
	position += SPEED * delta * extra_speed * dir
	
	position += GameMethods.get_wind() * delta
	
	position = TS.vec2_fit_in_rect(position, window_rect)
	
	Sprites.rotation = TS.vec2_home(Vector2.ZERO, 
			
			dir if dir else Vector2.RIGHT, 
	Sprites.transform.x, delta * ROTATE_SPEED)
	
	
	var lenght = dir.length()
	
	Sprites.scale.x = lerp(1, range_lerp(
			dash_timer.time_left if dash_timer else 0.0, 
			0, 
			DASH_TIME, 
			NORMAL_SQUISH, 
			DASH_SQUISH
	), lenght)
	Sprites.scale.y = 1.0 / Sprites.scale.x
	
	
	var offset_vec: Vector2 = Vector2(range_lerp(
		dash_timer.time_left if dash_timer else 0.0, 
		0, 
		DASH_TIME, 
		0, 
		DASH_OFFSET
	), 0)
	Sprites.position = offset_vec.rotated(Sprites.rotation) * lenght
	
	var white_weight = range_lerp(
			dash_timer.time_left if dash_timer else 0.0, 
			DASH_TIME, 
			0, 
			0, 
			1
	)
	BaseSprite.scale = Vector2.ONE * range_lerp(
			WHITE_SCALE_CURVE.interpolate_baked(white_weight), 
			1, 
			0, 
			DASH_WHITE_SCALE, 
			1
	)
	
	MoveParti.rotation = dir.angle_to_point(Vector2.ZERO)
	MoveParti.emitting = not is_zero_approx(lenght)
	
	




	

	
	
	if dash_buffer_left > 0:
		dash_buffer_left -= 1


func _input(event):

	if event.is_action_pressed(input_dash):
		dash_buffer_left = DASH_BUFFER_FRAMES
	
	if event.is_action_pressed("debug_self_rescue") and OS.is_debug_build() and player_index == 0:
		rescue()
	
	if event.is_action_pressed("debug_full_hp") and OS.is_debug_build():
		hp = max_hp
		update_hp()


func is_dash_pressed():


	return dash_buffer_left > 0


func is_dashing():
	return dash_timer and dash_timer.time_left >= DASH_VALID_TIME


func is_invincible():
	return is_dashing() or mercy_invi or drifting


func stop_dashing():
	pass




func update_hp():
	var health_sector = hp / (max_hp as float)
	if mercy_by_rescue:
		health_sector = 0
	BaseSprite.modulate.g = health_sector
	WhiteSprite.modulate.g = health_sector


func get_hit():
	if drifting: return
	hp -= 1
	times_hit += 1
	update_hp()
	GameMethods.screen_flash()
	if hp <= 0:
		
		drifting = true
		times_died += 1
		
		DieParti.show()
		DieParti.restart()
		set_drift_stuff()
	else:
		start_mercy_stuff()
		stunned = true
		BreakParti.restart()
		var __ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_invi")
		var ___ = get_tree().create_timer(STUN_TIME, false).connect("timeout", self, "end_stun")


func start_mercy_stuff():
	mercy_invi = true
	MercyCircle.modulate.g = 1
	var __ = create_tween().tween_property(MercyCircle, "modulate:g", 0.0, MERCY_INVI_TIME)


func set_drift_stuff():
	RescueArea.set_collision_mask_bit(1, drifting)
	Sprites.visible = not drifting
	DriftLight.visible = drifting
	emit_signal("drift_state_update", drifting)


func end_mercy_invi():
	mercy_invi = false


func end_stun():
	stunned = false


func cp_crossed():
	if gone:
		respawn_full_hp(true)
	else:
		rescue()


func end_of_level():
	if gone:
		respawn_full_hp(true)
	else:
		rescue()
	hp = max_hp
	update_hp()


func rescue():
	
	if not drifting:

		return
	
	drift_speed = 0.0
	
	check_rescue_every_frame = false
	hp = 1
	drifting = false
	gone = false
	set_drift_stuff()
	start_mercy_stuff()
	mercy_by_rescue = true
	update_hp()
	var __ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_invi")
	var ___ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_by_rescue")


func respawn_full_hp(w_mercy: bool = false):
	position = spawn_pos
	
	drift_speed = 0.0
	
	check_rescue_every_frame = false
	hp = max_hp
	drifting = false
	gone = false
	update_hp()
	set_drift_stuff()
	
	
	
	
	DieParti.hide()
	if w_mercy:
		mercy_by_rescue = true
		start_mercy_stuff()
		update_hp()
		var __ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_invi")
		var ___ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_by_rescue")


func end_mercy_by_rescue():
	mercy_by_rescue = false
	update_hp()


func _on_Player_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if area and ("_AM_PLAYER" in area or "_AM_END_TRI" in area): return
	area_count += 1


func _on_Player_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	if area and ("_AM_PLAYER" in area or "_AM_END_TRI" in area): return
	area_count -= 1



func can_area_rescue(area: Area2D, check_rescue: Array = []) -> bool:
	
	if not drifting: return false
	
	if area == self: return false
	
	if not "_AM_PLAYER" in area: return false
	
	if "_AM_RESCUE_AREA" in area: return false
	
	
	if "mercy_by_rescue" in area and area.mercy_by_rescue:
		
		if check_rescue:
			check_rescue[0] = true
		return false
	return true


func _on_RescueArea_area_entered(area):
	var arr = [false]
	if can_area_rescue(area, arr):
		
		rescue()
	
	if arr[0]:
		check_rescue_every_frame = true


func get_rank() -> int:
	if times_hit == 0:
		return GameVars.RANK_S
	elif times_died == 0:
		return GameVars.RANK_A
	elif times_died == 1:
		return GameVars.RANK_B
	else:
		return GameVars.RANK_C
