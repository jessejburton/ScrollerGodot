extends Control

onready var Health = $HealthBar
onready var Hit = $HitBar
onready var UpdateTween = $UpdateTween

func _on_health_updated(health):
	Health.value = health
	$AnimationPlayer.play("Show")
	UpdateTween.interpolate_property(Hit, "value", Hit.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	UpdateTween.start()
	
func _on_max_health_updated(max_health):
	Health.max_value = max_health
	Hit.max_value = max_health
