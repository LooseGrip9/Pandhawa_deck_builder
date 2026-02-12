extends Card

@export var damage := 100
@export var optional_sound: AudioStream

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in targets:
		if target is Enemy:
			target.take_damage(damage, Modifier.Type.NO_MODIFIER)
	
	if targets.is_empty():
		return
		
	var tree = targets[0].get_tree()
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	if player_handler:
		player_handler.turns_locked = 2
