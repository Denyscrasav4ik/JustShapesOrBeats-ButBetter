extends CanvasLayer





var last_intensity: float
var tween: Tween

@onready var Rect = $ColorRect


func _ready():
	GameMethods.var_screen_flash = Callable(self, "screen_flash")


func screen_flash(time: float, intensity: float = 1):
	if GameSettings.photosens_mode: return
	Rect.color = Color(1, 1, 1, intensity)

	if tween and tween.is_running() and intensity >= last_intensity:
		tween.kill()
	last_intensity = intensity
	tween = create_tween()
	var __ = tween.tween_property(Rect, "color", Color.TRANSPARENT, time)
