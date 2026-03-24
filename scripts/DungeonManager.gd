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

func _ready():
	pass

func start_game() -> void:
	print("Starting game at level %d" % current_level)
	generate_dungeon()
	spawn_paladin()
	spawn_monsters()
	spawn_stairs()

func generate_dungeon() -> void:
	tiles.clear()
	
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			var tile = Tile.new()
			row.append(tile)
		tiles.append(row)
	
	print("Generated dungeon grid: %dx%d" % [grid_width, grid_height])

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
		tile.rotate_clockwise()
	else:
		tile.rotate_counter_clockwise()
	
	# Update adjacent tiles to match shared walls
	update_adjacent_walls(x, y, tile)
	
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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not event.shift:
		var mouse_pos = get_global_mouse_position()
		var grid_x = int(mouse_pos.x / tile_size)
		var grid_y = int(mouse_pos.y / tile_size)
		rotate_tile(grid_x, grid_y, true)
	
	# Handle shift+left click to rotate counter-clockwise
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.shift:
		var mouse_pos = get_global_mouse_position()
		var grid_x = int(mouse_pos.x / tile_size)
		var grid_y = int(mouse_pos.y / tile_size)
		rotate_tile(grid_x, grid_y, false)
