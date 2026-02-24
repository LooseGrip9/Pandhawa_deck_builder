class_name SlowStatus
extends StatusTemplates 

var _target: Node

func initialize_status(target: Node) -> void:
	_target = target
	print("Slow initialized on %s" % _target.name)
	
	status_changed.connect(_on_status_changed.bind(_target))
	_on_status_changed(_target)
	
	if not Events.enemy_turn_ended.is_connected(_on_enemy_turn_ended):
		Events.enemy_turn_ended.connect(_on_enemy_turn_ended)

func apply_status(target: Node) -> void:
	status_applied.emit(self)
	status_changed.emit()

func get_tooltip() -> String:
	return tooltip % stacks

func _on_status_changed(target: Node) -> void:
	if not target.get("modifier_handler"):
		return
		
	var action_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.ACTION_COUNT)
	
	if action_modifier:
		var slow_value := action_modifier.get_value("slow")
		
		if not slow_value:
			slow_value = ModifierValue.create_new_modifier("slow", ModifierValue.Type.FLAT)
		
		slow_value.flat_value = -stacks
		action_modifier.add_new_value(slow_value)
		print("Slow applied! Action count modifier is now: ", slow_value.flat_value)

func _on_enemy_turn_ended() -> void:
	if stacks > 0 and is_instance_valid(_target) and _target.is_in_group("enemies"):
		stacks -= 1
		print("Slow reduced to: ", stacks)
		status_changed.emit()
