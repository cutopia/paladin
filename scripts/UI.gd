# UI.gd - User interface controller

extends Control

func _ready():
	update_display()

func update_display(paladin = null):
	# Update display with paladin stats if available
	if paladin:
		pass  # Can add label updates when labels are added
	
	var game = get_node("/root/Game")
	if game and game.has_node("DungeonManager"):
		var dungeon_manager = game.get_node("DungeonManager")
		pass  # Can update dungeon level label when added
