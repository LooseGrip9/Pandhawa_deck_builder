class_name MultiAttackAction
extends EnemyAction

@export var total_cycle_damage := 12 
@export var damage_per_bolt := 3
@export var hit_count := 4           
@export var jam_status_res: Status   

func perform_action() -> void:
	if not enemy or not target:
		Events.enemy_action_completed.emit(enemy)
		return
	
	var jam_status = enemy.status_handler.get_status("macet")
	var actual_hits: int = 1 if jam_status else hit_count
		
	var damage_per_bolt: int = floor(total_cycle_damage / hit_count) 
	
	var draw_status = enemy.status_handler.get_status("tarik_busur")
	if draw_status:
		damage_per_bolt += draw_status.stacks 
	
	if enemy.modifier_handler:
		damage_per_bolt = enemy.modifier_handler.get_modified_value(damage_per_bolt, Modifier.Type.DMG_DEALT)
	
	var damage_effect := DamageEffect.new()
	damage_effect.amount = damage_per_bolt 
	damage_effect.sound = sound
	var target_array: Array[Node] = [target]
	
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var original_pos := enemy.global_position
	
	for i in actual_hits:
		tween.tween_property(enemy, "global_position:x", original_pos.x + 10, 0.04)
		tween.tween_callback(damage_effect.execute.bind(target_array))
		tween.tween_property(enemy, "global_position:x", original_pos.x, 0.04)
		tween.tween_interval(0.12)
	
	tween.finished.connect(
		func():
			if not jam_status and jam_status_res:
				enemy.status_handler.add_status(jam_status_res.duplicate())
			Events.enemy_action_completed.emit(enemy)
	)
	
func update_intent_text() -> void:
	if not intent or not enemy or not target:
		return
		
	var modified_dmg: int = damage_per_bolt
	
	var draw_status = enemy.status_handler.get_status("tarik_busur")
	if draw_status:
		modified_dmg += draw_status.stacks
	
	if enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_DEALT)
	
	# Check for "macet" status to show only 1 hit if jammed
	var jam_status = enemy.status_handler.get_status("macet")
	var displayed_hits = 1 if jam_status else hit_count
	
	# Fixes the "%s x %s" visual issue
	intent.current_text = intent.base_text % [modified_dmg, displayed_hits]
