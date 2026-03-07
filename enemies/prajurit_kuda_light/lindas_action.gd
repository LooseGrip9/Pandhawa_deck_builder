class_name TrampleAction
extends EnemyAction

@export var base_damage := 15

func is_performable() -> bool:
	var momentum = enemy.status_handler.get_status("laju")
	return momentum != null and momentum.stacks >= 3

func perform_action() -> void:
	if not enemy or not target:
		Events.enemy_action_completed.emit(enemy)
		return
		
	var final_dmg = base_damage
	if enemy.modifier_handler:
		final_dmg = enemy.modifier_handler.get_modified_value(final_dmg, Modifier.Type.DMG_DEALT)
		
	var damage_effect := DamageEffect.new()
	damage_effect.amount = final_dmg
	
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	var original_pos := enemy.global_position
	
	tween.tween_property(enemy, "global_position:y", original_pos.y - 100, 0.3)
	tween.tween_property(enemy, "global_position:x", target.global_position.x, 0.2)
	tween.tween_callback(damage_effect.execute.bind([target]))
	tween.tween_property(enemy, "global_position", original_pos, 0.3)
	
	tween.finished.connect(func():
		var momentum = enemy.status_handler.get_status("laju")
		if momentum:
			momentum.stacks = 0
			enemy.status_handler.remove_status("laju")
			enemy.status_handler.statuses_changed.emit()
			
		Events.enemy_action_completed.emit(enemy)
	)
