# Game.gd - Main game controller

extends Node2D

@onready var dungeon_manager = $DungeonManager
@onready var ui = $UI

func _ready():
	print("Game started!")
	$DungeonManager.start_game()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
