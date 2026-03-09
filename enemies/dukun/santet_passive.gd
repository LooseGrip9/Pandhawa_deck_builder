class_name DukunSantetPassive
extends Node

var enemy: Enemy : set = _set_enemy
var target: Node2D # We need to know who to reflect the damage to!

func _ready() -> void:
	# A safe way to automatically find the player on the board
	target = get_tree().get_first_node_in_group("player")

func _set_enemy(value: Enemy) -> void:
	enemy = value
	if enemy and not enemy.damaged.is_connected(_on_enemy_damaged):
		enemy.damaged.connect(_on_enemy_damaged)

func _on_enemy_damaged(amount: int) -> void:
	# 1. Did the Dukun actually take unblocked damage?
	if amount <= 0:
		return

	# 2. Is the Santet status currently active?
	var santet_status = enemy.status_handler.get_status("santet")
	
	if santet_status and target:
		# 3. Reflect the EXACT damage back to the player!
		var damage_effect := DamageEffect.new()
		damage_effect.amount = amount
		damage_effect.execute([target])
		
		# A heavy screen shake on the player so they feel their mistake
		if Shaker:
			Shaker.shake(target, 8, 0.3)
			
		print("SANTET TRIGGERED! Reflected ", amount, " damage back to player.")
