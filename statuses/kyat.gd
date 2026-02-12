class_name KyatStatus
extends Status


func initialize_status(_target: Node) -> void:
	status_changed.connect(_on_status_changed.bind(_target))
	_on_status_changed(_target)

func get_tooltip() -> String:
	return tooltip % stacks

func _on_status_changed(target: Node) -> void:
	assert(target.get("modifier_handler"), "No Modifier on %s" % target)
	
	var dmg_delt_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_delt_modifier, "No dmg dealt modifier on %s" % target)
	
	var kyat_modifier_value := dmg_delt_modifier.get_value("kyat")
	
	if not kyat_modifier_value:
		kyat_modifier_value = ModifierValue.create_new_modifier("kyat", ModifierValue.Type.FLAT)
	
	kyat_modifier_value.flat_value = stacks
	dmg_delt_modifier.add_new_value(kyat_modifier_value)
	print("Kyat updated: ", stacks, " on ", target.name)
