# DungeonMap.gd - Manages the dungeon grid and tile generation

extends Node2D

@export var grid_width: int = 20
@export var grid_height: int = 20
@export var tile_size: int = 64

var tiles: Array[Array] = []
var floor_tile_scene: PackedScene = preload("res://scenes/floor_tile.tscn")

func _ready():
	generate_dungeon()
	
	# Visualize the dungeon
	for y in range(grid_height):
		for x in range(grid_width):
			var tile = tiles[y][x]
			spawn_tile_visual(x, y, tile)

func generate_dungeon() -> void:
	tiles.clear()
	
	for y in range(grid_height):
		var row: Array[Tile] = []
		for x in range(grid_width):
			var tile = Tile.new()
			row.append(tile)
		tiles.append(row)
	
	print("Generated dungeon grid: %dx%d" % [grid_width, grid_height])
	print("Total tiles: %d" % (grid_width * grid_height))

func spawn_tile_visual(x: int, y: int, tile: Tile) -> void:
	var floor_sprite = floor_tile_scene.instantiate()
	floor_sprite.position = Vector2(x * tile_size + tile_size/2, y * tile_size + tile_size/2)
	add_child(floor_sprite)
	
	# Store reference for later updates
	floor_sprite.set_meta("grid_x", x)
	floor_sprite.set_meta("grid_y", y)

func get_tile(x: int, y: int) -> Tile:
	if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
		return null
	return tiles[y][x]

# Rotate tile at position clockwise
func rotate_tile_clockwise(x: int, y: int) -> bool:
	var tile = get_tile(x, y)
	if not tile:
		return false
	
	tile.rotate_clockwise()
	
	# Update adjacent tiles to match shared walls
	update_adjacent_walls(x, y, tile)
	
	print("Rotated tile at (%d,%d): %s" % [x, y, tile])
	return true

# Rotate tile at position counter-clockwise
func rotate_tile_counter_clockwise(x: int, y: int) -> bool:
	var tile = get_tile(x, y)
	if not tile:
		return false
	
	tile.rotate_counter_clockwise()
	
	# Update adjacent tiles to match shared walls
	update_adjacent_walls(x, y, tile)
	
	print("Rotated counter-clockwise tile at (%d,%d): %s" % [x, y, tile])
	return true

func update_adjacent_walls(x: int, y: int, tile: Tile) -> void:
	# Update north neighbor (if exists)
	if y > 0:
		var north_tile = tiles[y-1][x]
		north_tile.set_state(Side.SOUTH, tile.get_state(Side.NORTH))
	
	# Update east neighbor (if exists)
	if x < grid_width - 1:
		var east_tile = tiles[y][x+1]
		east_tile.set_state(Side.WEST, tile.get_state(Side.EAST))
	
	# Update south neighbor (if exists)
	if y < grid_height - 1:
		var south_tile = tiles[y+1][x]
		south_tile.set_state(Side.NORTH, tile.get_state(Side.SOUTH))
	
	# Update west neighbor (if exists)
	if x > 0:
		var west_tile = tiles[y][x-1]
		west_tile.set_state(Side.EAST, tile.get_state(Side.WEST))

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var grid_x = int(mouse_pos.x / tile_size)
		var grid_y = int(mouse_pos.y / tile_size)
		
		if event.shift_key:
			rotate_tile_counter_clockwise(grid_x, grid_y)
		else:
			rotate_tile_clockwise(grid_x, grid_y)
