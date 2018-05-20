#Collectibles
extends Area2D

#Export variable to menu
export(String, FILE, "*.tscn") var change_sprite

onready var sprite = get_node("Sprite")

func _physics_process(delta):
	#display sprite
	
	#Initialize Variables
	var bodies = get_overlapping_bodies()
	sprite.set_texture(change_sprite)
	for body in bodies:
		if body.name == "Player":
			queue_free()

