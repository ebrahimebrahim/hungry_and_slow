extends Node2D

export var speed = 200
export var freakout_radius = 200

var player_nearby = false
var last_known_player_pos = null # will be a Vector2

func player_spotted(pos : Vector2):
	player_nearby = true
	last_known_player_pos = pos


func player_not_spotted():
	player_nearby = false # Todo: instead make an alert timer count down and set this false


func _process(delta):
	if player_nearby:
		position += (position - last_known_player_pos).normalized() * speed * delta
	else:
		position += Vector2(1,0).rotated(randf()*2*PI) * speed/5 * delta
