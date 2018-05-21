extends AudioStreamPlayer2D

onready var music = get_node("background_music")

func _process(delta):
	music.play()
