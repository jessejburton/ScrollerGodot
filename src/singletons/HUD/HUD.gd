extends CanvasLayer

onready var Health = $MarginContainer/Health

export var player_health: int setget set_player_health
	
func set_player_health(health):
	for index in Health.get_child_count():
		Health.get_child(index).visible = health > index
	
