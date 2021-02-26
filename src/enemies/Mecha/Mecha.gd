extends KinematicBody2D

signal on_BossBattle_complete

onready var Player = get_tree().get_current_scene().get_node("Player/Player")
onready var camera = get_tree().get_current_scene().get_node("Player/Player/Camera2D")
onready var Bullet = preload("res://src/enemies/Bullet/Bullet.tscn")
onready var Target = preload("res://src/enemies/Target/Target.tscn")
onready var Laser = $LaserSpawn/LaserBeam

# Constants
const GRAVITY = 10
const ACCELERATION = 2
const MAX_SPEED = 10
const JUMP_HEIGHT = -350
const FRICTION = 0.2

# Variables
export var health: int = 10
export var is_active: bool = false

var state_machine
var velocity = Vector2.ZERO
var is_attacking = false
var is_firing = false
var is_jumping = false
var is_charging = false
var has_state = false
var will_collide = false
var is_hit = false
var is_dead = false
var direction = 1
var state = 1
var max_health: int = 10
var rng = RandomNumberGenerator.new()
var target
var charge_time = 3

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
	$HealthBar._on_health_updated(100)

func get_input():	
	var current_animation = state_machine.get_current_node()
	
	velocity.y += GRAVITY	
	
	if is_jumping == true and is_on_floor(): # Just landed
		$Sounds/Death.play()
		$Sounds/Walk.play()
		is_jumping = false
		velocity.x = MAX_SPEED
	
	if not has_state and not is_hit and not is_jumping and is_active:
		if state == 0:
			walk_left()
		elif state == 1:
			walk_right()
		elif state == 2:
			jump()
		elif state == 3:
			charge()
		else:
			idle()
		has_state = true
	else:
		has_state = true

func _physics_process(delta):
	check_is_firing()
	
	if not is_attacking and not is_dead:
		var action = get_input()
		velocity = move_and_slide(velocity, Vector2.UP)	
		
	if is_dead:
		dead()
		
func face_player():
	if position.direction_to(Player.global_position).normalized().x > 0:
		face_right()
	else:
		face_left()
		
func dead():
	emit_signal("on_BossBattle_complete")
	Player.zoom_full_extents = Vector2(1,1)
	set_collision_layer_bit(6,0)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)	
	state_machine.travel("Death")
	set_physics_process(false)

func walk_left():
	state_machine.travel("Run")
	face_left()
	$Sounds/Walk.play()
	velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
	
func walk_right():
	state_machine.travel("Run")	
	face_right()
	$Sounds/Walk.play()	
	velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)	
	
func face_left():
	$LaserSpawn.rotation_degrees = 180
	$LaserSpawn.position.x = 36	
	$BulletSpawn.rotation_degrees = 180
	$BulletSpawn.position.x = 14	
	$Sprite.flip_h = true
	$Sprite.offset.x = -52
	direction = -1
	
func face_right():
	$LaserSpawn.rotation_degrees = 0	
	$LaserSpawn.position.x = 46		
	$BulletSpawn.rotation_degrees = 0
	$BulletSpawn.position.x = 72
	$Sprite.flip_h = false
	$Sprite.offset.x = 0
	direction = 1	
	
func jump():
	if not is_attacking and not is_charging:
		state_machine.travel("Run")	
		is_jumping = true
		$Sounds/Walk.stop()
		$Sounds/Jump.play()	
			
		velocity.x = MAX_SPEED * 6
		velocity.y = JUMP_HEIGHT
	
func charge(duration = charge_time):
	if not is_jumping and not is_charging and is_active:
		is_charging = true
		is_attacking = true
		$Sounds/Walk.stop()		
		velocity.x = 0
		show_target()
		get_tree().current_scene.add_child(target)
		$Timers/ChargeTimer.wait_time = duration
		$Timers/ChargeTimer.start()

