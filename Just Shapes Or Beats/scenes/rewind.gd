extends Control

const FLASH_TIME = 0.2
const EASE_UPWARD_OFFSET = 25

@onready var MyLabel = $Label

func _ready():
	hide()

func rewind(last_rewinds: int, time: float):
	show()
	MyLabel.text = str(last_rewinds)

	var tween = create_tween()
	tween.tween_callback(Callable(self, "rewind_half").bind(last_rewinds, time)).set_delay(time * 0.5)
	tween.tween_callback(Callable(self, "hide")).set_delay(time * 0.5)

	if not GameSettings.photosens_mode:
		tween.parallel().tween_property(MyLabel, "modulate", Color.AQUA, FLASH_TIME).from(Color.WHITE)


	var tween2 = create_tween()
	tween2.tween_property(MyLabel, "position:y", MyLabel.position.y, time * 0.25).\
	from(MyLabel.position.y + EASE_UPWARD_OFFSET)
	tween2.parallel().tween_property(MyLabel, "modulate", Color.AQUA, time * 0.25).\
	from(Color.TRANSPARENT)


func rewind_half(last_rewinds: int, _time: float):
	MyLabel.text = str(last_rewinds - 1)
