extends Control



const VU_COUNT = 16
const FREQ_MAX = 11050.0
const WIDTH = 1152.0
const HEIGHT = 648.0
const MIN_DB = 60
const SPECTRUM_COLOR = Color(1, 1, 1, 0.1)
const SPECTRUM_COLUMN_SIZE_OFS = 5

const CONTROL_FADE_TIME = 0.5
const TRACK_PREVIEW_LEN = 15.0
const TRACK_MUSIC_FADE_TIME = 1.0
const SELECT_DIFF_SHOW_TIME = 1.0
const SELECT_DIFF_HIDE_TIME = 0.2
const LETS_GO_SLAM_TIME = 0.5
const LETS_GO_SHAKE_TIME = 0.25
const LETS_GO_SHAKE_INTENSITY: float = 50.0
const LETS_GO_STOP_TIME = 1
const LETS_GO_HIDE_TIME = 0.5
const MENU_TRACK = preload("res://scenes/menu_track.tscn")
const MAIN = preload("res://scenes/main.tscn")

enum {
	CONTROL_MAIN,
	CONTROL_TRACKS,
	CONTROL_LETS_GO,
}

var current_tracks_struct: LevelStruct
var fixing_lazy_eval: bool = false
var tracks_music_fading: bool = false
var diff_chosen_variant
var diff_selected = true


var tween_list: Array

@onready var ctrl_list = [
	$Main,
	$Tracks,
	$LetsGo,
]
@onready var MainBtn = $"%MainBtn"
@onready var LevelChoose = $"%LevelChoose"
@onready var LevelChooseBox = $"%LevelChooseBox"
@onready var TrackName = $"%TrackName"
@onready var TrackByRemixed = $"%TrackByRemixed"
@onready var TrackArtist = $"%TrackArtist"
@onready var TrackPlaylist = $"%TrackPlaylist"
@onready var TrackCover = $"%TrackCover"
@onready var TracksSideStuff = $"%TracksSideStuff"
@onready var SelectDiffHBox = $"%SelectDiffHBox"
@onready var StreamPlayer = $AudioStreamPlayer
@onready var SelectDifficulty = $SelectDifficulty
@onready var ExitPopup = $ExitPopup
@onready var spectrum: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(2, 0)



func _ready():
	SelectDifficulty.hide()

	for i in ctrl_list:
		i.hide()
		i.modulate = Color.TRANSPARENT

	var ctrl_to_show: int = GameVars.get_menu_target_ctrl()
	ctrl_list[ctrl_to_show].show()
	ctrl_list[ctrl_to_show].modulate = Color.WHITE

	for i in GameVars.STRUCT_LIST:
		var track = MENU_TRACK.instantiate()
		track.level_struct = i
		track.connect("hovered", Callable(self, "_menu_track_hovered").bind(i))
		track.connect("clicked", Callable(self, "_menu_track_pressed").bind(i))
		LevelChooseBox.add_child(track)

	give_focus_to(ctrl_to_show)





	if ctrl_to_show != CONTROL_TRACKS:
		ctrl_list[CONTROL_TRACKS].show()
		fixing_lazy_eval = true
		await get_tree().process_frame
		fixing_lazy_eval = false
		ctrl_list[CONTROL_TRACKS].hide()
	else:
		TracksSideStuff.hide()







func _process(_delta):




	queue_redraw()
	if current_tracks_struct and \
	not tracks_music_fading and \
	StreamPlayer.get_playback_position() - current_tracks_struct.playback_pos\
	>= TRACK_PREVIEW_LEN:
		tracks_music_fading = true
		var tween: Tween = create_tween()
		var __ = tween.tween_method(Callable(self, "music_set_volume_pc"), 1.0, 0.0, TRACK_MUSIC_FADE_TIME)
		var ___ = tween.tween_callback(Callable(self, "set").bind("tracks_music_fading", false))
		var ____ = tween.tween_callback(Callable(StreamPlayer, "seek").bind(current_tracks_struct.playback_pos))
		var _____ = tween.tween_method(Callable(self, "music_set_volume_pc"), 0.0, 1.0, TRACK_MUSIC_FADE_TIME)


func music_set_volume_pc(val: float):
	StreamPlayer.volume_db = linear_to_db(val)



func _draw():
	if not ctrl_list[CONTROL_TRACKS].visible:
		return

	var w = WIDTH / VU_COUNT
	var prev_hz = 0
	for i in range(VU_COUNT):
		var hz = i * FREQ_MAX / VU_COUNT
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		var height = energy * HEIGHT
		draw_rect(Rect2(
				w * i + SPECTRUM_COLUMN_SIZE_OFS,
				HEIGHT - height,
				w - 2 * SPECTRUM_COLUMN_SIZE_OFS,
				height
		), SPECTRUM_COLOR)
		prev_hz = hz


