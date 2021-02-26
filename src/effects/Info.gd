extends Node2D

func _ready():
	$AnimationPlayer.play("DissolveUp")
	
func set_text(text):
	$Label.set_text(str(text))

func _on_DeathTimer_timeout():
	self.queue_free()
