extends Resource
















static func get_shape_data() -> Array:
	return [
		
		{
			type = Physics2DServer.SHAPE_RECTANGLE, 
			data = Vector2(0.5, 0.5), 
		}, 
		
		{
			type = Physics2DServer.SHAPE_CIRCLE, 
			data = 0.5
		}, 
		
		{
			type = Physics2DServer.SHAPE_RECTANGLE, 
			data = Vector2(0.5, 0.5), 
		}, 
	]
