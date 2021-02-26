extends Area2D

var velocity = Vector2.ZERO
var follow_target
var limit_x_left = 0
var limit_x_right = 0
var limit_y_top = 0
var limit_y_bottom = 0
var is_bound = false

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if follow_target:
		position += position.direction_to(follow_target.position)
		
	if is_bound:
		check_limits()	
			
func check_limits():
	if position.y < limit_y_top:
		position.y = limit_y_top		
	if position.y > limit_y_bottom:
		position.y = limit_y_bottom

	if position.x < limit_x_left:
		position.x = limit_x_left		
	if position.x > limit_x_right:
		position.x = limit_x_right
	
func start_at(pos):
	position = pos
	
func move_towards(target):
	follow_target = target
	
func set_limit_y(limitTop, limitBottom):
	is_bound = true
	limit_y_top = limitTop
	limit_y_bottom = limitBottom

func set_limit_x(limitLeft, limitRight):
	is_bound = true
	limit_x_left = limitLeft
	limit_x_right = limitRight
