class_name ActionHantamanBerdarah
extends EnemyAction

@export var damage := 20
@export var strength_status: Status
@export var strength_gain := 2

func is_performable() -> bool:
	if not enemy or not enemy.get("stats"): return false
	
	return enemy.stats.health <= (enemy.stats.max_health * 0.3)

func update_intent_text() -> void:
	var modified_dmg := damage
	if enemy and enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_DEALT)
		
	intent.current_text = intent.base_text % [modified_dmg, strength_gain]

func perform_action() -> void:
	if not enemy or not target: return
	
	var tween := create_tween()
	var original_pos = enemy.sprite_2d.position
	
	tween.tween_property(enemy.sprite_2d, "position", original_pos + Vector2(20, -20), 0.3).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(func(): Shaker.shake(enemy, 10.0, 0.3))
	tween.tween_interval(0.3)
	
	tween.tween_property(enemy.sprite_2d, "position", original_pos + Vector2(-40, 20), 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(func():
		Shaker.shake(target, 25.0, 0.4)
		
		var final_damage = damage
		if enemy.modifier_handler:
			final_damage = enemy.modifier_handler.get_modified_value(final_damage, Modifier.Type.DMG_DEALT)
		
		if target.has_method("take_damage"):
			target.take_damage(final_damage, Modifier.Type.NO_MODIFIER)
			
		var handler = enemy.get_node_or_null("StatusHandler")
		if handler and strength_status:
			var new_strength = strength_status.duplicate() as Status
			new_strength.stacks = strength_gain
			handler.add_status(new_strength)
			print("Duryudana's rage grows! He gained +%d Kuat!" % strength_gain)
	)
	
	tween.tween_property(enemy.sprite_2d, "position", original_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))
