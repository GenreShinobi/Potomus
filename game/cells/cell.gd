extends Area
class_name Cell

onready var topFace: = $TopFace
onready var northFace: = $NorthFace
onready var eastFace: = $EastFace
onready var southFace: = $SouthFace
onready var westFace: = $WestFace
onready var bottomFace: = $BottomFace
onready var north: = $RayNorth
onready var south: = $RaySouth
onready var east: = $RayEast
onready var west: = $RayWest

export (bool) var north_is_on :bool  = true
export (bool) var south_is_on :bool  = true
export (bool) var east_is_on :bool  = true
export (bool) var west_is_on :bool  = true

var xCord :int = 0
var yCord :int = 0
var original_loation :Vector3

func _ready() -> void:
	if north_is_on:
		northFace.show()
	else:
		northFace.hide()
		
	if east_is_on:
		eastFace.show()
	else:
		eastFace.hide()
		
	if west_is_on:
		westFace.show()
	else:
		westFace.hide()
		
	if south_is_on:
		southFace.show()
	else:
		southFace.hide()
		

func update_faces(cell_list) -> void:
	var my_grid_position = Vector2(translation.x/Globals.GRID_SIZE, translation.z/2)

	if cell_list.has(my_grid_position + Vector2.RIGHT):
		eastFace.hide()
	else: eastFace.show()
	
	if cell_list.has(my_grid_position + Vector2.LEFT):
		westFace.hide()
	else: westFace.show()
	
	if cell_list.has(my_grid_position + Vector2.DOWN):
		southFace.hide()
	else: southFace.show()
	
	if cell_list.has(my_grid_position + Vector2.UP):
		northFace.hide()
	else: northFace.show()

func update_faces_again(cell_list) -> void:
	
	for cell in cell_list:
		if cell.north.is_colliding():
			cell.northFace.hide()
		else: cell.northFace.show()
		
		if cell.west.is_colliding():
			cell.westFace.hide()
		else: cell.westFace.show()	
		
		if cell.south.is_colliding():
			cell.southFace.hide()
		else: cell.southFace.show()
		
		if cell.east.is_colliding():
			cell.eastFace.hide()
		else: cell.eastFace.show()

func set_original_location(location) -> void:
	original_loation = location

func get_original_location():
	return original_loation

func set_current_location(new_location) -> void:
	global_transform.origin = new_location

func get_current_location():
	return global_transform.origin
