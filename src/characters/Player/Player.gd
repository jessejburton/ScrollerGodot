extends KinematicBody2D

onready var camera = get_node("Camera2D")
onready var sparks = load("res://src/effects/Sparks.tscn")

# Constants
const GRAVITY = 10
const ACCELERATION = 20
const MAX_SPEED = 100
const JUMP_HEIGHT = -200
const FRICTION = 0.2

const HURT_SOUNDS = ["res://assets/sound/Hurt3.wav","res://assets/sound/Hurt2.wav","res://assets/sound/Hurt1.wav"]
const HIT_SOUNDS = ["res://assets/sound/sword-clash-01.wav","res://assets/sound/sword-clash-02.wav","res://assets/sound/sword-clash-03.wav","res://assets/sound/sword-clash-04.wav","res://assets/sound/sword-clash-05.wav"]

# Variables
export var health: int
export var max_health: int = 6
export var max_jumps: int = 10
export var zoom_full_extents = Vector2(1,1)

var state_machine
var is_in_air: bool = true
var velocity: Vector2 = Vector2.ZERO
var jumps_left: int = max_jumps
var is_attacking: bool = false
var initiate_second_attack: bool = false
var start_zoom = Vector2(1,1)
var target_zoom = Vector2(1,1)
var zoom_speed = 2
var is_zooming = false
var follow_speed = 0.2
var has_attacked_in_air = false
var is_hit = false
var is_dead = false
var is_falling = false
var fall_time = 0
var is_invincible = false
var direction = 1
var hit_combo:int = 0

func set_health(amount):
	health = clamp(amount, 0, max_health)
	Hud.player_health = amount

func _ready():
	set_health(max_health)
	state_machine = $AnimationTree.get("parameters/playback")

func _get_unhandled_input():
	# DEV INPUT
	if Input.is_action_pressed("ui_quit"):
		get_tree().quit()
	
	if Input.is_action_pressed("ui_reset"):
		get_tree().reload_current_scene()
	# END DEV INPUT
	
	if is_hit:
		velocity.x = 0
		return
		
	if is_attacking: 
		velocity.y += 20
		
		if is_on_floor():
			velocity.x = 0
		else: 
			velocity.x *= 0.8
		return
	
	var current_animation = state_machine.get_current_node()
	velocity.y += GRAVITY	
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = MAX_SPEED
		face_right()
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -MAX_SPEED
		face_left()	
	else:
		velocity.x = 0
		idle()
			
	if is_on_floor() and velocity.x != 0 and !is_attacking:
		run()	
			
	if is_attacking and is_on_floor(): 
		velocity.x = 0			
		
	if is_on_floor():
		if Input.is_action_just_pressed("ui_attack") and !is_attacking:
			attack()
			return				
	else:
		if Input.is_action_just_pressed("ui_attack") and not has_attacked_in_air:
			air_attack()
			return
				
	if Input.is_action_just_pressed("ui_up") and jumps_left > 0 and !is_attacking:
		if is_on_floor():
			$Sounds/Jump.set_stream(load("res://assets/sound/Jump1.wav"))
		else:
			$Sounds/Jump.set_stream(load("res://assets/sound/Jump2.wav"))
		$Sounds/Jump.play()	
		velocity.y = JUMP_HEIGHT	
		jumps_left -= 1
	
	if is_on_floor():
		if is_in_air: # Just Landed
			has_attacked_in_air = false				
			if fall_time > 100:
				land_hard()
			else:
				land()	
	else:			
		if velocity.y < 0:
			jump()
		else:
			fall()
			
	if is_on_floor() and velocity.x == 0:
		idle()

func _physics_process(delta):
	_get_unhandled_input()
	
	if is_falling:
		fall_time += 1
	
	move_and_slide(velocity, Vector2.UP)
	
	if not is_hit:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var collider = collision.collider
			var is_stompable_enemy = collider.is_in_group("stompable")
			
			if is_stompable_enemy:
				if is_on_floor() and collision.normal.dot(Vector2.UP) > 0.3:
					OS.delay_msec(15)
					$Camera2D/Effects/ScreenShake.screen_shake(0.9, 5, 10)		
					zoom_camera_to(Vector2(1,1), Vector2(0.9,0.9), 2)
					velocity.y = collider.stomp_height
					collider.damage()
				else:
					damage()

	check_camera(delta)
	
func face_left():
	if !can_turn():
		return

	$Sprite.flip_h = true
	$HurtBox/CollisionShape2D.position.x = -28
	$CollisionShape2D.position.x = -6	
	direction = -1
	
func face_right():
	if !can_turn():
		return

	$Sprite.flip_h = false
	$HurtBox/CollisionShape2D.position.x = 23		
	$CollisionShape2D.position.x = 0
	direction = 1	
	
func jump():
	$Sounds/Steps.stop()
	is_in_air = true
	state_machine.travel("Jump")
	#print("Jump")
	
func fall():
	$Sounds/Steps.stop()
	is_falling = true
	state_machine.travel("Fall")
	#print("Fall")	

