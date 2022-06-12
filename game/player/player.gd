extends Spatial
class_name Player

var CELL = load("res://cells/cell.tscn")

onready var timerProcessor: = $Timer
onready var tween: = $Tween
onready var forward: = $RayForward
onready var back: = $RayBack
onready var right: = $RayRight
onready var left: = $RayLeft
onready var down: = $RayDown
var world

var current_cell
var previous_cell

func _ready() -> void:
	current_cell = down.get_collider()
	previous_cell = down.get_collider()
	world = get_tree().get_nodes_in_group("world")[0]

func _physics_process(_delta):
	if current_cell != null:
		current_cell.update_faces_again(world.maze_cells)
#		current_cell.update_faces_again(world.hall_cells)

func collision_check(direction):
	if direction != null:
		return direction.is_colliding()
	else:
		return false

func player_check():
	var chasing_cam = get_tree().get_nodes_in_group("chasing_portal")[0]
	var player = get_tree().get_nodes_in_group("player")[0]
	var hall = get_tree().get_nodes_in_group("hall")[0]
	var world = get_tree().get_nodes_in_group("world")[0]
	if down.get_collider() != current_cell:
		current_cell = down.get_collider()
		if chasing_cam != null and previous_cell != null:
			chasing_cam.global_transform.origin = player.global_transform.origin
			chasing_cam.set_rotation(player.get_rotation()+Vector3(0,PI,0))
		if current_cell != previous_cell:
			if previous_cell != null:
				print("Current: " + String(current_cell.get_instance_id()) + " Previous: " + String(previous_cell.get_instance_id()))
				world.add_new_cell_to_hall(previous_cell)
			previous_cell = current_cell
	
func get_direction(direction):
	if not direction is RayCast: return
	return direction.get_collider().global_transform.origin - global_transform.origin


func tween_translation(change):
	$AnimationPlayer.play("Step")
	tween.interpolate_property(
		self, "translation", translation, translation + change,
		0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	tween.start()
	yield(tween, "tween_completed")


func tween_rotation(change):
	tween.interpolate_property(
		self, "rotation", rotation, rotation + Vector3(0, change, 0),
		0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	tween.start()
	yield(tween, "tween_completed")


func _on_Timer_timeout() -> void:
	var GO_W	:= Input.is_action_pressed("move_forward")
	var TURN_A	:= Input.is_action_pressed("turn_left")
	var TURN_D	:= Input.is_action_pressed("turn_right")
	
	var ray_dir
	var turn_dir = int(TURN_A) - int(TURN_D)
	
	if GO_W:
		ray_dir = forward
		
	elif turn_dir:
		timerProcessor.stop()
		yield(tween_rotation(PI/2 * turn_dir), "completed")
		timerProcessor.start()
	
	if collision_check(ray_dir):
		timerProcessor.stop()
		yield(tween_translation(get_direction(ray_dir)), "completed")
		timerProcessor.start()
	
	if player_check():
		pass
