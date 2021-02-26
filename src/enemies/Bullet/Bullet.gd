extends Area2D

export var speed: float = 500
var velocity = Vector2()

func _ready():
	randomize()
	var bullet_sound = AudioStreamPlayer.new()
	bullet_sound.volume_db = -10.0	
	self.add_child(bullet_sound)
	bullet_sound.stream = load("res://assets/sound/gunfire.wav")
	bullet_sound.play()
	set_process(true)
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

func _on_Bullet_body_entered(body):
	body.damage()
