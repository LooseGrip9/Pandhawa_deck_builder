class_name AssassinPoisonAction
extends EnemyAction

@export var base_damage := 5
@export var poison_stacks := 3
@export var poison_status_res: Status 

func update_intent_text() -> void:
	if not intent or not enemy:
		return
		
	var final_dmg := base_damage
	if enemy.modifier_handler:
		final_dmg = enemy.modifier_handler.get_modified_value(final_dmg, Modifier.Type.DMG_DEALT)
		
	intent.current_text = intent.base_text % final_dmg

func perform_action() -> void:
	if not enemy or not target:
		Events.enemy_action_completed.emit(enemy)
		return
	
	var final_dmg := base_damage
	if enemy.modifier_handler:
		final_dmg = enemy.modifier_handler.get_modified_value(final_dmg, Modifier.Type.DMG_DEALT)
	
	var tween := create_tween()
	var original_pos := enemy.global_position
	
	if enemy.sprite_2d:
		tween.tween_property(enemy.sprite_2d, "modulate:a", 0.2, 0.2)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(enemy, "global_position:x", original_pos.x + 20, 0.2)
	
	tween.tween_property(enemy, "global_position:x", target.global_position.x + 40, 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	if enemy.sprite_2d:
		tween.parallel().tween_property(enemy.sprite_2d, "modulate:a", 1.0, 0.1)
	
	tween.tween_callback(
		func():
			var damage_effect := DamageEffect.new()
			damage_effect.amount = final_dmg
			if sound:
				damage_effect.sound = sound
			damage_effect.execute([target])
			
			if Shaker:
				Shaker.shake(enemy, 5, 0.15) 
			
			var target_status_handler = target.get("status_handler")
			if poison_status_res and target_status_handler:
				var current_poison = target_status_handler.get_status("poison")
				
				if not current_poison:
					var new_poison = poison_status_res.duplicate()
					new_poison.stacks = poison_stacks
					target_status_handler.add_status(new_poison)
				else:
					current_poison.stacks += poison_stacks
					
				target_status_handler.statuses_changed.emit()
	)
	
	tween.tween_interval(0.1)
	tween.tween_property(enemy, "global_position", original_pos, 0.25)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func():
		enemy.update_intent()
		Events.enemy_action_completed.emit(enemy)
	)
