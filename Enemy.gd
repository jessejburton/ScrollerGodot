extends KinematicBody2D

const GRAVITY = 10

var velocity = Vector2.ZERO

func get_input():
	velocity.y += GRAVITY
	
func _physics_process(delta):
	var action = get_input()

	velocity = move_and_slide(velocity, Vector2.UP)		


func _on_HurtBox_area_entered(area):
	queue_free()
