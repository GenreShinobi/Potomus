extends Node


const GRID_SIZE = 2

var current_map :int = 0
var recently_jumped :bool = false
var portal_jumping :bool = false

enum MapType {
	MAZE,
	HALL
}

enum cardinals {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

enum RoomShape {
	UNKNOWN,
	T,
	END,
	I,
	L,
	OPEN
}
