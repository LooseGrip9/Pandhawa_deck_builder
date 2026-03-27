extends Relic

@export var gold_bonus := 0.10

func initialize_relic(owner: RelicUI) -> void:
	print("DEBUG: Gold Relic initialized!")
	
	var run = _get_run_node(owner)
	
	if run and run.stats:
		print("DEBUG: Old Gold Multiplier: ", run.stats.gold_multiplier)
		
		run.stats.gold_multiplier += gold_bonus
		
		print("DEBUG: New Gold Multiplier: ", run.stats.gold_multiplier)
		owner.flash()
	else:
		print("DEBUG: CRITICAL - Cannot find the Run node or stats!")

func _get_run_node(node: Node) -> Node:
	var current = node
	while current != null:
		if current is Run: 
			return current
		current = current.get_parent()
	return null
