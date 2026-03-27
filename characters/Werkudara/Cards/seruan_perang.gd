extends Card

@export var status_to_apply: Status
@export var amount: int = 3

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:

	var all_enemies = modifiers.get_tree().get_nodes_in_group("enemies")
	
	for enemy in all_enemies:
		if enemy and is_instance_valid(enemy):
			var status_instance = status_to_apply.duplicate()
			status_instance.stacks = amount
			
			enemy.status_handler.add_status(status_instance)
			
			print("Applied -%s damage to %s" % [amount, enemy.name])