func _menu_track_hovered(struct: LevelStruct):

	if struct == current_tracks_struct:
		return

	if fixing_lazy_eval:
		return

	current_tracks_struct = struct
	TracksSideStuff.show()
	print("Hover, ", struct)

	TrackName.text = struct.song_name
	TrackByRemixed.text = "Remixed by" if struct.song_is_remix else "By"
	TrackArtist.text = struct.song_artist
	TrackPlaylist.text = struct.song_playlist
	TrackCover.texture = struct.song_cover

	StreamPlayer.stream = struct.song
	StreamPlayer.play(struct.playback_pos)


func _menu_track_pressed(struct: LevelStruct):
	print("Click, ", struct)
	show_select_diff(struct)





func show_select_diff(extra):
	SelectDifficulty.show()
	diff_selected = false
	var __ = create_tween().tween_property(SelectDifficulty, "modulate", Color.WHITE, SELECT_DIFF_SHOW_TIME).from(Color.TRANSPARENT)
	diff_chosen_variant = extra
	SelectDiffHBox.get_child(0).call_deferred("grab_focus")


func diff_btn_pressed(type: int):
	GameVars.current_mode = type
	GameVars.current_struct = current_tracks_struct
	set_main_ctrl(CONTROL_LETS_GO)
	hide_select_diff()



func hide_select_diff():
	var tween = create_tween()
	tween.tween_interval(SELECT_DIFF_HIDE_TIME)
	tween.tween_property(SelectDifficulty, "modulate", Color.TRANSPARENT, SELECT_DIFF_HIDE_TIME)
	tween.tween_callback(Callable(SelectDifficulty, "hide"))


func give_focus_to(ctrl: int):
	match ctrl:
		CONTROL_MAIN:
			MainBtn.call_deferred("grab_focus")
		CONTROL_TRACKS:
			LevelChooseBox.get_child(0).call_deferred("grab_focus")



func set_main_ctrl(type: int):

	StreamPlayer.stream = null
	if type == CONTROL_TRACKS:

		current_tracks_struct = null
		TracksSideStuff.hide()






	give_focus_to(type)



	for i in tween_list:
		i.kill()
	tween_list = []

	for i in ctrl_list.size():

		if i == type:
			ctrl_list[i].show()
			var tween = create_tween()
			tween.tween_property(ctrl_list[i], "modulate", Color.WHITE, CONTROL_FADE_TIME).from(Color.TRANSPARENT)
			tween_list.append(tween)

		else:
			var tween = create_tween()
			tween.tween_property(ctrl_list[i], "modulate", Color.TRANSPARENT, CONTROL_FADE_TIME).from(Color.WHITE)
			tween.tween_callback(Callable(ctrl_list[i], "hide"))
			tween_list.append(tween)


func _on_MainPlayBtn_pressed():
	set_main_ctrl(CONTROL_TRACKS)


func _on_TracksBackBtn_pressed():
	set_main_ctrl(CONTROL_MAIN)


func _on_LetsGo_visibility_changed():
	if ctrl_list[CONTROL_LETS_GO].visible:
		var lets_go: Control = ctrl_list[CONTROL_LETS_GO]
		var lets_go_label: Control = lets_go.get_child(0)

		var tween: Tween = create_tween()
		lets_go_label.scale = Vector2.ONE
		lets_go_label.modulate = Color.TRANSPARENT
		var __ = tween.tween_interval(SELECT_DIFF_HIDE_TIME * 2.5)
		var ___ = tween.tween_property(lets_go_label, "scale", Vector2.ONE * 0.0625, LETS_GO_SLAM_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		var ____ = tween.parallel().tween_property(lets_go_label, "modulate", Color.WHITE, LETS_GO_SLAM_TIME * 0.05)
		var _____ = tween.tween_method(Callable(self, "lets_go_shake"), LETS_GO_SHAKE_INTENSITY, 0.0, LETS_GO_SHAKE_TIME).set_trans(Tween.TRANS_LINEAR)
		var ______ = tween.tween_property(lets_go, "position:x", 1024.0, LETS_GO_HIDE_TIME).\
		set_delay(LETS_GO_STOP_TIME).\
		set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		var _______ = tween.tween_callback(Callable(get_tree(), "change_scene_to_packed").bind(MAIN))


func lets_go_shake(intensity: float):
	ctrl_list[CONTROL_LETS_GO].position = Vector2(
			randf_range( - intensity, intensity),
			randf_range( - intensity, intensity)
	)


func _on_ExitBtn_pressed():
	ExitPopup.popup()


func _on_ExitConfirm_pressed():
	get_tree().quit()


func _on_ExitCancel_pressed():
	ExitPopup.hide()


func _on_button_pressed() -> void:
	pass # Replace with function body.
