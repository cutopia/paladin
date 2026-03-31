# DungeonManager.gd - Manages dungeon generation using recursive maze algorithm

extends Node2D

const Side = preload("res://scripts/Side.gd")
const Tile = preload("res://scripts/Tile.gd")

@export var grid_width: int = 20
@export var grid_height: int = 20
@export var tile_size: int = 64

var tiles: Array[Array] = []
var paladin: Node2D
var monsters: Array[Node2D] = []
var current_level: int = 1
var floor_texture: Texture2D

# Visual nodes storage
var tile_visuals: Array[Array] = []

func _ready():
	floor_texture = preload("res://assets/sprites/tile_sprites.png")
	set_process_input(true)
	queue_redraw()

func start_game() -> void:
	print("Starting game at level %d" % current_level)
	generate_dungeon()
	spawn_paladin()
	spawn_monsters()
	spawn_stairs()

func generate_dungeon() -> void:
	tiles.clear()
	tile_visuals.clear()
	
	# Initialize all tiles with walls on all sides
	for y in range(grid_height):
		var row = []
		var visual_row = []
		for x in range(grid_width):
			var tile = Tile.new()
			# Set all sides to WALL initially
			tile.set_state(Side.SIDE_TOP, Tile.State.WALL)
			tile.set_state(Side.SIDE_RIGHT, Tile.State.WALL)
			tile.set_state(Side.SIDE_BOTTOM, Tile.State.WALL)
			tile.set_state(Side.SIDE_LEFT, Tile.State.WALL)
			row.append(tile)
			visual_row.append(null)
		tiles.append(row)
		tile_visuals.append(visual_row)
	
	# Generate maze using recursive backtracking starting from (1,1)
	var start_x = 1
	var start_y = 1
	generate_maze(start_x, start_y)
	
	print("Generated dungeon grid: %dx%d" % [grid_width, grid_height])
	
	# Create visual representation for all tiles
	for y in range(grid_height):
		for x in range(grid_width):
			create_tile_visual(x, y, tiles[y][x])
	
	queue_redraw()

func generate_maze(x: int, y: int) -> void:
	# Mark current cell as visited
	tiles[y][x].visited = true
	
	# Get unvisited neighbors (cells that are 2 steps away with walls between)
	var neighbors = get_unvisited_neighbors(x, y)
	
	while neighbors.size() > 0:
		# Pick a random neighbor
		var rand_index = randi() % neighbors.size()
		var neighbor = neighbors[rand_index]
		
		# Remove the wall between current cell and chosen neighbor
		remove_wall(x, y, neighbor.x, neighbor.y)
		
		# Recursively visit the neighbor
		generate_maze(neighbor.x, neighbor.y)
		
		# Re-check for new unvisited neighbors
		neighbors = get_unvisited_neighbors(x, y)

func get_unvisited_neighbors(x: int, y: int) -> Array:
	var neighbors = []
	
	# Check all four directions (N, E, S, W)
	# Only check cells that are 2 steps away (for maze generation with walls between)
	var directions = [
		{"x": x, "y": y - 2, "wall_x": x, "wall_y": y - 1},   # North
		{"x": x + 2, "y": y, "wall_x": x + 1, "wall_y": y},   # East
		{"x": x, "y": y + 2, "wall_x": x, "wall_y": y + 1},   # South
		{"x": x - 2, "y": y, "wall_x": x - 1, "wall_y": y}    # West
	]
	
	for dir in directions:
		if is_valid_cell(dir.x, dir.y) and not tiles[dir.y][dir.x].visited:
			neighbors.append({"x": dir.x, "y": dir.y})
	
	return neighbors

func is_valid_cell(x: int, y: int) -> bool:
	return x >= 0 and x < grid_width and y >= 0 and y < grid_height

func remove_wall(x1: int, y1: int, x2: int, y2: int) -> void:
	# Determine which wall to remove between two adjacent cells
	if x1 == x2:
		if y2 < y1:
			# North neighbor: remove south wall of (x2,y2) and north wall of (x1,y1)
			tiles[y2][x2].set_state(Side.SIDE_BOTTOM, Tile.State.DOORWAY)
			tiles[y1][x1].set_state(Side.SIDE_TOP, Tile.State.DOORWAY)
		else:
			# South neighbor: remove north wall of (x2,y2) and south wall of (x1,y1)
			tiles[y2][x2].set_state(Side.SIDE_TOP, Tile.State.DOORWAY)
			tiles[y1][x1].set_state(Side.SIDE_BOTTOM, Tile.State.DOORWAY)
	elif y1 == y2:
		if x2 < x1:
			# West neighbor: remove east wall of (x2,y2) and west wall of (x1,y1)
			tiles[y2][x2].set_state(Side.SIDE_RIGHT, Tile.State.DOORWAY)
			tiles[y1][x1].set_state(Side.SIDE_LEFT, Tile.State.DOORWAY)
		else:
			# East neighbor: remove west wall of (x2,y2) and east wall of (x1,y1)
			tiles[y2][x2].set_state(Side.SIDE_LEFT, Tile.State.DOORWAY)
			tiles[y1][x1].set_state(Side.SIDE_RIGHT, Tile.State.DOORWAY)

func create_tile_visual(x: int, y: int, tile: Tile) -> void:
	# Store the tile position for later use in drawing
	var tile_data = {
		"x": x,
		"y": y,
		"tile": tile
	}
	tile_visuals[y][x] = tile_data
	
	print("Created visual for tile at (%d,%d)" % [x, y])

