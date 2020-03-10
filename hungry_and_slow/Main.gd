extends Node

onready var player = get_node("Player")
onready var prey_list = get_node("PreyList")

func _process(delta):
	if not randi()%10 and not prey_list.maxed_out():
		prey_list.spawn_prey_offscreen()
#	if not randi()%10: print(prey_list.get_child_count())
		
