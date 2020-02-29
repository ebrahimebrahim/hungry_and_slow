extends "Creature.gd"

export var panic_time = 3 # will be the wait_time of child node panic timer


enum Behavior {IDLE,
			   RUNNING_AWAY,
			   SEEKING_SAFETY}

var state : int = Behavior.IDLE

# Used for RUNNING_AWAY
var thing_running_away_from : Node = null

# Used for SEEKING_SAFETY
var last_known_danger_pos = null # will be a Vector2

var max_speed = 300

onready var panic_cooldown = get_node("Panic Cooldown")


func player_spotted(pos : Vector2):
#	player_nearby = true
#	last_known_player_pos = pos
	panic_cooldown.stop()


func player_not_spotted():
	if panic_cooldown.is_stopped():
		panic_cooldown.start(panic_time)


func _physics_process(delta):
	match state:
		Behavior.IDLE:
			step_rotate(direction_vec.rotated(0.5*(0.5-randf())*2*PI),delta)
			step_move_ahead(max_speed/5)
		Behavior.RUNNING_AWAY:
			step_rotate(position - thing_running_away_from.position,delta)
			step_move_ahead(max_speed)
		Behavior.SEEKING_SAFETY:
			step_rotate(position - last_known_danger_pos,delta)
			step_move_ahead(max_speed)




func _on_Panic_Cooldown_timeout():
	if state == Behavior.SEEKING_SAFETY:
		state = Behavior.IDLE


func _on_VisibilityRegion_body_entered(body):
	if body.is_in_group("player"):
		state = Behavior.RUNNING_AWAY
		panic_cooldown.stop()
		thing_running_away_from = body


func _on_VisibilityRegion_body_exited(body):
	if body.is_in_group("player"):
		state = Behavior.SEEKING_SAFETY
		panic_cooldown.start(panic_time)
		last_known_danger_pos = body.position

