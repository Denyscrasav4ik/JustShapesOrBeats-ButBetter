tool
extends EditorScript






const COLORS = PoolColorArray([
	Color(0, 1, 1), 
	Color(1, 1, 0), 
])


func _run():
	var img: Image = Image.new()
	img.create(256, 1, false, Image.FORMAT_RGBA8)
	
	
	img.lock()
	for i in COLORS.size():
		img.set_pixel(i, 0, COLORS[i])
	
	
	print(img.save_png("images/shapes_color.png"))
