extends KinematicBody2D

signal on_health_updated
signal on_death
signal on_damage

onready var player = get_tree().get_current_scene().get_node("Player/Player")

# Sounds
onready var attack_sound := load("res://assets/sound/flying_droid_attack.wav")
onready var hit_sound := load("res://assets/sound/enemy_hit.wav")

# Constants
const GRAVITY := 30
const STATES := ["IDLE","WALK_LEFT","WALK_RIGHT"]

# Variables
var rng := RandomNumberGenerator.new()
var state_machine
var velocity := Vector2.ZERO
var is_attacking := false
var state := "WAKE"
var speed := 10
var direction := 1
var is_detected := false
var is_hit := false
var is_dead := false
var current_attack_sound
var max_health: int = 5
var health:int = 5

func _ready():
	$Timers/MoveTimer.start()
	$HealthBar._on_health_updated(100)	
	state_machine = $AnimationTree.get("parameters/playback") 	

func _physics_process(delta):	
	if is_dead:
		velocity.y += 10
		
	if is_detected:
		face_to(player.global_position)
	
	velocity.x = speed * direction
	move_and_slide(velocity, Vector2.UP)

func _get_unhandled_input():
	randomize()
	state = STATES[rng.randi_range(1,STATES.size()-1)]

	match state:
		"WAKE":
			wake()
		"IDLE":
			idle()
		"WALK_LEFT":
			walk_left()
		"WALK_RIGHT":
			walk_right()
			
func wake():
	velocity.x = 0			
	state_machine.travel("Wake")						
			
func idle():
	velocity.x = 0			
	state_machine.travel("Idle")		
	
func walk_left():
	face_left()
	velocity.x = speed
	state_machine.travel("Move")
	
func walk_right():
	face_right()	
	velocity.x = speed
	state_machine.travel("Move")	
	
func face_left():
	direction = -1
	$Sprite.flip_h = true	

func face_right():
	direction = 1
	$Sprite.flip_h = false
	
func face_to(point: Vector2):
	if global_position.x > point.x:
		face_left()
	else:
		face_right()	

func charge():
	freeze()	
	$Timers/ChargeTimer.start()
	
func attack():
	speed = 0
	is_attacking = true
	state_machine.travel("Attack")	
	current_attack_sound = SoundController.play_sound(attack_sound)
	$Timers/AttackTimer.start()
	
func cancel_attack():
	is_attacking = false
	$Timers/AttackTimer.stop()
	speed = 0
	if current_attack_sound:
		current_attack_sound.stop()
	
func damage():
	freeze()
	cancel_attack()
	speed = 0
	is_hit = true
	health -= 1
	if health < 0:
			death()
	else:
		SoundController.play_sound(hit_sound)	
		$EffectsAnimationPlayer.play("Hit")			
		state_machine.travel("Damage")
		$Timers/HitTimer.start()	
	emit_signal("on_health_updated", float(health)/float(max_health)*100)	
	
func death():
	freeze()
	stop_all_timers()
	is_attacking = false
	is_hit = false
	state_machine.travel("Death")
	velocity.y += 10
	dead()
		
func dead():
	state_machine.travel("Death")	
	is_dead = true
	
func stop_all_timers():
	$Timers/ChargeTimer.stop()
	$Timers/MoveTimer.stop()
	$Timers/AttackTimer.stop()
	$Timers/HitTimer.stop()	
	
func freeze():
	$Timers/MoveTimer.stop()
	
func unfreeze():
	$Timers/MoveTimer.start()
	
func can_detect():
	return !is_attacking and !is_hit

func detect(body):
	if !can_detect():
		return

	is_detected = true
	freeze()
	face_to(body.global_position)
	speed = 30
	charge()
	
func undetect(body):
	if !can_detect():
		return

	is_detected = false
	unfreeze()
	speed = 10
	
func _on_MoveTimer_timeout():
	if !is_attacking and !is_hit:
		_get_unhandled_input()

func _on_HitTimer_timeout():
	unfreeze()
	is_hit = false
	$EffectsAnimationPlayer.play("NoEffects")	

func _on_ChargeTimer_timeout():
	attack()

func _on_HurtBox_area_entered(area):
	damage()

func _on_HitBox_body_entered(body):
	body.damage()

func _on_AttackTimer_timeout():
	$Timers/MoveTimer.start()
	is_attacking = false
