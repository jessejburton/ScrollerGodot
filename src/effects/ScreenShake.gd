extends Node

var current_shake_priority = 0

onready var camera = get_parent().get_parent()

func _ready():
	pass
	
func move_camera(vector):
	camera.offset = Vector2(rand_range(-vector.x, vector.x), rand_range(-vector.y, vector.y))

func screen_shake(shake_length:float, shake_power:int, shake_priority:int, zoom_amount:float = 0.9):
	if zoom_amount > 0 and zoom_amount < 1:
		get_parent().get_parent().get_parent().zoom_camera_to(Vector2(camera.zoom.x,camera.zoom.y),Vector2(max(camera.zoom.x * zoom_amount, 0.7),max(camera.zoom.y * zoom_amount, 0.7)))
	
	if shake_priority > current_shake_priority:
		current_shake_priority = shake_priority
		$Tween.interpolate_method(
			self, 
			"move_camera", 
			Vector2(shake_power, shake_power), 
			Vector2(0,0), shake_length, 
			Tween.TRANS_SINE, 
			Tween.EASE_OUT, 
			0
		)
	$Tween.start()
	
func _on_Tween_tween_completed(object, key):
	current_shake_priority = 0
