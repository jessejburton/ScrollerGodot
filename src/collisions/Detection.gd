extends Area2D

func _on_Detection_body_entered(body):
	get_parent().detect(body)

func _on_Detection_body_exited(body):
	get_parent().undetect(body)
