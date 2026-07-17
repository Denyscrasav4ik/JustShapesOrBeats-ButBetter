extends Resource
















static func get_shape_data() -> Array:
	return [
		
		{
			type = PhysicsServer2D.SHAPE_RECTANGLE, 
			data = Vector2(0.5, 0.5), 
		}, 
		
		{
			type = PhysicsServer2D.SHAPE_CIRCLE, 
			data = 0.5
		}, 
		
		{
			type = PhysicsServer2D.SHAPE_RECTANGLE, 
			data = Vector2(0.5, 0.5), 
		}, 
	]
