extends Area
class_name Cell

onready var northSide := $NorthSide
onready var southSide := $SouthSide
onready var eastSide := $EastSide
onready var westSide := $WestSide
onready var topFace: = $TopFace
onready var northFace: = $NorthSide/NorthFace
onready var eastFace: = $EastSide/EastFace
onready var southFace: = $SouthSide/SouthFace
onready var westFace: = $WestSide/WestFace
onready var bottomFace: = $BottomFace
onready var north: = $RayNorth
onready var south: = $RaySouth
onready var east: = $RayEast
onready var west: = $RayWest
onready var compass: = $RayCompass

export (bool) var north_is_on :bool  = true
export (bool) var south_is_on :bool  = true
export (bool) var east_is_on :bool  = true
export (bool) var west_is_on :bool  = true

var xCord :int = 0
var yCord :int = 0
var return_location :Vector3
var return_rotation :Vector3
var is_on_map :int = Globals.MapType.MAZE
var last_pass
var walls_on :int = 0
var connected_cell

func _ready() -> void:
	$Debug/Viewport/NodeID.text = String(get_instance_id())
	walls_on = 0
	if north_is_on:
		northFace.show()
	else:
		northFace.hide()
		walls_on += 1
		
	if east_is_on:
		eastFace.show()
	else:
		eastFace.hide()
		walls_on += 1
		
	if west_is_on:
		westFace.show()
	else:
		westFace.hide()
		walls_on += 1
		
	if south_is_on:
		southFace.show()
	else:
		southFace.hide()
		walls_on += 1
		

func update_faces(cell_list) -> void:
	var my_grid_position = Vector2(translation.x/Globals.GRID_SIZE, translation.z/2)
	walls_on = 0

	if cell_list.has(my_grid_position + Vector2.RIGHT):
		eastFace.hide()
		walls_on += 1
	else: 
		eastFace.show()
	
	if cell_list.has(my_grid_position + Vector2.LEFT):
		westFace.hide()
		walls_on += 1
	else: 
		westFace.show()
	
	if cell_list.has(my_grid_position + Vector2.DOWN):
		southFace.hide()
		walls_on += 1
	else: 
		southFace.show()
	
	if cell_list.has(my_grid_position + Vector2.UP):
		northFace.hide()
		walls_on += 1
	else: 
		northFace.show()

func update_faces_again(cell_list) -> void:
	walls_on = 0
	for cell in cell_list:
		if cell.north.is_colliding():
			cell.northFace.hide()
			walls_on += 1
		else: cell.northFace.show()
		
		if cell.west.is_colliding():
			cell.westFace.hide()
			walls_on += 1
		else: 
			cell.westFace.show()	
		
		if cell.south.is_colliding():
			cell.southFace.hide()
			walls_on += 1
		else: 
			cell.southFace.show()
		
		if cell.east.is_colliding():
			cell.eastFace.hide()
			walls_on += 1
		else: 
			cell.eastFace.show()

func set_return_location(location) -> void:
	return_location = location

func get_return_location():
	return return_location

func set_current_location(new_location) -> void:
	global_transform.origin = new_location

func get_current_location():
	return global_transform.origin

func set_map_on(map :int) -> void:
	is_on_map = map 

func get_map_on() -> int:
	return is_on_map

func _on_passed_through(side):
	last_pass = side

func get_room_shape():
	if ((eastFace.visible and westFace.visible) and (!northFace.visible and !southFace.visible)) or ((!eastFace.visible and !westFace.visible) and (northFace.visible and southFace.visible)):
		return Globals.RoomShape.I
	return Globals.RoomShape.UNKNOWN

func set_return_rotation_by_player(player):
	return_rotation = player.get_rotation() + Vector3(0, PI, 0)

func set_return_rotation_by_cell(rotation):
	return_rotation = rotation

func get_return_rotation() -> Vector3:
	return return_rotation

	
func get_connected_cell():
	return connected_cell

func set_connected_cell(cell):
	connected_cell = cell
