extends PanelContainer



const RANK_IMAGE_N = [
	preload("res://images/rank_sn.png"), 
	preload("res://images/rank_an.png"), 
	preload("res://images/rank_bn.png"), 
	preload("res://images/rank_cn.png"), 
]
const RANK_IMAGE_H = [
	preload("res://images/rank_sh.png"), 
	preload("res://images/rank_ah.png"), 
	preload("res://images/rank_bh.png"), 
	preload("res://images/rank_ch.png"), 
]







var rank: int
var hardcore: bool
var player: Player

@onready var RankSprite = $Rank
@onready var PlayerSprite = $Player
@onready var AnimPlayer = $AnimationPlayer
@onready var AnimPlayer2 = $AnimationPlayer2


func _ready():
	RankSprite.texture = RANK_IMAGE_H[rank] if hardcore else RANK_IMAGE_N[rank]
	PlayerSprite.texture = TS.PLAYER_TEXTURES[player.player_index][2]
	
	self_modulate = TS.PLAYER_COLORS[player.player_index]
	RankSprite.modulate = Color.TRANSPARENT


func play_anim():
	AnimPlayer.play("RankAppear")
