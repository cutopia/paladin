# Game.gd - Main game controller

extends Node2D

@onready var dungeon_manager = $DungeonManager
@onready var ui = $UI

func _ready():
	print("Game started!")
	$DungeonManager.start_game()
	
	# Create a simple background color
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.15, 0.2, 1)
	add_child(bg)
	
	# Create a label to show something is working
	var label = Label.new()
	label.name = "Title"
	label.set_anchor_left(0.5)
	label.set_anchor_top(0.1)
	label.set_anchor_right(0.5)
	label.set_anchor_bottom(0.1)
	label.position = Vector2(0, -20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	label.add_theme_font_size_override("font_size", 32)
	label.text = "Paladin's Path"
	add_child(label)

func _draw() -> void:
	# Draw a simple grid to visualize the dungeon
	var tile_size = 64
	var grid_width = 20
	var grid_height = 20
	
	for y in range(grid_height):
		for x in range(grid_width):
			var rect = Rect2(x * tile_size, y * tile_size, tile_size, tile_size)
			
			# Alternating colors to make grid visible
			if (x + y) % 2 == 0:
				draw_rect(rect, Color(0.2, 0.2, 0.3, 0.5), true)
			else:
				draw_rect(rect, Color(0.15, 0.15, 0.25, 0.5), true)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
