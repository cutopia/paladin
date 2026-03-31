# DungeonManager.gd - Manages dungeon generation using recursive maze algorithm

extends CanvasItem  # Changed from Node2D to CanvasItem for proper drawing

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

# Track which cells have been visited during maze generation
var visited_cells: Array[Array] = []

func _ready():
	floor_texture = preload("res://assets/sprites/tile_sprites.png")
	# Now properly draws via CanvasItem's _draw() method instead of connect()

func start_game() -> void:
	print("Starting game at level %d" % current_level)
	generate_dungeon()
	spawn_paladin()
	spawn_monsters()
	spawn_stairs()

func generate_dungeon() -> void:
	tiles.clear()
	tile_visuals.clear()
	visited_cells.clear()
	
	# Initialize all tiles with walls on all sides
	for y in range(grid_height):
		var row = []
		var visual_row = []
		var visited_row = []
		for x in range(grid_width):
			var tile = Tile.new()
			# Set all sides to WALL initially
			tile.set_state(Side.SIDE_TOP, Tile.State.WALL)
			tile.set_state(Side.SIDE_RIGHT, Tile.State.WALL)
			tile.set_state(Side.SIDE_BOTTOM, Tile.State.WALL)
			tile.set_state(Side.SIDE_LEFT, Tile.State.WALL)
			row.append(tile)
			visual_row.append(null)
			visited_row.append(false)
		tiles.append(row)
		tile_visuals.append(visual_row)
		visited_cells.append(visited_row)
	
	# Generate maze using recursive backtracking starting from (1,1)
	var start_x = 1
	var start_y = 1
	generate_maze(start_x, start_y)
	
	print("Generated dungeon grid: %dx%d" % [grid_width, grid_height])
	
	# Create visual representation for all tiles
	for y in range(grid_height):
		for x in range(grid_width):
			create_tile_visual(x, y, tiles[y][x])

func generate_maze(x: int, y: int) -> void:
	# Mark current cell as visited
	visited_cells[y][x] = true
	
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
		if is_valid_cell(dir.x, dir.y) and not visited_cells[dir.y][dir.x]:
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
	var floor_sprite = Sprite2D.new()
	floor_sprite.texture = floor_texture
	floor_sprite.position = Vector2(x * tile_size + tile_size/2, y * tile_size + tile_size/2)
	add_child(floor_sprite)
	
	# Create wall visualization using a Control node for lines
	var wall_container = Control.new()
	wall_container.name = "WallVisuals_%d_%d" % [x, y]
	wall_container.size = Vector2(tile_size, tile_size)
	wall_container.position = Vector2(x * tile_size, y * tile_size)
	floor_sprite.add_child(wall_container)
	
	# Store reference for later updates
	floor_sprite.set_meta("grid_x", x)
	floor_sprite.set_meta("grid_y", y)
	floor_sprite.set_meta("wall_layer", wall_container)
	
	tile_visuals[y][x] = floor_sprite

func _draw() -> void:
	# Draw only walls as filled rectangles; doorways remain open
	for y in range(grid_height):
		for x in range(grid_width):
			var tile = tiles[y][x]
			var wc = tile_visuals[y][x].get_meta("wall_layer")
			if not wc:
				continue
			
			var wall_color = Color(0.6, 0.5, 0.4, 1)  # Brownish for walls
			var line_width = 8
			
			# Draw each side as a filled rectangle instead of lines
			for side in [Side.SIDE_TOP, Side.SIDE_RIGHT, Side.SIDE_BOTTOM, Side.SIDE_LEFT]:
				var state = tile.get_state(side)
				if state == Tile.State.WALL:
					match side:
						Side.SIDE_TOP:
							# Draw top edge rectangle
							draw_rect(Rect2(wc.position.x, wc.position.y, wc.size.x, line_width), wall_color)
						Side.SIDE_RIGHT:
							# Draw right edge rectangle
							draw_rect(Rect2(wc.position.x + wc.size.x - line_width, wc.position.y, line_width, wc.size.y), wall_color)
						Side.SIDE_BOTTOM:
							# Draw bottom edge rectangle
							draw_rect(Rect2(wc.position.x, wc.position.y + wc.size.y - line_width, wc.size.x, line_width), wall_color)
						Side.SIDE_LEFT:
							# Draw left edge rectangle
							draw_rect(Rect2(wc.position.x, wc.position.y, line_width, wc.size.y), wall_color)

func update_wall_visuals(wall_container: Control, tile: Tile) -> void:
	# Update the stored tile reference and redraw
	wall_container.set_meta("tile", tile)
	queue_redraw()
	
	var x = int(wall_container.position.x / tile_size)
	var y = int(wall_container.position.y / tile_size)
	print("Updated walls at (%d,%d)" % [x, y])

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
	
	# Update visual representation for this tile and neighbors
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < grid_width and ny >= 0 and ny < grid_height:
				var wc = tile_visuals[ny][nx].get_meta("wall_layer")
				if wc:
					update_wall_visuals(wc, tiles[ny][nx])
	
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
