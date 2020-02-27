extends Node2D

export var direction_vec = Vector2(0,-1)

export var max_rot_speed = deg2rad(360*6)

# The current path that this creature will walk along when step_path is called
var path = PoolVector2Array() setget set_path


func _ready():
	update_direction(self.direction_vec)


func update_direction(dir : Vector2) -> void :
	self.direction_vec = dir.normalized()
	self.rotation = atan2(dir.y,dir.x)+PI/2


func step_rotate(target_direction : Vector2, delta_t : float) -> void:
	var angle_difference = direction_vec.angle_to(target_direction)
	if abs(angle_difference) < 0.02:
		update_direction(target_direction)
	else:
		update_direction( direction_vec.rotated((max_rot_speed * delta_t) * angle_difference/PI) )




func step_move_ahead(dist : float) -> void:
	self.position += dist * direction_vec



func set_path(new_path):
	path = new_path

func step_path(dist : float) -> void:
	pass






