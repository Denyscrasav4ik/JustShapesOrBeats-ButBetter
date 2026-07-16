extends PanelContainer


signal hovered
signal clicked



const RANK_IMAGE_N = [
	null, 
	preload("res://images/rank_sn.png"), 
	preload("res://images/rank_an.png"), 
	preload("res://images/rank_bn.png"), 
	preload("res://images/rank_cn.png"), 
]
const RANK_IMAGE_H = [
	null, 
	preload("res://images/rank_sh.png"), 
	preload("res://images/rank_ah.png"), 
	preload("res://images/rank_bh.png"), 
	preload("res://images/rank_ch.png"), 
]

var level_struct: LevelStruct

onready var NameLabel = $"%NameLabel"
onready var ArtistLabel = $"%ArtistLabel"
onready var RankNormal = $"%RankNormal"
onready var RankHardcore = $"%RankHardcore"


func _ready():
	NameLabel.text = level_struct.song_name
	ArtistLabel.text = level_struct.song_artist
	var ranks: Array = GameVars.get_ranks(level_struct)
	
	RankNormal.texture = RANK_IMAGE_N[ranks[0] + 1]
	RankHardcore.texture = RANK_IMAGE_H[ranks[1] + 1]


func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		emit_signal("hovered")
		call_deferred("grab_focus")


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index and event.is_pressed():
			emit_signal("clicked")
	if has_focus() and event.is_action_pressed("ui_accept"):
		emit_signal("clicked")


func _on_focus_entered():
	emit_signal("hovered")
