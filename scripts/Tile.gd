# Tile.gd - Represents a single floor tile in the dungeon
# Each side (N/E/S/W) can be either a Wall or Doorway

enum Side { NORTH, EAST, SOUTH, WEST }
enum State { WALL, DOORWAY }

class_name Tile

var sides: Dictionary = {}

func _init():
	# Initialize all sides to random state
	sides[Side.NORTH] = randi() % 2
	sides[Side.EAST] = randi() % 2
	sides[Side.SOUTH] = randi() % 2
	sides[Side.WEST] = randi() % 2

func get_state(side: int) -> int:
	return sides.get(side, State.WALL)

func set_state(side: int, state: int) -> void:
	sides[side] = state

# Rotate all sides clockwise: N->E->S->W->N
func rotate_clockwise() -> void:
	var north = sides[Side.NORTH]
	var east = sides[Side.EAST]
	var south = sides[Side.SOUTH]
	var west = sides[Side.WEST]
	
	sides[Side.NORTH] = west
	sides[Side.EAST] = north
	sides[Side.SOUTH] = east
	sides[Side.WEST] = south

# Rotate all sides counter-clockwise: N->W->S->E->N
func rotate_counter_clockwise() -> void:
	var north = sides[Side.NORTH]
	var east = sides[Side.EAST]
	var south = sides[Side.SOUTH]
	var west = sides[Side.WEST]
	
	sides[Side.NORTH] = east
	sides[Side.EAST] = south
	sides[Side.SOUTH] = west
	sides[Side.WEST] = north

func _to_string() -> String:
	return "Tile(N:%s E:%s S:%s W:%s)" % [
		get_state_name(sides[Side.NORTH]),
		get_state_name(sides[Side.EAST]),
		get_state_name(sides[Side.SOUTH]),
		get_state_name(sides[Side.WEST])
	]

func get_state_name(state: int) -> String:
	return "Wall" if state == State.WALL else "Door"
