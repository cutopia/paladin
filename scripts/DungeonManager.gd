# DungeonManager.gd - Manages dungeon generation and game flow

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
	floor_texture = preload("res://dungeon_floor.png")
	# Connect to draw signal for wall rendering
	connect("draw", Callable(self, "_draw_walls"))

func start_game() -> void:
	print("Starting game at level %d" % current_level)
	generate_dungeon()
	spawn_paladin()
	spawn_monsters()
	spawn_stairs()

func generate_dungeon() -> void:
	tiles.clear()
	tile_visuals.clear()
	
	for y in range(grid_height):
		var row = []
		var visual_row = []
		for x in range(grid_width):
			var tile = Tile.new()
			row.append(tile)
			visual_row.append(null)
		tiles.append(row)
		tile_visuals.append(visual_row)
	
	print("Generated dungeon grid: %dx%d" % [grid_width, grid_height])
	
	# Create visual representation for all tiles
	for y in range(grid_height):
		for x in range(grid_width):
			create_tile_visual(x, y, tiles[y][x])

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

func _draw_walls() -> void:
	# Draw all walls using CanvasItem draw methods
	for y in range(grid_height):
		for x in range(grid_width):
			var tile = tiles[y][x]
			var wc = tile_visuals[y][x].get_meta("wall_layer")
			if not wc:
				continue
			
			var wall_color = Color(0.6, 0.5, 0.4, 1)  # Brownish for walls
			var doorway_color = Color(0.3, 0.7, 0.9, 1)  # Blue-ish for doorways
			var line_width = 8
			
			# Draw each side based on its state
			for side in [Side.SIDE_TOP, Side.SIDE_RIGHT, Side.SIDE_BOTTOM, Side.SIDE_LEFT]:
				var state = tile.get_state(side)
				var color = wall_color if state == Tile.State.WALL else doorway_color
				
				match side:
					Side.SIDE_TOP:
						draw_line(wc.position + Vector2(0, 0), wc.position + Vector2(tile_size, 0), color, line_width)
					Side.SIDE_RIGHT:
						draw_line(wc.position + Vector2(tile_size, 0), wc.position + Vector2(tile_size, tile_size), color, line_width)
					Side.SIDE_BOTTOM:
						draw_line(wc.position + Vector2(tile_size, tile_size), wc.position + Vector2(0, tile_size), color, line_width)
					Side.SIDE_LEFT:
						draw_line(wc.position + Vector2(0, tile_size), wc.position + Vector2(0, 0), color, line_width)

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
