tool
extends ParallaxBackground

var start_color = [212, 240, 246]
var end_color = [154, 182, 154]
var throttle_amount = 5
var throttle_value = 0

export var moon_height = 300

func _ready():
	change_background_color(start_color)
	$Moon/Moon.position.y = 350
	
func _physics_process(delta):
	if throttle_value >= throttle_amount:
		if not is_same_color(start_color, end_color):
			start_color = get_next_color(start_color, end_color)
			change_background_color(start_color)
		throttle_value = 0
	else:
		throttle_value += 1
	if $Moon/Moon.position.y > 145:
		$Moon/Moon.position.y -= 0.05
		
func change_background_color(rgb):
	var color = rgb_to_color(rgb[0],rgb[1],rgb[2])
	$Sky/Sky.modulate = Color(color)
	
func get_next_color(color1, color2):
	if is_same_color(color1, color2):
		return color2
		
	var new_color = [0,0,0]

	for index in range(0, 3): 
		if color1[index] == color2[index]:
			new_color[index] = color2[index]
		else:
			var direction = 1
			if color1[index] > color2[index]:
				direction = -1
				
			new_color[index] = color1[index] + direction

	return new_color
			
func is_same_color(color1, color2):
	if (color1[0] == color2[0]) and (color1[1] == color2[1]) and (color1[2] == color2[2]):
		return true
	return false
	
func rgb_to_color(r,g,b):
	return Color(to_floating_point(r),to_floating_point(g),to_floating_point(b))
	
func to_floating_point(value, of = 255):
	return stepify(value * 1.00 / of, 0.01)

func get_difference(number1, number2):
	return abs(abs(number2)-abs(number1))
