extends Node2D

onready var player = get_node("Player")
onready var prey_list = get_node("PreyList")

func _process(delta):
	for prey in prey_list.get_children():
			if prey.position.distance_to(player.position) < prey.freakout_radius:
				prey.player_spotted(player.position)
			else:
				prey.player_not_spotted()
		
