extends Node

onready var camera = get_node("../Player/Camera2D")
const PreyScene : PackedScene = preload("res://Prey.tscn")
const spawn_area : Rect2 = Rect2(Vector2(-2970,-1440),Vector2(5800,4200)) # TODO: this is seuper peupy
const max_prey : int = 100

func spawn_prey_offscreen() -> void:
	var new_prey = PreyScene.instance()
	var extents : Vector2 = new_prey.get_node("CollisionShape2D").shape.extents
	var spawn_pos : Vector2 = rand_point_in_rect(spawn_area)
	while camera.get_rect().intersects(Rect2(spawn_pos-extents/2,extents)):
		spawn_pos = rand_point_in_rect(spawn_area)
	new_prey.position = spawn_pos
	self.add_child(new_prey)

func maxed_out() -> bool:
	return get_child_count()>=max_prey # TODO: What if children are later made that are not prey nodes?


# this can be moved out into a utilities class if I make one
static func rand_point_in_rect(r : Rect2) -> Vector2:
	return Vector2(rand_range(r.position.x,r.end.x),
				   rand_range(r.position.y,r.end.y))