func show_target():
	target = Target.instance()
	target.set_limit_y(position.y - 100, position.y + 50)
	
	if direction == -1:
		target.set_limit_x(position.x - 200, position.x - 10)	
	else:
		target.set_limit_x(position.x + 100, position.x + 200)	
		
	target.start_at(Player.global_position)
	target.move_towards(Player)

func attack():
	is_attacking = true
	randomize()
	face_player()
	var attack_state = rng.randi_range(0,1)	

	if attack_state == 0:
		fire_gun(target.global_position)
	else:
		fire_laser(target.global_position)
		
func fire_laser(fire_target):
	var rotation_degrees = rad2deg($LaserSpawn.get_angle_to(fire_target))
	if direction == -1:
		rotation_degrees += 180
		
	$LaserSpawn.rotation_degrees = rotation_degrees
	
	state_machine.travel("Fire")	
	$Sounds/Laser.play()
	$Timers/FiringTimer.start()
	$Timers/AttackTimer.start()	
	Laser.fire_laser(true)
	
func fire_gun(fire_target):
	is_firing = true	
		
	$BulletSpawn/Muzzle.set_emitting(true)	
	state_machine.travel("Fire")
	$Timers/FiringTimer.start()
	$Timers/AttackTimer.start()		

func check_is_firing():
	if is_firing and $Timers/FireRateTimer.get_time_left() == 0:
		fire()
	
func fire():
	var rotation_degrees = rad2deg($BulletSpawn.get_angle_to(Player.position))
	$BulletSpawn.rotation_degrees = rotation_degrees	
	
	var bullet = Bullet.instance()
	bullet.start_at($BulletSpawn.global_position, $BulletSpawn.rotation)
	bullet.speed = 500 * direction
	get_tree().current_scene.add_child(bullet)
	$Timers/FireRateTimer.start()
	
func idle():
	state_machine.travel("Idle")	
	velocity.x = 0
	
func death():
	#OS.delay_msec(15)
	stop_all_timers()
	is_dead = true
	velocity.x = 0 
	velocity.y = 0
	camera.get_node("Effects/ScreenShake").screen_shake(2, 10, 100)	
	is_attacking = false # In case he was mid attack	
	$BulletSpawn/Muzzle.set_emitting(false)	
	Laser.fire_laser(false)
	$Sounds/Laser.stop()
	if is_charging:
		target.queue_free()	
	$HealthBar.visible = false
	$Sounds/Walk.stop()
	$Sounds/Death.play()
	state_machine.travel("Death")
	
func damage():
	is_attacking = false # In case he was mid attack	
	if not is_hit:
		OS.delay_msec(15) #want to play with this
		camera.get_node("Effects/ScreenShake").screen_shake(0.9, 3, 50)
		$Sounds/Hit.play()
		is_hit = true
		health -= 1
		$HealthBar._on_health_updated(float(health)/float(max_health)*100)
		if health < 0:
			death()
		else:
			state_machine.travel("Damage")
			$Timers/HitTimer.start()
		velocity.x = 0
		
func stop_all_timers():
	$Timers/AttackTimer.stop()
	$Timers/MoveTimer.stop()
	$Timers/ChargeTimer.stop()
	$Timers/FiringTimer.stop()
	$Timers/FireRateTimer.stop() 
	
func _on_HurtBox_area_entered(area):
	call_deferred("damage")
	# Handled by appropriate layer / masks
	#queue_free()

func _on_MoveTimer_timeout():
	randomize()
	has_state = false
	state = rng.randi_range(0,3)

func _on_HitTimer_timeout():
	has_state = false
	is_hit = false

func _on_Detection_body_entered(body):
	if not is_attacking and not is_dead:
		face_player()
		charge()

func _on_AttackTimer_timeout():
	Laser.fire_laser(false)
	is_attacking = false

func _on_ChargeTimer_timeout():
	is_charging = false
	target.queue_free()
	attack()

func _on_FiringTimer_timeout():
	is_firing = false
	
	$BulletSpawn/Muzzle.set_emitting(false)	
	$Sounds/Laser.stop()
	
func _on_HitBox_body_entered(body):
	body.damage()