func _draw() -> void:
	# Draw floor tiles and walls using CanvasItem drawing methods
	
	# First draw floor background for all tiles
	for y in range(grid_height):
		for x in range(grid_width):
			var tile_pos = Vector2(x * tile_size, y * tile_size)
			
			# Draw floor background - use a simple color to avoid texture issues
			var floor_color = Color(0.15, 0.15, 0.2, 1)  # Very dark blue-gray
			draw_rect(Rect2(tile_pos, Vector2(tile_size, tile_size)), floor_color)
	
	# Then draw walls as lines/rectangles on top
	var wall_color = Color(0.8, 0.7, 0.6, 1)  # Lighter brownish for walls
	var line_width = 8
	
	for y in range(grid_height):
		for x in range(grid_width):
			var tile = tiles[y][x]
			
			# Calculate position relative to this CanvasItem
			var tile_pos = Vector2(x * tile_size, y * tile_size)
			
			# Draw each side as a filled rectangle
			for side in [Side.SIDE_TOP, Side.SIDE_RIGHT, Side.SIDE_BOTTOM, Side.SIDE_LEFT]:
				var state = tile.get_state(side)
				if state == Tile.State.WALL:
					match side:
						Side.SIDE_TOP:
							# Draw top edge rectangle
							draw_rect(Rect2(tile_pos.x, tile_pos.y, tile_size, line_width), wall_color)
						Side.SIDE_RIGHT:
							# Draw right edge rectangle
							draw_rect(Rect2(tile_pos.x + tile_size - line_width, tile_pos.y, line_width, tile_size), wall_color)
						Side.SIDE_BOTTOM:
							# Draw bottom edge rectangle
							draw_rect(Rect2(tile_pos.x, tile_pos.y + tile_size - line_width, tile_size, line_width), wall_color)
						Side.SIDE_LEFT:
							# Draw left edge rectangle
							draw_rect(Rect2(tile_pos.x, tile_pos.y, line_width, tile_size), wall_color)



func spawn_paladin() -> void:
	# Spawn paladin at center of dungeon
	var start_x = grid_width / 2
	var start_y = grid_height / 2
	
	paladin = preload("res://scenes/Paladin.tscn").instantiate()
	paladin.position = Vector2(start_x * tile_size + tile_size/2, start_y * tile_size + tile_size/2)
	add_child(paladin)
	
	print("Paladin spawned at (%d,%d)" % [start_x, start_y])

func spawn_monsters() -> void:
	# Spawn random monsters in the dungeon (not on paladin starting position)
	var monster_count = 5 + current_level * 2
	
	for i in range(monster_count):
		var valid_position = false
		var x: int
		var y: int
		
		while not valid_position:
			x = randi() % grid_width
			y = randi() % grid_height
			
			# Don't spawn on paladin starting position
			if x != grid_width / 2 and y != grid_height / 2:
				valid_position = true
		
		var monster = preload("res://scenes/Monster.tscn").instantiate()
		monster.position = Vector2(x * tile_size + tile_size/2, y * tile_size + tile_size/2)
		monster.set_meta("grid_x", x)
		monster.set_meta("grid_y", y)
		add_child(monster)
		monsters.append(monster)
	
	print("Spawned %d monsters" % monster_count)

func spawn_stairs() -> void:
	# Spawn stairs in a reachable location (not on paladin starting position)
	var valid_position = false
	var x: int
	var y: int
	
	while not valid_position:
		x = randi() % grid_width
		y = randi() % grid_height
		
		if x != grid_width / 2 and y != grid_height / 2:
			valid_position = true
	
	print("Stairs placed at (%d,%d)" % [x, y])

func rotate_tile(x: int, y: int, clockwise: bool = true) -> bool:
	if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
		return false
	
	var tile = tiles[y][x]
	
	if clockwise:
		print("=== TILE ROTATION (Clockwise) ===")
		print("Tile position: (%d, %d)" % [x, y])
		print("Before rotation: %s" % tile)
		
		tile.rotate_clockwise()
		
		print("After rotation:  %s" % tile)
		print("=================================")
	else:
		print("=== TILE ROTATION (Counter-Clockwise) ===")
		print("Tile position: (%d, %d)" % [x, y])
		print("Before rotation: %s" % tile)
		
		tile.rotate_counter_clockwise()
		
		print("After rotation:  %s" % tile)
		print("=========================================")
	
	# Update adjacent tiles to match shared walls
	update_adjacent_walls(x, y, tile)
	
	# Trigger redraw for visual updates
	queue_redraw()
	
	print("Rotated tile at (%d,%d) %s" % [x, y, "clockwise" if clockwise else "counter-clockwise"])
	return true

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
	# Handle left click to rotate clockwise
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not event.shift_pressed:
		var mouse_pos = get_global_mouse_position()
		var grid_x = int(mouse_pos.x / tile_size)
		var grid_y = int(mouse_pos.y / tile_size)
		rotate_tile(grid_x, grid_y, true)
	
	# Handle shift+left click to rotate counter-clockwise
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.shift_pressed:
		var mouse_pos = get_global_mouse_position()
		var grid_x = int(mouse_pos.x / tile_size)
		var grid_y = int(mouse_pos.y / tile_size)
		rotate_tile(grid_x, grid_y, false)

func get_state_name_at_index(tile: Tile, index: int) -> String:
	return tile.get_state_name(index)
