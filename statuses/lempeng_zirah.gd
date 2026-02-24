class_name PlatedArmorStatus
extends StatusTemplates

var _target: Node

func get_tooltip() -> String:
	return tooltip % stacks

func initialize_status(target: Node) -> void:
	_target = target
	print("Plated Armor initialized on %s" % _target.name)
	
	if _target.is_in_group("player"):
		if not Events.player_turn_ended.is_connected(_on_turn_ended):
			Events.player_turn_ended.connect(_on_turn_ended)
		
		if not Events.player_hit.is_connected(_on_took_damage):
			Events.player_hit.connect(_on_took_damage)

func apply_status(target: Node) -> void:
	status_applied.emit(self)
	status_changed.emit()

func _on_turn_ended() -> void:
	if stacks > 0 and is_instance_valid(_target):
		var block_effect := BlockEffect.new()
		block_effect.amount = stacks
		block_effect.execute([_target])
		print("Plated Armor triggered: Gained %d block." % stacks)

func _on_took_damage() -> void:
	if stacks > 0:
		stacks -= 1
		print("Plated Armor hit! Stacks reduced to: ", stacks)
		status_changed.emit() # Updates your UI to show the new number
