extends Spatial
class_name Player

var CELL = load("res://cells/cell.tscn")

onready var timerProcessor: = $Timer
onready var tween: = $Tween
onready var tween_viewport: = $TweenViewport
onready var forward: = $RayForward
onready var back: = $RayBack
onready var right: = $RayRight
onready var left: = $RayLeft
onready var down: = $RayDown
onready var cam_ray: = $Camera/RayCamera
onready var drop_point = $DropPoint
onready var debug_cur_loc = $Camera/Debug/Viewport/VBoxContainer/HBoxContainer/CurrentLoc
onready var debug_prev_loc = $Camera/Debug/Viewport/VBoxContainer/HBoxContainer2/PrevLoc
onready var debug_cur_map = $Camera/Debug/Viewport/VBoxContainer/HBoxContainer3/CurMap
onready var debug_portal_jumping = $Camera/Debug/Viewport/VBoxContainer/HBoxContainer4/PortalJumpingLabel
onready var debug_recently_jumped = $Camera/Debug/Viewport/VBoxContainer/HBoxContainer5/recentlyJumpedLabel

var world

var current_cell
var previous_cell
var last_maze_position
var other_player

func _ready() -> void:
	current_cell = down.get_collider()
	world = get_tree().get_nodes_in_group("world")[0]
	Globals.current_map = Globals.MapType.MAZE
	if other_player == null:
		for player in get_tree().get_nodes_in_group("player"):
			if player.name != name:
				other_player = player

func _process(delta):
	if current_cell != null and debug_cur_loc != null and is_instance_valid(current_cell):
		debug_cur_loc.text = Globals.MapType.keys()[current_cell.is_on_map] + "." + String(get_current_cell().get_instance_id())
	elif debug_cur_loc != null:
		debug_cur_loc.text = "null"

	if previous_cell != null and debug_prev_loc != null and is_instance_valid(previous_cell):
		debug_prev_loc.text = Globals.MapType.keys()[previous_cell.is_on_map] + "." + String(previous_cell.get_instance_id())
	elif debug_prev_loc != null:
		debug_prev_loc.text = "null"
	
	if Globals.current_map != null and debug_cur_map != null:
		debug_cur_map.text = Globals.MapType.keys()[Globals.current_map]
	elif debug_cur_map != null:
		debug_cur_map.text = "null"
		
	if debug_portal_jumping != null:
		debug_portal_jumping.text = String(Globals.portal_jumping)
		
	if debug_recently_jumped != null:
		debug_recently_jumped.text = String(Globals.recently_jumped)
		
func _physics_process(_delta):
	if current_cell != null and is_instance_valid(current_cell):
		current_cell.update_faces_again(world.maze_cells)
		
func collision_check(direction):
	if direction != null and is_in_group("active"):
		if direction.is_colliding():
			if cam_ray.is_colliding() and (cam_ray.get_collider().is_in_group("maze_portal") or cam_ray.get_collider().is_in_group("hall_portal")):
				Globals.portal_jumping = true
				if Globals.current_map == Globals.MapType.MAZE:
					last_maze_position = global_transform.origin
			return true
	else:
		return false

func player_check():
	var maze_portal = get_tree().get_nodes_in_group("maze_portal")[0]
	var hall_portal = get_tree().get_nodes_in_group("hall_portal")[0]
	var maze_player = get_tree().get_nodes_in_group("maze_player")[0]
	var hall_player = get_tree().get_nodes_in_group("hall_player")[0]
	var hall = get_tree().get_nodes_in_group("hall")[0]
	var world = get_tree().get_nodes_in_group("world")[0]
	if get_actual_cell() != current_cell:
		arrive_in_new_cell()
		if hall_portal != null and previous_cell != null and Globals.current_map == Globals.MapType.HALL and !Globals.portal_jumping:
			world.remove_cell_from_hall()
		if current_cell != previous_cell:
			if previous_cell != null:
				if Globals.current_map == Globals.MapType.MAZE and Globals.portal_jumping:
					move_from_maze_to_hall()
				elif Globals.current_map == Globals.MapType.HALL and Globals.portal_jumping:
					move_from_hall_to_maze()
				else:
					Globals.recently_jumped = false
			if previous_cell != null and previous_cell.get_map_on() == Globals.MapType.MAZE:
				previous_cell.set_return_rotation_by_player(maze_player)
		if Globals.current_map == Globals.MapType.MAZE and !Globals.portal_jumping and !Globals.recently_jumped:
			world.add_new_cell_to_hall(previous_cell)
		
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
		if is_in_group("active"):		
			yield(tween_rotation(PI/2 * turn_dir), "completed")
		timerProcessor.start()
	
	if collision_check(ray_dir):
		timerProcessor.stop()
		if is_in_group("active"):	
			prepare_to_leave_cell(get_current_cell())	
			yield(tween_translation(get_direction(ray_dir)), "completed")
		timerProcessor.start()
	
	if is_in_group("active") and player_check():
		pass

