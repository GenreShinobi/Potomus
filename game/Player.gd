extends KinematicBody

var gravity = Vector3.DOWN * 12
var speed 	= 4
var velocity = Vector3()

func _physics_process(delta):
	velocity += gravity * delta
	getInput()
	velocity = move_and_slide(velocity, Vector3.UP)
	
func getInput():
	velocity.x = 0
	velocity.z = 0
	
	if Input.is_action_pressed("move_forward"):
		velocity.z -= speed

# Testing Export Workflow
