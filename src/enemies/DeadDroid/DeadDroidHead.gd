extends KinematicBody2D

signal on_health_updated

onready var DEATH_SOUND = load("res://assets/sound/enemy_death.wav")
onready var HARD_HIT_SOUND = load("res://assets/sound/thud-1.wav")
onready var sparks = load("res://src/effects/Sparks.tscn")
onready var info_text = load("res://src/effects/Info.tscn")

const GRAVITY:int = 10
const FRICTION_GROUND:float = 0.1
const HIT_SOUNDS = ["res://assets/sound/metal-hammer-hit-01.wav","res://assets/sound/metal-hammer-hit-02.wav"]

var velocity:Vector2 = Vector2.ZERO
var rotation_speed:float = 0.0
var is_on_body:bool = true
var health:float = 20
var max_health:float = 20

func _ready():
	$HealthBar._on_health_updated(100)

func _physics_process(delta):
	if !is_on_body:
		velocity.y += GRAVITY
	
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, FRICTION_GROUND)
		rotation = lerp(rotation, 0, 0.3)
		
	rotation += rotation_speed * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
func display_info(text:String):
	var info = info_text.instance()
	info.set_text(text)	
	info.position.x = self.global_position.x
	info.position.y = self.global_position.y
	self.add_child(info)

func _disconnect_from_body(direction):
	is_on_body = false
	$HealthBar.queue_free()
	velocity.x += 100 * direction
	velocity.y += -200
	SoundController.play_sound(DEATH_SOUND, 1.5)
	_emit_sparks(self.global_position, 300)
	rotation_speed = -30
	
func _emit_sparks(location:Vector2, force:int = 150):
	var spark = sparks.instance()
	spark.process_material.initial_velocity = force
	spark.global_position.x = location.x + 30
	spark.global_position.y = location.y
	get_tree().current_scene.add_child(spark)
	spark.set_emitting(true)
	
func damage(amount:int = 1, direction:int = 1):
	health -= amount
	position.x = clamp(position.x + 1 * direction, -4, 1)
	display_info(str(amount))
	emit_signal("on_health_updated", float(health)/float(max_health)*100)
	if amount < 5:
		SoundController.play_random_sound(HIT_SOUNDS)
	else:
		SoundController.play_sound(HARD_HIT_SOUND, 2.0)
		
	if health <= 0 and is_on_body:
		_disconnect_from_body(direction)	

func _on_ResetTimer_timeout():
	if is_on_body:
		health = max_health
		$HealthBar._on_health_updated(100)
