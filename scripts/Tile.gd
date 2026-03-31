# Tile.gd - Represents a single floor tile in the dungeon
# Each side (N/E/S/W) can be either a Wall or Doorway

const Side = preload("res://scripts/Side.gd")
enum State { WALL, DOORWAY }

var sides: Dictionary = {}

func _init():
	# Initialize with guaranteed mix of walls and doorways
	# Use position-based seed for variety while ensuring each tile has both walls and doorways
	var x = get_instance_id() & 0xFFFF
	var y = (get_instance_id() >> 16) & 0xFFFF
	var seed = hash("%d,%d" % [x, y])
	
	# Ensure positive value and range 1-14 (patterns that have at least one wall and one doorway)
	# Pattern 0 (0000) = all doorways, Pattern 15 (1111) = all walls - we exclude these
	var abs_seed = seed if seed >= 0 else -seed
	var pattern = (abs_seed % 14) + 1  # Range: 1 to 14
	
	sides[Side.SIDE_TOP] = (pattern & 8) >> 3
	sides[Side.SIDE_RIGHT] = (pattern & 4) >> 2
	sides[Side.SIDE_BOTTOM] = (pattern & 2) >> 1
	sides[Side.SIDE_LEFT] = pattern & 1

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
	
	print("  North(%s) -> East" % get_state_name(north))
	print("  East(%s) -> South" % get_state_name(east))
	print("  South(%s) -> West" % get_state_name(south))
	print("  West(%s) -> North" % get_state_name(west))
	
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
	
	print("  North(%s) -> West" % get_state_name(north))
	print("  East(%s) -> North" % get_state_name(east))
	print("  South(%s) -> East" % get_state_name(south))
	print("  West(%s) -> South" % get_state_name(west))
	
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
