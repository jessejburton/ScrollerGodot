extends KinematicBody2D

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
var health = 3

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
	var action = get_input()
	velocity = move_and_slide(velocity, Vector2.UP)		

func walk_left():
	state_machine.travel("Run")
	$Sprite.flip_h = true
	$Sprite.offset.x = -26
	velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
	
func walk_right():
	state_machine.travel("Run")	
	$Sprite.flip_h = false
	$Sprite.offset.x = 0
	velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
	
func idle():
	state_machine.travel("Idle")	
	velocity.x = 0
	
func _on_HurtBox_area_entered(area):
	is_hit = true
	health -= 1
	if health < 0:
		state_machine.travel("Death")
	else:
		state_machine.travel("Damage")
		$HitTimer.start()
	# Handled by appropriate layer / masks
	#queue_free()

func _on_MoveTimer_timeout():
	has_state = false
	state = rng.randi_range(0,2)

func _on_HitTimer_timeout():
	has_state = false
	is_hit = false