func set_camera():
	$Camera.current = true

func get_camera():
	return $Camera

func set_previous_cell(cell :Cell) -> void:
	previous_cell = cell

func get_previous_cell() -> Cell:
	return previous_cell

func set_current_cell(cell) -> void:
	current_cell = cell
	
func get_current_cell():
	return current_cell

func get_actual_cell() -> Cell:
	return down.get_collider()

func set_actual_cell(cell :Cell) -> void:
	global_transform.origin = cell.global_transform.origin

func prepare_to_leave_cell(cell :Cell):
	if cell != null:
		if Globals.current_map == Globals.MapType.MAZE:
			set_previous_cell(cell)
		else:
			set_previous_cell(cell.get_connected_cell())
		print("Leaving " + Globals.MapType.keys()[Globals.current_map] + "." + String(cell.get_instance_id()) + "\n")

func arrive_in_new_cell():
	set_current_cell(get_actual_cell())
	if is_instance_valid(get_current_cell()):
		print("Arrived @ " + "" + Globals.MapType.keys()[Globals.current_map] + "." + String(get_current_cell().get_instance_id()) + "\n")
		if Globals.current_map == Globals.MapType.MAZE:
			var maze_portal = get_tree().get_nodes_in_group("maze_portal")[0]
			var maze_player = get_tree().get_nodes_in_group("maze_player")[0]
			maze_portal.global_transform.origin = maze_player.global_transform.origin
			maze_portal.set_rotation(maze_player.get_rotation()+Vector3(0,PI,0))
			
func ported_to_cell(cell :Cell):
	if cell != null:
		print("Ported to " + "[" + Globals.MapType.keys()[Globals.current_map] + "] " + String(cell.get_instance_id()) + "\n")

func get_drop_point() -> Vector3:
	return drop_point.global_transform.origin

func get_drop_point_rotation() -> Vector3:
	return drop_point.get_rotation()

func move_from_maze_to_hall():
	print("Porting to HALL \n")
	var hall_portal = get_tree().get_nodes_in_group("hall_portal")[0]
	var maze_portal = get_tree().get_nodes_in_group("maze_portal")[0]
	var maze_player = get_tree().get_nodes_in_group("maze_player")[0]
	var hall_player = get_tree().get_nodes_in_group("hall_player")[0]
	Globals.portal_jumping = false
	Globals.recently_jumped = true
	Globals.current_map = Globals.MapType.HALL
	hall_player.global_transform.origin = Vector3(2,0,100)
	hall_player.set_rotation(hall_portal.get_rotation() + Vector3(0,PI,0))
	maze_player.remove_from_group("active")
	hall_player.add_to_group("active")
	hall_player.set_camera()
	maze_portal.global_transform.origin = maze_player.get_drop_point()
	maze_portal.set_rotation(maze_player.get_drop_point_rotation())
	world.add_new_cell_to_hall(previous_cell)

func move_from_hall_to_maze():
	print("Porting to MAZE \n")
	var hall_portal = get_tree().get_nodes_in_group("hall_portal")[0]
	var maze_portal = get_tree().get_nodes_in_group("maze_portal")[0]
	var maze_player = get_tree().get_nodes_in_group("maze_player")[0]
	var hall_player = get_tree().get_nodes_in_group("hall_player")[0]
	Globals.portal_jumping = false
	Globals.recently_jumped = true
	Globals.current_map = Globals.MapType.MAZE
	#chasing_cam.global_transform.origin = maze_player.global_transform.origin
	maze_player.global_transform.origin = hall_player.get_current_cell().get_connected_cell().global_transform.origin
	maze_player.set_rotation(maze_player.get_rotation() + Vector3(0, PI, 0))
	hall_player.remove_from_group("active")
	maze_player.add_to_group("active")
	maze_player.set_camera()
	world.remove_cell_from_hall()
