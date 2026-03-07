class_name KudaAttackAction
extends EnemyAction

@export var base_damage := 6
@export var laju_status_res: Status 

func perform_action() -> void:
	if not enemy or not target:
		Events.enemy_action_completed.emit(enemy)
		return
	
	var final_dmg := base_damage
	var momentum: LajuStatus = enemy.status_handler.get_status("laju") as LajuStatus
	
	# Add the bonus damage if the horse has momentum
	if momentum:
		final_dmg += momentum.get_bonus_damage()
	
	if enemy.modifier_handler:
		final_dmg = enemy.modifier_handler.get_modified_value(final_dmg, Modifier.Type.DMG_DEALT)
	
	var damage_effect := DamageEffect.new()
	damage_effect.amount = final_dmg
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	var original_pos := enemy.global_position
	
	# Dash forward and strike
	tween.tween_property(enemy, "global_position:x", target.global_position.x + 50, 0.2)
	tween.tween_callback(damage_effect.execute.bind([target]))
	tween.tween_property(enemy, "global_position", original_pos, 0.2)
	
	tween.finished.connect(func():
		# Apply or Increase Laju at the end of the turn
		if not momentum and laju_status_res:
			enemy.status_handler.add_status(laju_status_res.duplicate())
		elif momentum:
			momentum.stacks += 1
			enemy.status_handler.statuses_changed.emit()
		
		Events.enemy_action_completed.emit(enemy)
	)
