# UI.gd - User interface controller

extends Control

@onready var health_label = $HealthLabel
@onready var level_label = $LevelLabel
@onready var xp_label = $XPLabel
@onready var dungeon_level_label = $DungeonLevelLabel

func _ready():
	update_display()

func update_display(paladin = null):
	if paladin:
		health_label.text = "HP: %d/%d" % [paladin.health, paladin.max_health]
		level_label.text = "Lvl: %d" % paladin.level
		xp_label.text = "XP: %d/%d" % [paladin.xp, paladin.xp_to_next_level]
	
	var game = get_node("/root/Game")
	if game and game.has_node("DungeonManager"):
		var dungeon_manager = game.get_node("DungeonManager")
		dungeon_level_label.text = "Level: %d" % dungeon_manager.current_level
