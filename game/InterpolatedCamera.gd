extends InterpolatedCamera

func _physics_process(delta):
	velocity += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	#rotation_degrees = Vector3(0,lerp(rotation_degrees.y, target_rotation.y, look_sensitivity * delta),0)
	
func _input(event):
	if event is InputEventKey:
		if event.pressed and !event.is_echo() and event.scancode == KEY_A:
			target_rotation = target_rotation + Vector3(0,90,0)
