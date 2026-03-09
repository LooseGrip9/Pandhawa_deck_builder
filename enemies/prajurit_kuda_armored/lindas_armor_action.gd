class_name TrampleArmorAction
extends EnemyAction

@export var base_damage := 25

func is_performable() -> bool:
	var momentum = enemy.status_handler.get_status("laju")
	return momentum != null and momentum.stacks >= 3

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
		
	var final_dmg = base_damage
	if enemy.modifier_handler:
		final_dmg = enemy.modifier_handler.get_modified_value(final_dmg, Modifier.Type.DMG_DEALT)
	
	var tween := create_tween()
	var original_pos := enemy.global_position
	
	for i in range(3):
		tween.tween_property(enemy, "global_position:x", original_pos.x + 25, 0.25)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(enemy, "global_position:x", original_pos.x - 10, 0.25)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(enemy, "global_position:x", target.global_position.x + 40, 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(
		func():
			var damage_effect := DamageEffect.new()
			damage_effect.amount = final_dmg
			damage_effect.sound = sound
			damage_effect.execute([target])
			
			if Shaker:
				Shaker.shake(enemy, 12, 0.2) 
	)
	
	tween.tween_interval(0.2)
	tween.tween_property(enemy, "global_position", original_pos, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func():
		var momentum = enemy.status_handler.get_status("laju")
		if momentum:
			momentum.stacks = 0
			enemy.status_handler.remove_status("laju")
			enemy.status_handler.statuses_changed.emit()
		
		enemy.update_intent()
		Events.enemy_action_completed.emit(enemy)
	)
