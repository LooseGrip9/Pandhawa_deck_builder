class_name RentanStatus
extends Status

const REDUCTION := -0.25 

func get_tooltip() -> String:
	return tooltip % duration

func initialize_status(_target: Node) -> void:
	assert(_target.get("modifier_handler"), "no modifier on %s" % _target)
	
	var dmg_dealt_modifier: Modifier = _target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_dealt_modifier, "no dmg dealt modifier on %s" % _target)
	
	var fear_modifier_value := dmg_dealt_modifier.get_value("ketakutan_debuff")
	
	if not fear_modifier_value:
		fear_modifier_value = ModifierValue.create_new_modifier("ketakutan_debuff", ModifierValue.Type.PERCENT_BASED)
		fear_modifier_value.percent_value = REDUCTION
		dmg_dealt_modifier.add_new_value(fear_modifier_value)
	
	if not status_changed.is_connected(_on_status_changed):
		status_changed.connect(_on_status_changed.bind(dmg_dealt_modifier))

func _on_status_changed(dmg_dealt_modifier: Modifier) -> void:
	var mod_value = dmg_dealt_modifier.get_value("ketakutan_debuff")
	
	# CHANGED: Check duration instead of stacks
	if duration <= 0:
		if mod_value:
			dmg_dealt_modifier.remove_value("ketakutan_debuff")
		return
