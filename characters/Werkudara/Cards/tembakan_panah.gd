extends Card

@export var base_damage := 5

func get_default_tooltip() -> String:
	return tooltip_text % base_damage

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := _player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	
	if _enemy_modifiers:
		modified_dmg = _enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	
	return tooltip_text % modified_dmg

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	# 1. Access the SceneTree through the targets
	var tree: SceneTree = null
	if not targets.is_empty():
		tree = targets[0].get_tree()
	
	if not tree: 
		return

	# 2. Reference your PlayerHandler (finds the node with the 'player_handler' group)
	var handler = tree.get_first_node_in_group("player_handler") as PlayerHandler

	# 3. Setup the Damage Effect
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	
	# 4. Create the sequence Tween
	var tween = tree.create_tween()
	
	# Hit 1
	tween.tween_callback(damage_effect.execute.bind(targets))
	tween.tween_interval(0.2)
	
	
	# Draw 1 Card (Uses your HAND_DRAW_INTERVAL of 0.25s internally)
	if handler:
		tween.tween_callback(handler.draw_cards.bind(1))
