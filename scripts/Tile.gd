# Tile.gd - Represents a single floor tile in the dungeon
# Each side (N/E/S/W) can be either a Wall or Doorway

const Side = preload("res://scripts/Side.gd")
enum State { WALL, DOORWAY }

var sides: Dictionary = {}

func _init():
	# Initialize all sides to random state
	sides[Side.SIDE_TOP] = randi() % 2
	sides[Side.SIDE_RIGHT] = randi() % 2
	sides[Side.SIDE_BOTTOM] = randi() % 2
	sides[Side.SIDE_LEFT] = randi() % 2

func get_state(side: int) -> int:
	return sides.get(side, State.WALL)

func set_state(side: int, state: int) -> void:
	sides[side] = state

# Rotate all sides clockwise: N->E->S->W->N
func rotate_clockwise() -> void:
	var north = sides[Side.SIDE_TOP]
	var east = sides[Side.SIDE_RIGHT]
	var south = sides[Side.SIDE_BOTTOM]
	var west = sides[Side.SIDE_LEFT]
	
	sides[Side.SIDE_TOP] = west
	sides[Side.SIDE_RIGHT] = north
	sides[Side.SIDE_BOTTOM] = east
	sides[Side.SIDE_LEFT] = south

# Rotate all sides counter-clockwise: N->W->S->E->N
func rotate_counter_clockwise() -> void:
	var north = sides[Side.SIDE_TOP]
	var east = sides[Side.SIDE_RIGHT]
	var south = sides[Side.SIDE_BOTTOM]
	var west = sides[Side.SIDE_LEFT]
	
	sides[Side.SIDE_TOP] = east
	sides[Side.SIDE_RIGHT] = south
	sides[Side.SIDE_BOTTOM] = west
	sides[Side.SIDE_LEFT] = north

func _to_string() -> String:
	return "Tile(N:%s E:%s S:%s W:%s)" % [
		get_state_name(sides[Side.SIDE_TOP]),
		get_state_name(sides[Side.SIDE_RIGHT]),
		get_state_name(sides[Side.SIDE_BOTTOM]),
		get_state_name(sides[Side.SIDE_LEFT])
	]

func get_state_name(state: int) -> String:
	return "Wall" if state == State.WALL else "Door"
