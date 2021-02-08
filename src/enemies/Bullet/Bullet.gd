extends Area2D

export var speed: float = 500
var velocity = Vector2()

func _ready():
	velocity.x = speed
	
func start_at(pos, rot):
	position = pos
	rotation = rot
	velocity = Vector2(speed, 0).rotated(rot + PI/1)
	$Sprite.rotation = abs(rot)

func _physics_process(delta):
	position = position + velocity * delta

func _on_DeathTimer_timeout():
	queue_free()
