extends "Creature.gd"

export var panic_time = 3 # will be the wait_time of child node panic timer


const TreeStructure = preload("res://TreeStructure.gd")
onready var state : TreeStructure = PreyStates.idle

# Used for RUNNING_AWAY
var thing_running_away_from : Node = null

# Used for SEEKING_SAFETY
var last_known_danger_pos = null # will be a Vector2

var max_speed = 300

onready var panic_cooldown = get_node("Panic Cooldown")




func _physics_process(delta):
	if state.IS(PreyStates.idle):
		step_rotate(direction_vec.rotated(0.5*(0.5-randf())*2*PI),delta)
		step_move_ahead(max_speed/5)
	elif state.IS(PreyStates.running_away):
		step_rotate(position - thing_running_away_from.position,delta)
		step_move_ahead(max_speed)
	elif state.IS(PreyStates.seeking_safety):
		step_rotate(position - last_known_danger_pos,delta)
		step_move_ahead(max_speed)




func _on_Panic_Cooldown_timeout():
	if state.IS(PreyStates.seeking_safety):
		state = PreyStates.idle


func _on_VisibilityRegion_body_entered(body):
	if body.is_in_group("player"):
		state = PreyStates.running_away
		panic_cooldown.stop()
		thing_running_away_from = body


func _on_VisibilityRegion_body_exited(body):
	if body.is_in_group("player"):
		state = PreyStates.seeking_safety
		panic_cooldown.start(panic_time)
		last_known_danger_pos = body.position

