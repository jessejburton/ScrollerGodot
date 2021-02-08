extends KinematicBody2D

onready var camera = get_node("Camera2D")

# Constants
const GRAVITY = 10
const ACCELERATION = 20
const MAX_SPEED = 100
const JUMP_HEIGHT = -200
const FRICTION = 0.2

# Modifiers
var friction_modifier = 0

# Variables
var state_machine
var is_in_air = true
var velocity = Vector2.ZERO
var max_jumps = 2
var jumps_left = max_jumps
var is_attacking = false
var initiate_second_attack = false
var start_zoom = Vector2(1,1)
var target_zoom = Vector2(1,1)
var zoom_speed = 2
var is_zooming = false
var follow_speed = 0.2
var has_attacked_in_air = false
var is_hit = false
var is_dead = false
var max_health = 3
var health = 3 setget set_health
var is_falling = false
var fall_time = 0

func set_health(amount):
	health = clamp(amount, 0, max_health)

func _ready():
	var health = max_health
	state_machine = $AnimationTree.get("parameters/playback")

func get_input():
	# DEV INPUT
	if Input.is_action_pressed("ui_quit"):
		get_tree().quit()
	
	if Input.is_action_pressed("ui_reset"):
		get_tree().reload_current_scene()
	# END DEV INPUT
	
	var current_animation = state_machine.get_current_node()
	velocity.y += GRAVITY	
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
		$Sprite.flip_h = false
		$HurtBox/CollisionShape2D.position.x = 23		
		$CollisionShape2D.position.x = 0
	elif Input.is_action_pressed("ui_left"):
		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
		if not is_hit:
			$Sprite.flip_h = true
			$HurtBox/CollisionShape2D.position.x = -28
			$CollisionShape2D.position.x = -6		
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION + friction_modifier)	
	
	if not is_hit:
		if velocity.x < 1 and velocity.x > -1: # lerp seems to not quite get to 0
			velocity.x = 0
			idle()
		if velocity.x != 0 and !is_attacking:
			run()	
			
		if is_attacking: velocity.x = lerp(velocity.x, 0, FRICTION + friction_modifier)			
		
		if Input.is_action_just_pressed("ui_attack"):
			$Sounds/Attack.play()	
			attack()		
		
		if Input.is_action_just_pressed("ui_up") and jumps_left > 0 and !is_attacking:
			$Sounds/Jump.play()	
			velocity.y = JUMP_HEIGHT
			friction_modifier = -0.2	
			jumps_left -= 1
		
		if is_on_floor():
			if is_in_air == true: # Just Landed
				has_attacked_in_air = false
				friction_modifier = 0					
				if fall_time > 100:
					land_hard()
				else:
					land()
				fall_time = 0
		else:
			if Input.is_action_just_pressed("ui_attack") and not has_attacked_in_air:
				air_attack()
			elif velocity.y < 0:
				jump()
			elif velocity.y > 0:
				fall()
	else:
		velocity.x = 0
	
func _physics_process(delta):
	var action = get_input()
	
	if is_falling:
		fall_time += 1
	
	if is_attacking: 
		friction_modifier = -0.2
	else:
		friction_modifier = 0
	
	if action == "HAULT":
		velocity = move_and_slide(Vector2.ZERO, Vector2.UP)
	elif action == "WITH_SNAP":
		velocity = move_and_slide_with_snap(velocity, Vector2.UP)			
	else:
		velocity = move_and_slide(velocity, Vector2.UP)	
	
	if not is_hit:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var collider = collision.collider
			var is_enemy = collider.is_in_group("stompable")
			
			if is_enemy:
				if is_on_floor() and collision.normal.dot(Vector2.UP) > 0.3:
					OS.delay_msec(15)
					$Camera2D/Effects/ScreenShake.screen_shake(0.9, 5, 10)		
					zoom_camera_to(Vector2(1,1), Vector2(0.9,0.9), 2)
					velocity.y = collider.stomp_height
					collider.damage()
				else:
					damage()
					#velocity = velocity.bounce(collision.normal)

	check_camera(delta)
	
func check_camera(delta):
	if is_zooming:
		var start_zoom_x = lerp(start_zoom.x, target_zoom.x, zoom_speed * delta)
		var start_zoom_y = lerp(start_zoom.y, target_zoom.y, zoom_speed * delta)
		
		start_zoom = Vector2(start_zoom_x,start_zoom_y)
		
		if abs(start_zoom.x - target_zoom.x) > 0.01 or abs(start_zoom.y - target_zoom.y) > 0.01:
			set_camera_zoom(start_zoom)
		else:
			start_zoom = target_zoom
			is_zooming = false	
	
	#camera.set_global_position(lerp(camera.get_global_position(), get_global_position(), delta * follow_speed))			

func jump():
	is_in_air = true
	state_machine.travel("Jump")
	
func fall():
	is_falling = true
	state_machine.travel("Fall")

func run():
	state_machine.travel("Run")
	
func idle():
	state_machine.travel("Idle")

func attack():
	state_machine.travel("Attack")

func air_attack():
	has_attacked_in_air = true
	state_machine.travel("AttackAir")
	velocity.y = 200

func land():
	is_falling = false
	is_in_air = false
	jumps_left = max_jumps
	state_machine.travel("Land")

func land_hard():
	OS.delay_msec(100) # Screen Freeze Delay for Game Juice
	$Camera2D/Effects/ScreenShake.screen_shake(0.3, 3, 1)
	zoom_camera_to(Vector2(1,1), Vector2(0.8,0.8), 2)
	velocity.x = 0
	is_falling = false	
	is_in_air = false
	jumps_left = max_jumps
	state_machine.travel("LandHard")
	
func damage():
	OS.delay_msec(100) # Screen Freeze Delay for Game Juice
	$Camera2D/Effects/ScreenShake.screen_shake(0.9, 5, 100)	
	zoom_camera_to(Vector2(1,1), Vector2(0.8,0.8), 2)
	$Sounds/Hit.play()	
	is_hit = true
	velocity.y = 200
	health -= 1
	if health > 0:
		$HitTimer.start()
		state_machine.travel("Hit")
	else:
		death()
	
func death():
	state_machine.travel("Death")
	is_dead = true
	$ResetTimer.start()

func fall_off_screen():
	$Camera2D.current = false
	$ResetTimer.start()
	
func restart_level():
	get_tree().reload_current_scene()

func _on_FallZone_body_entered(body):
	fall_off_screen()

func _on_ResetTimer_timeout():
	restart_level()
	
func zoom_camera_to(to, from = camera.zoom, speed = zoom_speed):
	zoom_speed = speed
	start_zoom = from
	target_zoom = to
	is_zooming = true
	
func set_camera_zoom(vec):
	camera.zoom.x = vec.x
	camera.zoom.y = vec.y	
	
func _on_HitTimer_timeout():
	is_hit = false
