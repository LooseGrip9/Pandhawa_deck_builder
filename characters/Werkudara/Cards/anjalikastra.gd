extends Card

var _last_execution_frame: int = -1
var base_damage := 25

func get_default_tooltip() -> String:
	return tooltip_text % base_damage

func is_playable(hand_node: Node) -> bool:
	if not hand_node:
		return false
		
	var count = 0
	for child in hand_node.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			count += 1
			
	return count == 1

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var current_frame = Engine.get_process_frames()
	if current_frame == _last_execution_frame:
		return
	
	_last_execution_frame = current_frame

	var actual_damage = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)

	var damage_effect := DamageEffect.new()
	damage_effect.amount = actual_damage
	damage_effect.sound = sound
	damage_effect.execute(targets)
