extends Node2D

export(Resource) var night_material
export(float, 0, 1) var amount_night = 0 setget set_amount_night

var throttle_amount = 5
var throttle_value = 0
var current_night_amount = 0.0
var night = false

func _ready():
	night = false
	current_night_amount = 0
	set_amount_night(current_night_amount)

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
