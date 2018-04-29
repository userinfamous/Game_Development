#Start_Menu.gd
extends Control

func _on_Start_Button_pressed():
	get_tree().change_scene("res://Scenes/Level1.tscn")
	pass # replace with function body


func _on_Exit_Game_pressed():
	get_tree().quit()
	pass # replace with function body


func _on_Options_pressed():
	print("Nothing Yet!")
	pass # replace with function body
