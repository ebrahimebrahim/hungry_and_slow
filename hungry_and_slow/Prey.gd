extends "Creature.gd"

export var freakout_radius = 200
export var panic_time = 3 # will be the wait_time of child node panic timer

var player_nearby = false
var last_known_player_pos = null # will be a Vector2

var max_speed = 300

onready var panic_cooldown = get_node("Panic Cooldown")


func player_spotted(pos : Vector2):
	player_nearby = true
	last_known_player_pos = pos
	panic_cooldown.stop()


func player_not_spotted():
	if panic_cooldown.is_stopped():
		panic_cooldown.start(panic_time)


func _physics_process(delta):
	if player_nearby:
		step_rotate(position - last_known_player_pos,delta)
		step_move_ahead(max_speed)
	else:
		step_rotate(direction_vec.rotated(0.5*(0.5-randf())*2*PI),delta)
		step_move_ahead(max_speed/5)



func _on_Panic_Cooldown_timeout():
	player_nearby = false
