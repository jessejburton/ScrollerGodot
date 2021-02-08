extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

export var amplitude = 0
var priority = 0

onready var camera = get_parent()

func start(duration = 0.2, frequency = 5, amplitude = 5):
	if priority >= self.priority:
		self.priority
		self.amplitude = amplitude
		
		$Timers/Duration.wait_time = duration
		$Timers/Frequency.wait_time = 1 / float(frequency)
		$Timers/Duration.start()
		$Timers/Frequency.start()
		
		_new_shake()
	
func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)

	$Tween.interpolate_property(camera, "offset", camera.offset, rand, $Timers/Frequency.wait_time, TRANS, EASE)
	$Tween.start()
	
func _reset():
	$Tween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Timers/Frequency.wait_time, TRANS, EASE)
	$Tween.start()	
	
	priority = 0

func _on_FrequencyTimer_timeout():
	_new_shake()

func _on_Duration_timeout():
	_reset()
	$Timers/Duration.stop()
