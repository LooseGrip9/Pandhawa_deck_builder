extends Card

var base_damage := 4

func get_default_tooltip() -> String:
	return tooltip_text % base_damage

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := _player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	
	if _enemy_modifiers:
		modified_dmg = _enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	
	return tooltip_text % modified_dmg

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	# We need a SceneTree or Node to create a Tween. 
	# Usually, the 'targets' or the 'modifiers' owner can provide this.
	var scene_root = targets[0].get_tree() if not targets.is_empty() else null
	if not scene_root:
		return

	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	
	# Create a tween to handle the timing
	var tween = scene_root.create_tween()
	
	for i in 2:
		# Call the execution
		tween.tween_callback(damage_effect.execute.bind(targets))
		# Add the delay between hits (e.g., 0.2 seconds)
		tween.tween_interval(0.2)
