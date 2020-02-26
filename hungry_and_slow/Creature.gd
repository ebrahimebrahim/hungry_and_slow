extends Node2D

export var direction_vec = Vector2(0,-1)

export var max_speed = 400
export var speed_control_radius = 400
export var max_rot_speed = deg2rad(360*6) 


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


func step_move_ahead(speed, delta_t) -> void:
	self.position += (speed * delta_t) * direction_vec	
