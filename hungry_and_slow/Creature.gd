extends KinematicBody2D

export var direction_vec : Vector2 = Vector2(0,-1) setget update_direction

export var max_rot_speed = deg2rad(360*6)

var current_speed : float = 0

# The current path that this creature will walk along when step_path is called
var path = PoolVector2Array() setget set_path


func _ready():
	update_direction(direction_vec)


func update_direction(dir : Vector2) -> void :
	direction_vec = dir.normalized()
	rotation = atan2(dir.y,dir.x)+PI/2


func step_rotate(target_direction : Vector2, delta_t : float) -> bool:
	var angle_difference = direction_vec.angle_to(target_direction)
	if abs(angle_difference) < 0.02:
		update_direction(target_direction)
		return true # Return true when reached target orientation
	else:
		var delta_theta = (max_rot_speed * delta_t) * angle_difference/PI
		if abs(delta_theta) > abs(angle_difference):
			delta_theta = angle_difference
		update_direction( direction_vec.rotated(delta_theta) )
		return false




func step_move_ahead() -> void:
	move_and_slide(current_speed*direction_vec)



func set_path(new_path : PoolVector2Array):
	path = new_path

func set_destination(dest : Vector2):
	set_path(PoolVector2Array([dest]))


func step_path(delta_t : float, dist = null) -> void:
	if not dist : dist = current_speed * delta_t
	if not path or dist <= 0 : return
	step_rotate(path[0]-position,delta_t)
	var segment_length = position.distance_to(path[0])
	if dist < segment_length :
		move_and_slide( (dist/delta_t) * (path[0]-position) / segment_length  )
	elif dist >= segment_length :
		position = path[0]
		path.remove(0)
		dist -= segment_length
		step_path(delta_t,dist)
		






