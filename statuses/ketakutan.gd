class_name KetakutanStatus
extends Status

# We don't need a constant -3 here because the 'Stacks' variable 
# determines the amount (-1 per stack).
# If Stacks = 3, Damage is -3.

func get_tooltip() -> String:
	# Shows "Deals 3 less damage" if you have 3 stacks
	return "Deals %s less damage." % stacks

func initialize_status(_target: Node) -> void:
	assert(_target.get("modifier_handler"), "no modifier on %s" % _target)
	
	var dmg_dealt_modifier: Modifier = _target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_dealt_modifier, "no dmg dealt modifier on %s" % _target)
	
	var strength_modifier_value := dmg_dealt_modifier.get_value("ketakutan_debuff")
	
	if not strength_modifier_value:
		strength_modifier_value = ModifierValue.create_new_modifier("ketakutan_debuff", ModifierValue.Type.FLAT)
		# Initialize value based on current stacks immediately
		strength_modifier_value.flat_value = -stacks
		dmg_dealt_modifier.add_new_value(strength_modifier_value)
	
	if not status_changed.is_connected(_on_status_changed):
		status_changed.connect(_on_status_changed.bind(dmg_dealt_modifier))

func _on_status_changed(dmg_dealt_modifier: Modifier) -> void:
	var mod_value = dmg_dealt_modifier.get_value("ketakutan_debuff")
	
	# If stacks reach 0, remove the effect completely
	if stacks <= 0:
		if mod_value:
			dmg_dealt_modifier.remove_value("ketakutan_debuff")
		return

	# Otherwise, update the value to match the new stack count
	if mod_value:
		mod_value.flat_value = -stacks
