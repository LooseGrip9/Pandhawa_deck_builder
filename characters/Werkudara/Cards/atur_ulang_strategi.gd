extends Card

@export var optional_sound: AudioStream
@export var block_amount := 8

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in targets:
		var stats = target.get("stats") as CharacterStats
		if stats:
			stats.block += block_amount
	
	if targets.is_empty(): return
	var tree := targets[0].get_tree()
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	if player_handler:
		
		player_handler.redraw_hand()
