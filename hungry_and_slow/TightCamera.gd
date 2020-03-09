extends Camera2D

func _process(delta):
	align()

# Gets global rect of camera's view
func get_rect() -> Rect2:
	var size : Vector2 = get_viewport().size
	return Rect2(to_global(position)-size/2.0,size)
	
