# DungeonManager.gd - Manages dungeon generation and game flow

extends Node2D

@export var grid_width: int = 20
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

func generate_dungeon() -> void:
	tiles.clear()
	
	for y in range(grid_height):
		var row: Array[Tile] = []
		for x in range(grid_width):
			var tile = Tile.new()
			row.append(tile)
		tiles.append(row)
	
	print("Generated dungeon grid: %dx%d" % [grid_width, grid_height])

func spawn_paladin() -> void:
	var start_x = grid_width / 2
	var start_y = grid_height / 2
	
	paladin = preload("res://scenes/Paladin.tscn").instantiate()
	paladin.position = Vector2(start_x * tile_size + tile_size/2, start_y * tile_size + tile_size/2)
	add_child(paladin)

func spawn_monsters() -> void:
	var monster_count = 5 + current_level * 2
	
	for i in range(monster_count):
		var valid_position = false
		var x: int
		var y: int
		
		while not valid_position:
			x = randi() % grid_width
			y = randi() % grid_height
			
			if x != grid_width / 2 and y != grid_height / 2:
				valid_position = true
		
		var monster = preload("res://scenes/Monster.tscn").instantiate()
		monster.position = Vector2(x * tile_size + tile_size/2, y * tile_size + tile_size/2)
		monster.set_meta("grid_x", x)
		monster.set_meta("grid_y", y)
		add_child(monster)
		monsters.append(monster)

func rotate_tile(x: int, y: int, clockwise: bool = true) -> bool:
	if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
		return false
	
	var tile = tiles[y][x]
	
	if clockwise:
		tile.rotate_clockwise()
	else:
		tile.rotate_counter_clockwise()
	
	update_adjacent_walls(x, y, tile)
	return true

func update_adjacent_walls(x: int, y: int, tile: Tile) -> void:
	if y > 0:
		var north_tile = tiles[y-1][x]
		north_tile.set_state(Side.SOUTH, tile.get_state(Side.NORTH))
	
	if x < grid_width - 1:
		var east_tile = tiles[y][x+1]
		east_tile.set_state(Side.WEST, tile.get_state(Side.EAST))
	
	if y < grid_height - 1:
		var south_tile = tiles[y+1][x]
		south_tile.set_state(Side.NORTH, tile.get_state(Side.SOUTH))
	
	if x > 0:
		var west_tile = tiles[y][x-1]
		west_tile.set_state(Side.EAST, tile.get_state(Side.WEST))
