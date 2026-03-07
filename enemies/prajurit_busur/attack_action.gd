class_name BusurAttackAction
extends EnemyAction

@export var damage := 8

func update_intent_text() -> void:
	var player := target as Player
	if not player:
		return
	
	var bonus := 0
	var draw_status = enemy.status_handler.get_status("tarik_busur")
	if draw_status:
		bonus = draw_status.stacks
	
	var modified_dmg: int = damage + bonus
	
	if enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_DEALT)
		
	if player.modifier_handler:
		modified_dmg = player.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
		
	intent.current_text = intent.base_text % modified_dmg

func perform_action() -> void:
	if not enemy:
		push_error("BOW ENEMY ERROR: AttackAction doesn't know who the enemy is!")
		return
		
	if not target:
		push_error("BOW ENEMY ERROR: AttackAction cannot find the Player target!")
		Events.enemy_action_completed.emit(enemy)
		return
		
	var bonus := 0
	var draw_status = enemy.status_handler.get_status("tarik_busur")
	if draw_status:
		bonus = draw_status.stacks
		
	var total_base_damage: int = damage + bonus
	var modified_damage: int = total_base_damage
	
	if enemy.modifier_handler:
		modified_damage = enemy.modifier_handler.get_modified_value(total_base_damage, Modifier.Type.DMG_DEALT)
	
	var damage_effect := DamageEffect.new()
	var target_array: Array[Node] = [target]
	
	damage_effect.amount = modified_damage 
	damage_effect.sound = sound
	
	# Using TRANS_BACK for a mechanical "snap" feel
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var original_pos := enemy.global_position
	
	# 1. Fire and Recoil
	# Quick kick back (12 pixels) and snap back to position
	tween.tween_property(enemy, "global_position:x", original_pos.x + 12, 0.05)
	tween.tween_callback(damage_effect.execute.bind(target_array))
	tween.tween_property(enemy, "global_position:x", original_pos.x, 0.1)
	
	# 2. Brief pause before finishing turn
	tween.tween_interval(0.2)
	
	tween.finished.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)
