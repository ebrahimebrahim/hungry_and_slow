extends Node2D

export var speed = 200
export var freakout_radius = 200
onready var player = get_node("../../Player")


func _process(delta):
	if position.distance_to(player.position) < freakout_radius:
		position += (position - player.position).normalized() * speed * delta
	else:
		position += Vector2(1,0).rotated(randf()*2*PI) * speed/5 * delta
