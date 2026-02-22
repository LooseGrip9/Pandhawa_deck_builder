class_name TangkasStatus
extends Status

func initialize_status(_target: Node) -> void:
	status_changed.connect(_on_status_changed.bind(_target))
	_on_status_changed(_target)

func get_tooltip() -> String:
	return tooltip % stacks

func _on_status_changed(target: Node) -> void:
	assert(target.get("modifier_handler"), "No Modifier on %s" % target)
	
	var block_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.BLOCK_GAINED)
	assert(block_modifier, "No block gained modifier on %s" % target)
	
	var tangkas_modifier_value := block_modifier.get_value("tangkas")
	
	if not tangkas_modifier_value:
		tangkas_modifier_value = ModifierValue.create_new_modifier("tangkas", ModifierValue.Type.FLAT)
	
	tangkas_modifier_value.flat_value = stacks
	block_modifier.add_new_value(tangkas_modifier_value)
