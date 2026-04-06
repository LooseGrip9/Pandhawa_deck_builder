extends Card

var _last_execution_frame: int = -1

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(_targets: Array[Node], modifiers: ModifierHandler) -> void:
	var current_frame = Engine.get_process_frames()
	if current_frame == _last_execution_frame:
		return
	
	_last_execution_frame = current_frame

	var tree = Engine.get_main_loop() as SceneTree
	
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(8, Modifier.Type.DMG_DEALT) 
	damage_effect.sound = sound
	
	for i in range(3):
		var all_enemies = tree.get_nodes_in_group("enemies")
		var valid_targets = []
		
		for e in all_enemies:
			if is_instance_valid(e) and not e.is_queued_for_deletion():
				if e.get("stats") and e.stats.health > 0:
					valid_targets.append(e)
		
		if valid_targets.is_empty():
			break
			
		var target = valid_targets.pick_random()
		
		damage_effect.execute([target])
		
		await tree.create_timer(0.2).timeout
