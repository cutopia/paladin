# Paladin.gd - Controls the paladin's movement, combat, and progression

extends CharacterBody2D

@export var speed: float = 100.0

var health: int = 100
var max_health: int = 100
var level: int = 1
var xp: int = 0
var xp_to_next_level: int = 100
var attack_power: int = 10
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

func _ready():
	print("Paladin spawned!")

func _physics_process(delta):
	# Move towards nearest monster or stairs
	var target = find_nearest_target()
	
	if target:
		var direction = (target.position - position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func find_nearest_target() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance = INF
	
	# Check monsters
	for monster in get_tree().get_nodes_in_group("monsters"):
		var distance = position.distance_to(monster.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = monster
	
	# If no monsters nearby, check for stairs (exit)
	# For now, just return the nearest found
	return nearest

func attack(target: Node2D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(attack_power)
		print("Paladin attacked for %d damage!" % attack_power)

func take_damage(amount: int) -> void:
	health -= amount
	print("Paladin took %d damage! HP: %d/%d" % [amount, health, max_health])
	
	if health <= 0:
		game_over()

func gain_xp(amount: int) -> void:
	xp += amount
	print("Paladin gained %d XP!" % amount)
	
	if xp >= xp_to_next_level:
		level_up()

func level_up() -> void:
	level += 1
	xp -= xp_to_next_level
	xp_to_next_level = int(xp_to_next_level * 1.5)
	max_health += 20
	health = max_health
	attack_power += 5
	
	print("Paladin leveled up to level %d!" % level)

func game_over() -> void:
	print("Game Over! Paladin died at level %d" % level)
	get_tree().reload_current_scene()
