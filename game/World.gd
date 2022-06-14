extends Spatial

var CELL = preload("res://cells/cell.tscn")
var PORTAL = preload("res://portals/portal-hall.tscn")

onready var maze = $Maze
onready var hall = $Hall
onready var portals = $Portals

export (PackedScene) var Map
export (PackedScene) var Hall

var maze_cells = []
var hall_cells = []

func _ready():
	# Apply Textures
	generate_map()
	pass

func generate_map():
	if not Map is PackedScene: return
	var map = Map.instance()
	var tileMap = map.get_tilemap()
	var used_tiles = tileMap.get_used_cells()
	map.free() 
	for tile in used_tiles:
		var cell = CELL.instance()
		maze.add_child(cell)
		cell.translation = Vector3(tile.x * (Globals.GRID_SIZE), 0, tile.y * Globals.GRID_SIZE)
		cell.xCord = tile.x * Globals.GRID_SIZE
		cell.yCord = tile.y * Globals.GRID_SIZE
		maze_cells.append(cell)
	for cell in maze_cells:
		cell.update_faces_again(maze_cells)
	
	if not Hall is PackedScene: return
	var hall_map = Hall.instance()
	var hall_tileMap = hall_map.get_tilemap()
	var hall_used_tiles = hall_tileMap.get_used_cells()
	hall_map.free() 
	for tile in hall_used_tiles:
		var cell = CELL.instance()
		hall.add_child(cell)
		hall_cells.append(cell)
		cell.translation = Vector3(0, 0, 100)
		cell.xCord = tile.x * Globals.GRID_SIZE
		cell.yCord = tile.y * Globals.GRID_SIZE		
		cell.southFace.hide()
		cell.westFace.hide()
		cell.northFace.show()
		cell.southFace.show()
	for cell in hall_cells:
		cell.update_faces_again(hall_cells)

func add_new_cell_to_hall(cell):
	if !is_instance_valid(cell): return
	var maze_player = get_tree().get_nodes_in_group("maze_player")[0]
	var hall_player = get_tree().get_nodes_in_group("hall_player")[0]
	maze_cells.erase(cell)
	var new_cell = CELL.instance()	
	hall_cells.append(new_cell)
	hall.add_child(new_cell)
	
	new_cell.last_pass = cell.last_pass
	new_cell.walls_on = cell.walls_on
	new_cell.set_map_on(Globals.MapType.HALL)
	new_cell.set_return_rotation_by_cell(cell.get_return_rotation())
#   print("Last pass was: " + String(Globals.cardinals.keys()[new_cell.last_pass]))			
	for cell in hall_cells.size():
		hall_cells[cell].global_transform.origin += Vector3(Globals.GRID_SIZE,0,0)
		
	new_cell.eastFace.set_visible(cell.eastFace.is_visible())
	new_cell.westFace.set_visible(cell.westFace.is_visible())
	new_cell.northFace.set_visible(cell.northFace.is_visible())
	new_cell.southFace.set_visible(cell.southFace.is_visible())
	match cell.last_pass:
		Globals.cardinals.NORTH:
			new_cell.set_rotation(Vector3(0,0,0))
		Globals.cardinals.SOUTH:
			match new_cell.get_room_shape():
				Globals.RoomShape.I:
					new_cell.set_rotation(Vector3(0,PI/2,0))
				_:
					new_cell.set_rotation(Vector3(0,0,0))
		Globals.cardinals.EAST:
			new_cell.set_rotation(Vector3(0,PI,0))
		Globals.cardinals.WEST:
			new_cell.set_rotation(Vector3(0,0,0))
#	print("RoomShape: " + Globals.RoomShape.keys()[new_cell.get_room_shape()])
	new_cell.set_return_location(cell.get_current_location())
	new_cell.set_current_location(Vector3(0, 0, 100))
	new_cell.set_connected_cell(cell)
	hall_player.set_previous_cell(new_cell)
	print("Added "+ Globals.MapType.keys()[new_cell.is_on_map] + "." + String(new_cell.get_instance_id()) +" and connected to "+ Globals.MapType.keys()[cell.is_on_map] + "." + String(new_cell.get_connected_cell().get_instance_id())+"\n")
	
func remove_cell_from_hall():
	var dying_cell = hall_cells[hall_cells.size() - 1]
	if dying_cell.get_map_on() != Globals.MapType.HALL: return
	print("Removed " + Globals.MapType.keys()[dying_cell.is_on_map] + "." + String(dying_cell.get_instance_id()))
	
	# get the Maze Player and Maze Portal to prepare to move them
	var hall_player = get_tree().get_nodes_in_group("hall_player")[0]
	var maze_player = get_tree().get_nodes_in_group("maze_player")[0]
	var maze_portal = get_tree().get_nodes_in_group("maze_portal")[0]
	
	# Set the Maze Player to the proper location and rotation for this cell
#	maze_player.global_transform.origin = cell.get_return_location()
#	maze_player.set_rotation(cell.get_return_rotation())
	# Set the Maze Portal to the proper location and rotation for this cell
	maze_portal.global_transform.origin = dying_cell.get_return_location()
	maze_portal.set_rotation(dying_cell.get_return_rotation() + Vector3(0, PI/2, 0))
	
	# Remove the Cell fromt he Hall
	hall_cells.erase(dying_cell)
	dying_cell.queue_free()
		
	# Move the Hall Cells and Hall Player back 1 step
	for cell in hall_cells.size():
		hall_cells[cell].global_transform.origin -= Vector3(Globals.GRID_SIZE,0,0)
	hall_player.global_transform.origin -= Vector3(Globals.GRID_SIZE,0,0)
