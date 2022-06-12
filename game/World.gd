extends Spatial

const Cell = preload("res://cell/Cell.tscn")

onready var maze = $Maze

export (PackedScene) var Map


var cells = []

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
		var cell = Cell.instance()
		maze.add_child(cell)
		cell.translation = Vector3(tile.x * Globals.GRID_SIZE, 0, tile.y * Globals.GRID_SIZE)
		cell.xCord = tile.x * Globals.GRID_SIZE
		cell.yCord = tile.y * Globals.GRID_SIZE
		cells.append(cell)
	for cell in cells:
		cell.update_faces(used_tiles)