func run():
	if $Sounds/Steps.playing == false:
		$Sounds/Steps.play()
	state_machine.travel("Run")
	#print("Run")	
	
func idle():
	$Sounds/Steps.stop()
	state_machine.travel("Idle")
	#print("Idle")	

func attack():
	is_attacking = true
	$Timers/AttackTimer.start()
	$Sounds/Steps.stop()
	$Sounds/Attack.play()
	state_machine.travel("Attack")
	#print("Attack")	

func air_attack():
	is_attacking = true
	$Timers/AttackTimer.start()	
	$Sounds/Attack.play()
	has_attacked_in_air = true	
	state_machine.travel("AttackAir")
	velocity.y += 20
	#print("Air Attack")	

func land():
	is_falling = false
	is_in_air = false
	jumps_left = max_jumps
	state_machine.travel("Land")
	fall_time = 0
	#print("Land")	

func land_hard():
	$Sounds/Land.play()
	$Camera2D/Effects/ScreenShake.screen_shake(0.3, 3, 1)
	zoom_camera_to(Vector2(1,1), Vector2(0.8,0.8), 2)
	velocity.x = 0
	is_falling = false	
	is_in_air = false
	jumps_left = max_jumps
	state_machine.travel("LandHard")
	fall_time = 0	
	#print("Land Hard")
	
func damage():
	if not is_invincible:
		OS.delay_msec(30) # Screen Freeze Delay for Game Juice
		$Camera2D/Effects/ScreenShake.screen_shake(0.9, 5, 100)	
		zoom_camera_to(Vector2(1,1), Vector2(0.8,0.8), 2)
		#$Sounds/Hit.play()	
		SoundController.play_random_sound(HURT_SOUNDS)
		is_hit = true
		$EffectsAnimationPlayer.play("Invincible")
		is_invincible = true
		$Timers/InvincibilityTimer.start()

		set_health(health - 1)
		if health > 0:
			$Timers/HitTimer.start()
			state_machine.travel("Hit")
		else:
			death()

func death():
	$Sounds/Death.play()
	state_machine.travel("Death")
	is_dead = true
	$Timers/ResetTimer.start()
	#print("Death")
	
func invincible(duration = 3):
	is_invincible = true
	$CollisionShape2D.set_m
	$EffectsAnimationPlayer.play("Invincible")
	$Timers/InvincibilityTimer.wait_time = duration
	$Timers/InvincibilityTimer.start()
	#print("Invincible")	

func fall_off_screen():
	$Camera2D.current = false
	$Timers/ResetTimer.start()
	
func can_turn():
	return !is_hit
	
func restart_level():
	get_tree().reload_current_scene()
	
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
	else:
		if camera.zoom != zoom_full_extents:
			zoom_camera_to(zoom_full_extents)

func zoom_camera_to(to, from = camera.zoom, speed = zoom_speed):
	zoom_speed = speed
	start_zoom = from
	target_zoom = to
	is_zooming = true
	
func set_camera_zoom(vec):
	camera.zoom.x = vec.x
	camera.zoom.y = vec.y	
	
func _on_FallZone_body_entered(body):
	fall_off_screen()

func _on_ResetTimer_timeout():
	restart_level()	
	
func _on_HitTimer_timeout():
	is_hit = false

func _on_InvincibilityTimer_timeout():
	$EffectsAnimationPlayer.seek($EffectsAnimationPlayer.current_animation_length, true)
	$EffectsAnimationPlayer.play("NoEffects")
	is_invincible = false

func _on_HitBox_body_shape_entered(body_id, body, body_shape, area_shape):
	damage()
	
func _start_combo_timer(length:float):
	$Timers/ComboTimer.stop()	
	$Timers/ComboTimer.wait_time = length
	$Timers/ComboTimer.start()

func _emit_sparks(location:Vector2, force:int = 150):
	var spark = sparks.instance()
	spark.process_material.initial_velocity = force	* direction
	spark.global_position.x = location.x + 30 * direction
	spark.global_position.y = location.y
	get_tree().current_scene.add_child(spark)
	spark.set_emitting(true)
	SoundController.play_random_sound(HIT_SOUNDS)

func _on_AttackTimer_timeout():
	is_attacking = false

func _on_ComboTimer_timeout():
	hit_combo = 0


func _on_HurtBox_area_entered(area):
	hit_combo += 1

	match hit_combo:
		1:
			#$Camera2D/Effects/ScreenShake.screen_shake(0.1, 5, 5, 0)			
			_emit_sparks($HurtBox.global_position, 50)	
			_start_combo_timer(0.7)
			area.get_parent().damage(1, direction)		
		2:
			$Camera2D/Effects/ScreenShake.screen_shake(0.1, 3, 5, 0)			
			_emit_sparks($HurtBox.global_position, 100)
			_start_combo_timer(0.5)		
			area.get_parent().damage(2, direction)							
		3:
			$Camera2D/Effects/ScreenShake.screen_shake(0.5, 10, 10, 0.98)
			_emit_sparks($HurtBox.global_position, 300)
			hit_combo = 0
			area.get_parent().damage(8, direction)		
