extends Particles2D

func _on_RemoveTimer_timeout():
	self.queue_free()
