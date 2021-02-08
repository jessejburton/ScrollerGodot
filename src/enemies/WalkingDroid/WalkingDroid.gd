extends KinematicBody2D

onready var Player = get_tree().get_current_scene().get_node("Player/Player")

# Constants
const GRAVITY = 10
const MAX_GRAVITY = 30
const ACCELERATION = 2
const MAX_SPEED = 10
const JUMP_HEIGHT = -200
const FRICTION = 0.2

# Modifiers
var friction_modifier = 0

# Variables
var state_machine
var velocity = Vector2.ZERO
var is_attacking = false
var state = 1
var has_state = false
var will_collide = false
var is_hit = false
var is_dead = false
var health = 3
export var stomp_height = -200
var rng = RandomNumberGenerator.new()

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")

func get_input():
		
	var current_animation = state_machine.get_current_node()
	
	velocity.y += min(GRAVITY, MAX_GRAVITY)
	
	if not has_state and not is_hit:
		if state == 0:
			walk_left()
		elif state == 1:
			walk_right()
		else:
			idle()
	else:
		has_state = true
		velocity.x = 0
	
func _physics_process(delta):
	if not is_attacking and not is_dead:
		var action = get_input()
		velocity = move_and_slide(velocity, Vector2.UP)	
	if is_dead:
		state_machine.travel("Death")	

func walk_left():
	state_machine.travel("Run")
	face_left()
	velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
	
func walk_right():
	state_machine.travel("Run")	
	face_right()
	velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
	
func face_left():
	$HitBox/CollisionShape2D.position.x = -7
	$Sprite.flip_h = true
	$Sprite.offset.x = -26
	
func face_right():
	$HitBox/CollisionShape2D.position.x = 37
	$Sprite.flip_h = false
	$Sprite.offset.x = 0
	
func charge(direction):
	is_attacking = true
	if direction >= 0:
		face_right()
	else:
		face_left()
	velocity.x = 0
	print("charger")
	$ChargeTimer.start()

func attack():
	state_machine.travel("Attack")	
	$AttackTimer.start()
	
func idle():
	state_machine.travel("Idle")	
	velocity.x = 0
	
func death():
	OS.delay_msec(15)
	Player.get_node("Camera2D/Effects/ScreenShake").screen_shake(0.9, 5, 10)		
	is_attacking = false # In case he was mid attack	
	$Sounds/Death.play()
	is_dead = true
	velocity.x = 0 
	velocity.y = 0
	state_machine.travel("Death")
	set_collision_mask_bit(1,0)
	set_collision_mask_bit(2,0)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	
func damage():
	is_attacking = false # In case he was mid attack	
	if not is_hit:
		OS.delay_msec(15)
		Player.get_node("Camera2D/Effects/ScreenShake").screen_shake(0.9, 5, 10)	
		Player.zoom_camera_to(Vector2(1,1), Vector2(0.9,0.9), 2)
		$Sounds/Hit.play()
		is_hit = true
		health -= 1
		if health < 0:
			call_deferred("death")
		else:
			state_machine.travel("Damage")
			$HitTimer.start()
		velocity.x = 0
	
func _on_HurtBox_area_entered(area):
	call_deferred("damage")
	# Handled by appropriate layer / masks
	#queue_free()

func _on_MoveTimer_timeout():
	has_state = false
	state = rng.randi_range(0,2)

func _on_HitTimer_timeout():
	has_state = false
	is_hit = false

func _on_Detection_body_entered(body):
	if not is_attacking and not is_dead:
		$Sounds/Attack.play()
		charge((Player.position - position).normalized().x)

func _on_AttackTimer_timeout():
	print("end attack")
	is_attacking = false

func _on_HitBox_body_entered(body):
	body.damage()

func _on_ChargeTimer_timeout():
	attack()
