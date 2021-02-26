extends KinematicBody2D

signal on_health_updated

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
var velocity := Vector2.ZERO
var is_attacking := false
var state := 1
var has_state := false
var will_collide := false
var is_hit := false
var is_dead := false
var health := 3
var max_health := 3
var direction := 1
var stomp_height := -200
var rng := RandomNumberGenerator.new()
var is_turning := false

var times_run = 0

func _ready():
	set_physics_process(false)
	$HealthBar._on_health_updated(100)
	state_machine = $AnimationTree.get("parameters/playback") 

func _physics_process(delta):
	if not is_attacking and not is_dead:
		var action = get_input()
		velocity = move_and_slide(velocity, Vector2.UP)	
		
	if is_dead:
		dead()

func get_input():
	
	if !$RayCast2D.is_colliding() and not is_turning: # Needs to turn around
		times_run += 1
		turn_around()

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
	
func turn_around():
	is_turning = true
	if direction == 1:
		walk_left()
	else:
		walk_right()

func walk_left():
	face_left()
	velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
	state_machine.travel("Run")
	
func walk_right():
	face_right()
	velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
	state_machine.travel("Run")	
	
func face_left():
	$RayCast2D.position.x = 8
	$HitBox/CollisionShape2D.position.x = -7
	$Sprite.flip_h = true
	$Sprite.offset.x = -26
	direction = -1
	is_turning = false
	
func face_right():
	$RayCast2D.position.x = 25	
	$HitBox/CollisionShape2D.position.x = 37
	$Sprite.flip_h = false
	$Sprite.offset.x = 0
	direction = 1
	is_turning = false	
	
func charge(direction):
	is_attacking = true
	if direction >= 0:
		face_right()
	else:
		face_left()
	velocity.x = 0
	$ChargeTimer.start()

func attack():
	state_machine.travel("Attack")	
	$AttackTimer.start()
	
func idle():
	state_machine.travel("Idle")	
	velocity.x = 0
	
func dead():
	print("dead")
	set_collision_layer_bit(6,0)
	set_collision_mask_bit(1,0)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)	
	state_machine.travel("Death")
	set_physics_process(false)	
	
func death():
	#OS.delay_msec(15)
	Player.get_node("Camera2D/Effects/ScreenShake").screen_shake(0.9, 5, 10)		
	Player.zoom_camera_to(Vector2(1,1), Vector2(0.9,0.9), 2)
	$Sounds/Attack.stop()
	$Sounds/Death.play()
	$HealthBar.visible = false
	is_attacking = false # In case he was mid attack	
	is_dead = true
	velocity.x = 0 
	velocity.y = 0
	state_machine.travel("Death")
	call_deferred("dead")
	
func damage():
	is_attacking = false # In case he was mid attack	
	if not is_hit:
		#OS.delay_msec(15)
		Player.get_node("Camera2D/Effects/ScreenShake").screen_shake(0.3, 5, 10)	
		$Sounds/Hit.play()
		is_hit = true
		health -= 1
		if health < 0:
			death()
		else:
			state_machine.travel("Damage")
			$HitTimer.start()
		velocity.x = 0
		emit_signal("on_health_updated", float(health)/float(max_health)*100)
	
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
	is_attacking = false

func _on_HitBox_body_entered(body):
	body.damage()

func _on_ChargeTimer_timeout():
	if not is_dead:
		attack()
