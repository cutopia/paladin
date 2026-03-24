# DungeonMap.gd - Manages the dungeon grid and tile generation

extends Node2D

const Side = preload("res://scripts/Side.gd")
const Tile = preload("res://scripts/Tile.gd")
const State = Tile.State

@export var grid_width: int = 20
@export var grid_height: int = 20
@export var tile_size: int = 64

var tiles: Array[Array] = []

# Floor texture - replace with your actual texture path if different
const FLOOR_TEXTURE = preload("res://dungeon_floor.png")

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
		var row = []
		for x in range(grid_width):
			var tile = Tile.new()
			row.append(tile)
		tiles.append(row)
	
	print("Generated dungeon grid: %dx%d" % [grid_width, grid_height])
	print("Total tiles: %d" % (grid_width * grid_height))

func spawn_tile_visual(x: int, y: int, tile: Tile) -> void:
	var floor_sprite = Sprite2D.new()
	floor_sprite.texture = FLOOR_TEXTURE
	floor_sprite.position = Vector2(x * tile_size + tile_size/2, y * tile_size + tile_size/2)
	add_child(floor_sprite)
	
	# Create wall visualization using a CanvasLayer for lines
	var wall_layer = CanvasLayer.new()
	wall_layer.name = "WallVisuals_%d_%d" % [x, y]
	wall_layer.position = Vector2(x * tile_size, y * tile_size)
	floor_sprite.add_child(wall_layer)
	
	# Create visual representation of walls using Line2D
	create_wall_visuals(wall_layer, tile)
	
	# Store reference for later updates
	floor_sprite.set_meta("grid_x", x)
	floor_sprite.set_meta("grid_y", y)
	floor_sprite.set_meta("wall_layer", wall_layer)

func create_wall_visuals(wall_layer: CanvasLayer, tile: Tile) -> void:
	var wall_color = Color(0.6, 0.5, 0.4, 1)  # Brownish for walls
	var doorway_color = Color(0.3, 0.7, 0.9, 1)  # Blue-ish for doorways
	var line_width = 4
	
	# Create Line2D nodes for each side
	for side in [Side.SIDE_TOP, Side.SIDE_RIGHT, Side.SIDE_BOTTOM, Side.SIDE_LEFT]:
		var lin = Line2D.new()
		lin.width = line_width
		
		match side:
			Side.SIDE_TOP:
				lin.add_point(Vector2(0, 0))
				lin.add_point(Vector2(tile_size, 0))
			Side.SIDE_RIGHT:
				lin.add_point(Vector2(tile_size, 0))
				lin.add_point(Vector2(tile_size, tile_size))
			Side.SIDE_BOTTOM:
				lin.add_point(Vector2(tile_size, tile_size))
				lin.add_point(Vector2(0, tile_size))
			Side.SIDE_LEFT:
				lin.add_point(Vector2(0, tile_size))
				lin.add_point(Vector2(0, 0))
		
		wall_layer.add_child(lin)
		lin.set_meta("side", side)
	
	update_wall_visuals(wall_layer, tile)

func update_wall_visuals(wall_layer: CanvasLayer, tile: Tile) -> void:
	var wall_color = Color(0.6, 0.5, 0.4, 1)  # Brownish for walls
	var doorway_color = Color(0.3, 0.7, 0.9, 1)  # Blue-ish for doorways
	
	for child in wall_layer.get_children():
		if child is Line2D and child.has_meta("side"):
			var side = child.get_meta("side")
			var state = tile.get_state(side)
			
			print("Wall at side %d: state=%d" % [side, state])
			
			# Set color based on state
			child.set_default_color(wall_color if state == State.WALL else doorway_color)
			
			# Make doorways semi-transparent to show they're open
			if state == State.DOORWAY:
				child.modulate.a = 0.6
			else:
				child.modulate.a = 1.0

func get_tile(x: int, y: int) -> Tile:
	if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
		return null
	return tiles[y][x]

# Rotate tile at position clockwise
func rotate_tile_clockwise(x: int, y: int) -> bool:
	var tile = get_tile(x, y)
	if not tile:
		return false
	
	# Log before state
	print("=== TILE ROTATION (Clockwise) ===")
	print("Tile position: (%d, %d)" % [x, y])
	print("Before rotation: %s" % tile)
	
	tile.rotate_clockwise()
	
	# Log after state
	print("After rotation:  %s" % tile)
	
	# Update adjacent tiles to match shared walls
	update_adjacent_walls(x, y, tile)
	
	# Update visual representation
	update_tile_visuals(x, y)
	
	print("=================================")
	return true

# Rotate tile at position counter-clockwise
func rotate_tile_counter_clockwise(x: int, y: int) -> bool:
	var tile = get_tile(x, y)
	if not tile:
		return false
	
	# Log before state
	print("=== TILE ROTATION (Counter-Clockwise) ===")
	print("Tile position: (%d, %d)" % [x, y])
	print("Before rotation: %s" % tile)
	
	tile.rotate_counter_clockwise()
	
	# Log after state
	print("After rotation:  %s" % tile)
	
	# Update adjacent tiles to match shared walls
	update_adjacent_walls(x, y, tile)
	
	# Update visual representation
	update_tile_visuals(x, y)
	
	print("=========================================")
	return true

func update_tile_visuals(x: int, y: int) -> void:
	var tile = get_tile(x, y)
	if not tile:
		return
	
	# Find the wall layer for this tile
	for child in get_children():
		if child is Sprite2D:
			var sprite_x = child.get_meta("grid_x", -1)
			var sprite_y = child.get_meta("grid_y", -1)
			if sprite_x == x and sprite_y == y:
				var wall_layer = child.get_meta("wall_layer")
				if wall_layer:
					update_wall_visuals(wall_layer, tile)
				break

func update_adjacent_walls(x: int, y: int, tile: Tile) -> void:
	# Update north neighbor (if exists)
	if y > 0:
		var north_tile = tiles[y-1][x]
		north_tile.set_state(Side.SIDE_BOTTOM, tile.get_state(Side.SIDE_TOP))
	
	# Update east neighbor (if exists)
	if x < grid_width - 1:
		var east_tile = tiles[y][x+1]
		east_tile.set_state(Side.SIDE_LEFT, tile.get_state(Side.SIDE_RIGHT))
	
	# Update south neighbor (if exists)
	if y < grid_height - 1:
		var south_tile = tiles[y+1][x]
		south_tile.set_state(Side.SIDE_TOP, tile.get_state(Side.SIDE_BOTTOM))
	
	# Update west neighbor (if exists)
	if x > 0:
		var west_tile = tiles[y][x-1]
		west_tile.set_state(Side.SIDE_RIGHT, tile.get_state(Side.SIDE_LEFT))

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var grid_x = int(mouse_pos.x / tile_size)
		var grid_y = int(mouse_pos.y / tile_size)
		
		if event.shift_key:
			rotate_tile_counter_clockwise(grid_x, grid_y)
		else:
			rotate_tile_clockwise(grid_x, grid_y)
