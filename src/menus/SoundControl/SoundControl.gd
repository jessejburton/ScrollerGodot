extends Control

onready var menu = $MarginContainer/CenterContainer/Menu
onready var music = menu.get_node("Music")
onready var ambient = menu.get_node("Ambient")
onready var effects = menu.get_node("Effects")

func _on_MusicVolumeContol_value_changed(value):
	SoundController.set_bus_volume("Music", value)
	
func _on_AmbientVolumeContol_value_changed(value):
	SoundController.set_bus_volume("Ambient", value)
	
func _on_SoundsVolumeContol_value_changed(value):
	SoundController.set_bus_volume("Sounds", value)
