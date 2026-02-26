extends Relic

@export var max_hp_bonus := 5

# --- CHANGED TO initialize_relic! ---
func initialize_relic(owner: RelicUI) -> void:
	print("DEBUG: Beras Prajurit initialized!")
	
	var run = _get_run_node(owner)
	
	if run and run.character:
		print("DEBUG: Found Run! Old Max HP: ", run.character.max_health)
		
		run.character.max_health += max_hp_bonus
		run.character.health += max_hp_bonus 
		run.character.stats_changed.emit()
		
		print("DEBUG: New Max HP: ", run.character.max_health)
		owner.flash()
	else:
		print("DEBUG: CRITICAL - Still cannot find the Run node!")

func _get_run_node(node: Node) -> Node:
	var current = node
	while current != null:
		if current is Run: 
			return current
		current = current.get_parent()
	return null
