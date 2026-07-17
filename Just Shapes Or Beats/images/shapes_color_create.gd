@tool
extends EditorScript






static var COLORS := PackedColorArray([
    Color(0, 1, 1),
    Color(1, 1, 0)
])


func _run():
	var img: Image = Image.new()
	img.create(256, 1, false, Image.FORMAT_RGBA8)


	false # img.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	for i in COLORS.size():
		img.set_pixel(i, 0, COLORS[i])


	print(img.save_png("images/shapes_color.png"))
