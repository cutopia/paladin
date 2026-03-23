# Monster.gd - Basic monster AI and behavior

extends CharacterBody2D

@export var speed: float = 50.0
var health: int = 30
var attack_power: int = 5
var attack_cooldown: float = 1.5
var attack_timer: float = 0.0

func _ready():
	print("Monster spawned!")

func _physics_process(delta):
	# Move towards paladin
	var paladin = get_tree().get_nodes_in_group("paladin")
	if not paladin.is_empty():
		var direction = (paladin[0].position - position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	print("Monster took %d damage! HP: %d" % [amount, health])
	
	if health <= 0:
		die()

func die() -> void:
	print("Monster defeated!")
	
	# Give XP to paladin
	var paladin = get_tree().get_nodes_in_group("paladin")
	if not paladin.is_empty():
		paladin[0].gain_xp(25)
	
	queue_free()
