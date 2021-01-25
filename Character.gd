extends KinematicBody2D

# Constants
const GRAVITY = 10
const ACCELERATION = 10
const MAX_SPEED = 100
const JUMP_HEIGHT = -200
const FRICTION = 0.2

# Modifiers
var friction_modifier = 0

# Variables
var state_machine
var is_in_air = false
var velocity = Vector2.ZERO
var max_jumps = 2
var jumps_left = max_jumps
var is_attacking = false
var initiate_second_attack = false

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")

func get_input():
	var current_animation = state_machine.get_current_node()
	velocity.y += GRAVITY
	
	if current_animation == "Attack 2":
		initiate_second_attack = false	
	if current_animation == "Attack 1" or current_animation == "Attack 2":
		is_attacking = true
	else:
		is_attacking = false
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
		$Sprite.flip_h = false
		$Sprite.offset.x = 0
	elif Input.is_action_pressed("ui_left"):
		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = true
		$Sprite.offset.x = -60
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION + friction_modifier)	
	
	if velocity.x < 1 and velocity.x > -1: # lerp seems to not quite get to 0
		velocity.x = 0
		idle()
	if velocity.x != 0 and !is_attacking:
		run()	
		
	if is_attacking: velocity.x = lerp(velocity.x, 0, FRICTION + friction_modifier)			
	
	if Input.is_action_just_pressed("ui_attack"):
		if current_animation == "Attack 1":
			initiate_second_attack = true

		if initiate_second_attack:
			attack2()
		else:	
			attack()		
	
	if Input.is_action_just_pressed("ui_up") and jumps_left > 0 and !is_attacking:
		velocity.y = JUMP_HEIGHT
		friction_modifier = -0.2	
		jumps_left -= 1
	
	if is_on_floor():
		if is_in_air == true:
			friction_modifier = 0		
			land()
	else:
		if velocity.y < 0:
			jump()
		elif velocity.y > 0:
			fall()
	
func _physics_process(delta):
	var action = get_input()
	
	if is_attacking: 
		friction_modifier = 0.2
	else:
		friction_modifier = 0
	
	if action == "HAULT":
		velocity = move_and_slide(Vector2.ZERO, Vector2.UP)
	elif action == "WITH_SNAP":
		velocity = move_and_slide_with_snap(velocity, Vector2.UP)			
	else:
		velocity = move_and_slide(velocity, Vector2.UP)	

func jump():
	is_in_air = true
	state_machine.travel("Jump")
	
func fall():
	state_machine.travel("Falling")

func run():
	state_machine.travel("Run")
	
func idle():
	state_machine.travel("Idle")

func attack():
	state_machine.travel("Attack 1")
	
func attack2():
	state_machine.travel("Attack 2")

func land():
	jumps_left = max_jumps
	is_in_air = false
	state_machine.travel("Landing")


func _on_Area2D_area_entered(area):
	if area.is_in_group("hurtbox"):
		area.take_damage()
