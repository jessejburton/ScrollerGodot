extends Control\

func _on_Start_Game_pressed():
	get_tree().change_scene("res://Level1.tscn")


func _on_Quit_pressed():
	get_tree().quit()
