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

var xCord :int = 0
var yCord :int = 0

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

func update_faces_again() -> void:
	
	if north.is_colliding():
		northFace.hide()
	else: northFace.show()
	
	if west.is_colliding():
		westFace.hide()
	else: westFace.show()	
	
	if south.is_colliding():
		southFace.hide()
	else: southFace.show()
	
	if east.is_colliding():
		eastFace.hide()
	else: eastFace.show()
	
