extends RayCast2D

var is_casting := false setget set_is_casting

func _ready() -> void:
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO
	
func point_towards(target):
	position = target	
	
func fire_laser(fire) -> void:
	self.is_casting = fire

func _physics_process(delta: float) -> void:
	var cast_point := cast_to
	force_raycast_update()
	
	$CollisionParticles.emitting = true
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		$CollisionParticles.global_rotation = get_collision_normal().angle()
		$CollisionParticles.position = cast_point
		
	$Line2D.points[1] = cast_point
	$HitZone.position = cast_point / 2
	$HitZone/CollisionShape2D.shape.extents.x = cast_point.x/2
	$BeamParticles.position = cast_point * 0.5
	$BeamParticles.process_material.emission_box_extents.x = cast_point.length() - 80

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	$BeamParticles.emitting = is_casting
	$CastingParticles.emitting = is_casting
	if is_casting:
		appear()
	else:
		$CollisionParticles.emitting = false
		disappear()
		
	set_physics_process(is_casting)

func appear() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 2.0, 0.2)
	$Tween.start()
	
func disappear() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 2.0, 0, 0.1)
	$Tween.start()	

func _on_HitZone_body_entered(body):
	if is_casting:
		body.damage()
