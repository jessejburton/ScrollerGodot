extends Node2D

export(Resource) var night_material
export(float, 0, 1) var amount_night = 0 setget set_amount_night

var throttle_amount = 5
var throttle_value = 0
var current_night_amount = 0.0
var night = false

var music1 = AudioStreamPlayer2D.new()
var music2 = AudioStreamPlayer2D.new()

func _ready():
	night = false
	current_night_amount = 0
	set_amount_night(current_night_amount)
	play_music("res://assets/music/sands_of_mystery.ogg")

func _process(delta):
	if throttle_value >= throttle_amount:
		if night and current_night_amount < 1:
			set_amount_night(current_night_amount)
			current_night_amount += 0.01
			throttle_value = 0
	else:
		throttle_value += 1

func set_amount_night(amount):
	set_night_level(clamp(amount, 0, 1))

func set_night_level(amount):
	night_material.set_shader_param("mix_amount", amount)

func play_music(track):
	var fade_to = $Sound/Music/Music
	var fade_from = $Sound/Music/Music2
	
	if $Sound/Music/Music.playing:
		fade_to = $Sound/Music/Music2
		fade_from = $Sound/Music/Music
		
	fade_to.stream = load(track)
	
	fade_from.stop()
	fade_to.play()

func _on_TowerInside_body_entered(body):
	night = true
	$Player/Player.zoom_camera_to(Vector2(0.8,0.8))
	play_music("res://assets/music/boss.ogg")

func _on_TowerInside_body_exited(body):
	$Player/Player.zoom_camera_to(Vector2(1,1))
	
func _on_BossBattle_body_entered(body):
	$Cameras/Boss.current = true
	
	play_music("res://assets/music/epic.ogg")
