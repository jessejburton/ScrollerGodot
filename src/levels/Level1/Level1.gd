extends Node2D

onready var camera = get_node("Player/Player/Camera2D")

export(Resource) var night_material
export(float, 0, 1) var amount_night = 0 setget set_amount_night

var throttle_amount = 5
var throttle_value = 0
var current_night_amount = 0.0
var night = false

var is_mute = false
var music1 = AudioStreamPlayer2D.new()
var music2 = AudioStreamPlayer2D.new()

func _ready():
	$Enemies/WalkingDroid/WalkingDroid.set_physics_process(true)
	night = false
	current_night_amount = 0
	set_amount_night(current_night_amount)
	#SoundController.play_music("res://assets/music/sands_of_mystery.ogg")
	SoundController.play_ambiance("Wind")

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
	
func _on_TowerInside_body_entered(body):		
	night = true
	$Animations/AnimationPlayer.play("InsideBuilding")
	$Player/Player.zoom_camera_to(Vector2(0.9,0.9))
	SoundController.play_music("res://assets/music/inside_tower.ogg")

func _on_TowerInside_body_exited(body):
	$Animations/AnimationPlayer.play("OutsideBuilding")	
	$Player/Player.zoom_camera_to(Vector2(1,1))
	
func _on_BossBattle_body_entered(body):
	$Player/Player.zoom_full_extents = Vector2(1.5,1.5)
	$Enemies/Boss/Mecha.is_active = true
	SoundController.play_music("res://assets/music/epic.ogg")

func _on_Mecha_on_BossBattle_complete():
	SoundController.play_music("res://assets/music/mario_theme.ogg")	
