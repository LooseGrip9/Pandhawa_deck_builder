extends Card

var _last_execution_frame: int = -1
var base_damage = 25

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := _player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	
	if _enemy_modifiers:
		modified_dmg = _enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	
	return tooltip_text % modified_dmg

func is_playable(hand_node: Node) -> bool:
	if not hand_node:
		return false
		
	var count = 0
	for child in hand_node.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			count += 1
			
	return count <= 1

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var current_frame = Engine.get_process_frames()
	if current_frame == _last_execution_frame:
		return
	
	_last_execution_frame = current_frame

	for target in targets:
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(25, Modifier.Type.NO_MODIFIER)
