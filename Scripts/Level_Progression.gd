#Level Progression
extends Area2D

#Export variable to menu
export(String, FILE, "*.tscn") var change_level

func _physics_process(delta):
	
	
	#Initialize Variables
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			get_tree().change_scene(change_level)


