extends Node2D

onready var camera = get_node("../Player/Camera2D")

func _process(delta):
	update()
		

func _draw():
#	draw_rect(camera.get_rect(),Color(1,1,1))
	pass
