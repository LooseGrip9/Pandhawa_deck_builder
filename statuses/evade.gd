class_name EvadeStatus
extends Status

func get_modified_value(base_value: int, modifier_type: int) -> int:
	if modifier_type != Modifier.Type.DMG_TAKEN:
		return base_value
		
	if base_value <= 0:
		return base_value
		
	stacks -= 1
	return 0
