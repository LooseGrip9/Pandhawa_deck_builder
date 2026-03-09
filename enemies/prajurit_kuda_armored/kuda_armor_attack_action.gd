class_name KudaBeratAttackAction
extends EnemyAction

@export var base_damage := 10
@export var inherent_block := 5
@export var laju_status_res: Status 

func update_intent_text() -> void:
	if not intent or not enemy:
		return
		
	var final_dmg := base_damage
	var momentum: LajuStatus = enemy.status_handler.get_status("laju") as LajuStatus
	
	if momentum:
		final_dmg += momentum.get_bonus_damage()
		
	if enemy.modifier_handler:
		final_dmg = enemy.modifier_handler.get_modified_value(final_dmg, Modifier.Type.DMG_DEALT)
		
	intent.current_text = intent.base_text % final_dmg

func perform_action() -> void:
	if not enemy or not target:
		Events.enemy_action_completed.emit(enemy)
		return
	
	# --- REVERTED TO YOUR EXACT ORIGINAL BLOCK LOGIC ---
	var block_effect := BlockEffect.new()
	block_effect.amount = inherent_block
	block_effect.sound = sound # <--- This is the missing line!
	block_effect.execute([enemy])
	
	var final_dmg := base_damage
	var momentum: LajuStatus = enemy.status_handler.get_status("laju") as LajuStatus
	
	if momentum:
		final_dmg += momentum.get_bonus_damage()
	
	if enemy.modifier_handler:
		final_dmg = enemy.modifier_handler.get_modified_value(final_dmg, Modifier.Type.DMG_DEALT)
	
	var tween := create_tween()
	var original_pos := enemy.global_position
	
	for i in range(3):
		tween.tween_property(enemy, "global_position:x", original_pos.x + 15, 0.15)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(enemy, "global_position:x", original_pos.x - 5, 0.15)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(enemy, "global_position:x", target.global_position.x + 50, 0.1)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(
		func():
			var damage_effect := DamageEffect.new()
			damage_effect.amount = final_dmg
			damage_effect.sound = sound
			damage_effect.execute([target])
			if Shaker:
				Shaker.shake(enemy, 10, 0.2)
	)
	
	tween.tween_interval(0.1)
	tween.tween_property(enemy, "global_position", original_pos, 0.3)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func():
		var current_momentum = enemy.status_handler.get_status("laju") as LajuStatus
		
		if not current_momentum and laju_status_res:
			var new_laju = laju_status_res.duplicate()
			new_laju.stacks = 1
			enemy.status_handler.add_status(new_laju)
		elif current_momentum:
			current_momentum.stacks += 1
			
		enemy.status_handler.statuses_changed.emit()
		enemy.update_intent()
		Events.enemy_action_completed.emit(enemy)
	)
