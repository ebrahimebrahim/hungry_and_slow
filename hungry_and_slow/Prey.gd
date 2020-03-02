extends "Creature.gd"




const TreeStructure = preload("res://TreeStructure.gd")
onready var state : TreeStructure = PreyStates.idle_stopped

# Used for running_away
var things_running_away_from : Array = [] # array of bodies

# Used for seeking_safety
var last_known_danger_pos = null # will be a Vector2

# Used for multiple behavioral states
var steer : bool = false # means we are in process of changing rotation to target dir
var target_direction : Vector2 # not assumed to be normalized


onready var max_speed = 100 + randi()%300
onready var panic_time = 1 + randf()*3 # will be the wait_time of child node panic timer
onready var panic_cooldown = get_node("Panic Cooldown")




func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	
	if state.IS(PreyStates.idle):
		if state.IS(PreyStates.idle_stopped):
			set_destination(self.position + 100*randf()*self.direction_vec.rotated(0.5*(0.5-randf())*2*PI) )
			state = PreyStates.idle_motion
		elif state.IS(PreyStates.idle_motion):
			step_path(max_speed/5 * delta, delta)
			if not path: state = PreyStates.idle_stopped
	elif state.IS(PreyStates.running_away):
		set_steering_as_needed(space_state)
		steer_or_rotate_towards(position - things_running_away_from[0].position,delta)
		step_move_ahead(max_speed)
	elif state.IS(PreyStates.seeking_safety):
		set_steering_as_needed(space_state)
		steer_or_rotate_towards(position - last_known_danger_pos,delta)
		step_move_ahead(max_speed)


# Should only be called in _physics_process
func set_steering_as_needed(space_state) -> void:
	
	# "viewcone" r and Delta_theta (the cone angle is actually 2*Delta_theta)
	var r : float = 400 # TODO determine this ray size in some better way
	var Delta_theta : float = PI/4
	
	var result = space_state.intersect_ray(position,position+r*direction_vec,[self])
	if not result: return
	if not result.collider: return
	
#	$txt.text = str(int(rad2deg(result.normal.angle_to(-direction_vec)))) # for TESTing
	
#	var collision_angle = result.normal.angle_to(-direction_vec) # 0 means head-on
#	if abs(collision_angle) > PI/4 :
#		steer = true
#		target_direction = direction_vec.slide(result.normal)
#		return
		
	# cast more rays, looking for a place to squeeze by
	var d_theta : float = $CollisionShape2D.shape.extents.x*2 / r
	var theta : float = d_theta
	while theta < Delta_theta:
		var result_left = space_state.intersect_ray(position,
			position+r*direction_vec.rotated(theta),
			[self])
		var result_right = space_state.intersect_ray(position,
			position+r*direction_vec.rotated(-theta),
			[self])
		if result_left and result_right:
			theta += d_theta
			continue
		if not result_right:
			steer = true
			target_direction = direction_vec.rotated(-theta)
			if not result_left and randi()%2 :
				target_direction = direction_vec.rotated(theta)
			return
		if not result_left:
			steer = true
			target_direction = direction_vec.rotated(theta)
			return
	
	steer=true
	theta = (2*(randi()%2)-1) * (PI/2 + randf()*PI/2)
	target_direction = direction_vec.rotated(theta)
	


func steer_or_rotate_towards(target_dir : Vector2, delta : float) -> void:
	if steer :
		if step_rotate(target_direction,delta): steer = false
	else:
		step_rotate(target_dir,delta)




func _process(delta):
	var l = (3-len(things_running_away_from))/3.0
	modulate.g = l
	modulate.b = l



func _on_Panic_Cooldown_timeout():
	if state.IS(PreyStates.seeking_safety):
		state = PreyStates.idle_stopped
		steer = false


func _on_VisibilityRegion_body_entered(body):
	if body.is_in_group("player") and body!=self:
		state = PreyStates.running_away
		panic_cooldown.stop()
		things_running_away_from.push_front(body)


func _on_VisibilityRegion_body_exited(body):
	if state.IS(PreyStates.running_away) and body.is_in_group("player"):
		things_running_away_from.erase(body)
		if not things_running_away_from:
			state = PreyStates.seeking_safety
			panic_cooldown.start(panic_time)
			last_known_danger_pos = body.position
		

