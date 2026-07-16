extends Control


const FLASH_TIME = 0.2
const EASE_UPWARD_OFFSET = 25

onready var MyLabel = $Label


func _ready():
	hide()



func rewind(last_rewinds: int, time: float):
	show()
	MyLabel.text = last_rewinds as String


	
	var tween = create_tween()
	tween.tween_callback(self, "rewind_half", [last_rewinds, time]).set_delay(time * 0.5)
	tween.tween_callback(self, "hide").set_delay(time * 0.5)
	
	if not GameSettings.photosens_mode:
		tween.parallel().tween_property(MyLabel, "modulate", Color.aqua, FLASH_TIME).from(Color.white)
	
	
	var tween2 = create_tween()
	tween2.tween_property(MyLabel, "rect_position:y", MyLabel.rect_position.y, time * 0.25).\
	from(MyLabel.rect_position.y + EASE_UPWARD_OFFSET)
	tween2.parallel().tween_property(MyLabel, "modulate", Color.aqua, time * 0.25).\
	from(Color.transparent)


func rewind_half(last_rewinds: int, _time: float):
	MyLabel.text = (last_rewinds - 1) as String
