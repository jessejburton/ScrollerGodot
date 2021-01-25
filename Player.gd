extends KinematicBody2D

const GRAVITY = 10
const SPEED = 80
const JUMP_HEIGHT = -200
const UP = Vector2(0, -1)
var motion = Vector2()
var jumped = false
var double_jumped = false
var attacking = false
var landing = false
var has_landed = false
var has_dashed = false
var dashing = false

var speed_modifier = 1

func _physics_process(delta):
	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		motion.x = SPEED * speed_modifier
		$Sprite.flip_h = false
		if dashing == true:
			$Sprite.play("Dash")
		elif is_on_floor():
			$Sprite.play("Run")
		elif double_jumped:
			$Sprite.play("Fall")
		else:
			$Sprite.play("Jump")
			
	elif Input.is_action_pressed("ui_left"):
		motion.x = -SPEED * speed_modifier
		$Sprite.flip_h = true
		if dashing == true:
			$Sprite.play("Dash")
		elif is_on_floor():
			$Sprite.play("Run")		
		elif double_jumped:
			$Sprite.play("Fall")
		else:
			$Sprite.play("Jump")
						
	else:
		motion.x = 0	
		$Sprite.play("Idle")	
		
	if is_on_floor():
		jumped = false
		double_jumped = false
		if Input.is_action_just_pressed("ui_up"):
			motion.y = JUMP_HEIGHT
			jumped = true
		if landing:
			$Sprite.play("Landed")
			$Timer.set_wait_time(0.25)
			$Timer.start()
			has_landed = true
			landing = false
	elif !double_jumped:
		if Input.is_action_just_pressed("ui_up"):
			motion.y = JUMP_HEIGHT
			double_jumped = true
	else:
		if dashing == true:
			$Sprite.play("Dash")
		elif double_jumped:
			$Sprite.play("Fall")
		else:
			$Sprite.play("Jump")			
			
	if !is_on_floor() and !landing: 
		landing = true
		
	if has_landed == true:
		$Sprite.play("Landed")		
		
	if !dashing and motion.y > 10:
		$Sprite.play("Fall")
		
	if speed_modifier == 1 and Input.is_action_just_pressed("ui_dash"):
		dash()
		
	motion = move_and_slide(motion, UP)
	pass
	
func move():
	pass
	
func jump():	
	pass
	
func dash():
	speed_modifier = 4
	dashing = true
	$Timer.set_wait_time(0.25)
	$Timer.start()


func _on_Timer_timeout():
	has_landed = false
	speed_modifier = 1
	dashing = false
