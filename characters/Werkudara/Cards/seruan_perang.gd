extends Card

@export var status_to_apply: Status
@export var amount: int = 3

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	# Ignore the passed '_targets' (which might be single from mouse hover)
	# and fetch ALL enemies in the current scene manually.
	var all_enemies = modifiers.get_tree().get_nodes_in_group("enemies")
	
	for enemy in all_enemies:
		if enemy and is_instance_valid(enemy):
			# 1. Create a unique instance of the status for this enemy
			var status_instance = status_to_apply.duplicate()
			status_instance.stacks = amount
			
			# 2. Add it to the enemy's StatusHandler
			# (Assumes your Enemy scene has a child named 'StatusHandler')
			enemy.status_handler.add_status(status_instance)
			
			# Optional: Visual flair so you know it hit
			print("Applied -%s damage to %s" % [amount, enemy.name])
