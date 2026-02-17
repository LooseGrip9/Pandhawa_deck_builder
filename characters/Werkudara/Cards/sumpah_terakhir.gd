#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

@export var optional_sound: AudioStream

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	if not player_handler:
		return
		
	var stats = player_handler.character
	var damage_amount = stats.max_health - stats.health
	
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(damage_amount, Modifier.Type.NO_MODIFIER)
