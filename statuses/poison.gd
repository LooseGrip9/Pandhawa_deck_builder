class_name PoisonStatus
extends Status

func get_tooltip() -> String:
	return tooltip % stacks

func apply_status(target: Node) -> void:
	if not target:
		return
		
	if target.has_method("take_damage"):
		target.take_damage(stacks, Modifier.Type.NO_MODIFIER)
		
	stacks -= 1
	
	status_changed.emit()
