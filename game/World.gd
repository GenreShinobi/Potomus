extends Spatial

var CELL = preload("res://cells/Cell.tscn")
var PORTAL = preload("res://portals/portal.tscn")

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
	var hall_portal = PORTAL.instance()
	if not PORTAL is PackedScene: return
	portals.add_child(hall_portal)
	hall_portal.global_transform.origin = Vector3(4, 0, 100)
	hall_portal.set_rotation(Vector3(0,PI/2,0))
	
	if not Map is PackedScene: return
	var map = Map.instance()
	var tileMap = map.get_tilemap()
	var used_tiles = tileMap.get_used_cells()
	map.free() 
	for tile in used_tiles:
		var cell = CELL.instance()
		maze.add_child(cell)
		cell.translation = Vector3(tile.x * Globals.GRID_SIZE, 0, tile.y * Globals.GRID_SIZE)
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
		cell.translation = Vector3(hall_cells.size() * Globals.GRID_SIZE, 0, 100)
		cell.xCord = tile.x * Globals.GRID_SIZE
		cell.yCord = tile.y * Globals.GRID_SIZE
	for cell in hall_cells:
		cell.update_faces_again(hall_cells)
		
		
func move_cell_to_hall(cell):
	var room_parent = cell.get_parent()
	room_parent.remove_child(cell)
	maze_cells.erase(cell)
	hall.add_child(cell)
	hall_cells.append(cell)
	cell.set_original_location(cell.get_current_location())
	cell.set_current_location(Vector3(hall_cells.size() * Globals.GRID_SIZE, 0, 100))


func move_cell_to_maze(cell):
	var room_parent = cell.get_parent()
	room_parent.remove_child(cell)
	hall_cells.erase(cell)
	maze.add_child(cell)
	maze_cells.append()
	cell.set_current_location(cell.get_original_position())

func add_new_cell_to_hall(cell):
	maze_cells.erase(cell)
	var new_cell = CELL.instance()
	hall_cells.append(new_cell)
	hall.add_child(new_cell)
	new_cell.set_original_location(cell.get_current_location())
	new_cell.set_current_location(Vector3(hall_cells.size() * Globals.GRID_SIZE, 0, 100))
	
