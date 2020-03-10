extends "Creature.gd"




const TreeStructure = preload("res://TreeStructure.gd")
onready var state : TreeStructure = PreyStates.idle_stopped
const obstacle_layer : int = 2

# Used for running_away
var things_running_away_from : Array = [] # array of bodies

# Used for seeking_safety
var last_known_danger_pos = null # will be a Vector2

# Used for multiple behavioral states
var steer : bool = false setget set_steer# means we are in process of changing rotation to target_direction
var steering_lock : bool = false # when on, steering to target dir cannot be interrupted by new raycast info
var target_direction : Vector2 # not assumed to be normalized
var raycast_distance : float


onready var max_speed = 400 + randi()%300
onready var panic_time = 1 + randf()*3 # will be the wait_time of child node panic timer
onready var panic_cooldown = get_node("PanicCooldown")
onready var steering_cooldown = get_node("SteeringCooldown")


func _ready():
	max_rot_speed = deg2rad(360*3)


func set_state_idle_motion():
	state = PreyStates.idle_motion
	raycast_distance = 100
	current_speed = max_speed/5

func set_state_idle_stopped():
	state = PreyStates.idle_stopped
	set_steer(false)
	raycast_distance = 100
	current_speed = 0

func set_state_running_away(init_dir : Vector2):
	# init_dir is the initial direction to start running away towards
	# it is not assumed to be normalized
	state = PreyStates.running_away
	panic_cooldown.stop()
	raycast_distance = 400
	current_speed = max_speed
	set_steer(true,true) # set and LOCK steering
	target_direction = init_dir
	

func set_state_seeking_safety():
	state = PreyStates.seeking_safety
	panic_cooldown.start(panic_time)
	raycast_distance = 200
	current_speed = max_speed

func set_steer(desired_steer : bool, desired_lock : bool = false):
	if not steer and desired_steer :
		steering_cooldown.start( min(0.4 , raycast_distance / current_speed) )
	steer = desired_steer
	steering_lock = desired_lock
	


func _physics_process(delta):
	var space_state : Physics2DDirectSpaceState = get_world_2d().direct_space_state
	
	if state.IS(PreyStates.idle):
		if state.IS(PreyStates.idle_stopped):
			set_destination(self.position + 100*randf()*self.direction_vec.rotated(0.5*(0.5-randf())*2*PI) )
			set_state_idle_motion()
		elif state.IS(PreyStates.idle_motion):
			step_path(delta)
			if not path: set_state_idle_stopped()
			elif triple_raycast(space_state, 0): 
				set_destination(self.position + 100*randf()*self.direction_vec.rotated((0.5-randf())*2*PI))
	elif state.IS(PreyStates.running_away):
		set_steering_as_needed(space_state)
		steer_or_rotate_towards(position - things_running_away_from[0].position,delta)
		step_move_ahead()
	elif state.IS(PreyStates.seeking_safety):
		set_steering_as_needed(space_state)
		steer_or_rotate_towards(position - last_known_danger_pos,delta)
		step_move_ahead()


# Should only be called in _physics_process
func set_steering_as_needed(space_state, r : float = raycast_distance) -> void:
	
	# if steering lock enabled then we will NOT update target_direction
	if steer and steering_lock : return
	
	# "viewcone" r and Delta_theta (the cone angle is actually 2*Delta_theta)
	var Delta_theta : float = PI/4
	
	var result = space_state.intersect_ray(position,position+r*direction_vec,[self],obstacle_layer,true,true)
	if not result: return
	if not result.collider: return


	# don't try to steer around the player, just gtfo
	if result.collider.is_in_group("player"):
		target_direction = position - result.collider.position
		set_steer(true,true) # steering on and locked
		return
		
	set_steer(true)
		
	# cast more rays, looking for a place to squeeze by
	var d_theta : float = $CollisionShape2D.shape.extents.x*2 / r
	var theta : float = d_theta
	while theta < Delta_theta:
		var result_left = triple_raycast(space_state,theta,r)
		var result_right = triple_raycast(space_state,-theta,r)
		if result_left and result_right:
			theta += d_theta
			continue
		if not result_right:
			target_direction = direction_vec.rotated(-theta)
			if not result_left and randi()%2 :
				target_direction = direction_vec.rotated(theta)
			return
		if not result_left:
			target_direction = direction_vec.rotated(theta)
			return
	
	theta = (2*(randi()%2)-1) * (PI/2 + randf()*PI/2)
	target_direction = direction_vec.rotated(theta)


func triple_raycast(space_state, angle : float, r : float = raycast_distance) -> bool:
	var extents = Vector2(1.1 * $CollisionShape2D.shape.extents.x,
						  0.9 * $CollisionShape2D.shape.extents.y)
	var p1 = position+(-extents).rotated(angle)
	var p2 = position+Vector2(0,-extents.y).rotated(angle)
	var p3 = position+(Transform2D.FLIP_Y * extents).rotated(angle)
	var q1 = p1 + r*direction_vec.rotated(angle)
	var q2 = p2 + r*direction_vec.rotated(angle)
	var q3 = p3 + r*direction_vec.rotated(angle)
	var result1 = space_state.intersect_ray(p1,q1,[self], obstacle_layer,true,true)
	var result2 = space_state.intersect_ray(p2,q2,[self], obstacle_layer,true,true)
	var result3 = space_state.intersect_ray(p3,q3,[self], obstacle_layer,true,true)
	return result1 or result2 or result3



func steer_or_rotate_towards(target_dir : Vector2, delta : float) -> void:
	if steer :
		if step_rotate(target_direction,delta) and steering_cooldown.is_stopped():
			set_steer(false)
	else:
		step_rotate(target_dir,delta)




func _process(delta):
	var l = (3-len(things_running_away_from))/3.0
	modulate.g = l
	modulate.b = l
	update() # for drawing thigns that test stuff.




func _on_Panic_Cooldown_timeout():
	if state.IS(PreyStates.seeking_safety):
		set_state_idle_stopped()


func _on_VisibilityRegion_body_entered(body):
	if body.is_in_group("player") and body!=self:
		set_state_running_away(position - body.position)
		things_running_away_from.push_front(body)


func _on_VisibilityRegion_body_exited(body):
	if state.IS(PreyStates.running_away) and body.is_in_group("player"):
		things_running_away_from.erase(body)
		if not things_running_away_from:
			set_state_seeking_safety()
			last_known_danger_pos = body.position
		



func _on_HitBox_body_entered(body):
	if body.is_in_group("player"):
		queue_free()


func _draw():
	# useful for testing steering
#	draw_line(Vector2(),to_local(position+200*target_direction.normalized()),Color(1,0,0),2)
	pass
