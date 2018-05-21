#Collectibles
extends Area2D

#select animation
onready var sprite = get_node("sprite")
onready var player = get_node("Player")
onready var sound = get_node("sound")
var flag = false

func _physics_process(delta):
	sprite.animation = "spinning_coin"
	

func _on_sound_finished():
	queue_free()

func _on_Area2D_body_entered(player):
	sound.play()
	sprite.visible = false

