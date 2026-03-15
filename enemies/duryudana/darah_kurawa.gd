class_name ActionDarahKurawa
extends EnemyAction

@export var thorns_status: Status 
@export var thorns_amount := 2    

func is_performable() -> bool:
	if not enemy or not enemy.get("stats"): return false
	
	var is_low_hp = enemy.stats.health <= (enemy.stats.max_health * 0.3)
	
	var already_has_thorns = false
	if enemy.status_handler:
		for child in enemy.status_handler.get_children():
			var data = child.get("status")
			if data and data.id == "berduri":
				already_has_thorns = true
				
	return is_low_hp and not already_has_thorns

func update_intent_text() -> void:
	intent.current_text = intent.base_text

func perform_action() -> void:
	if not enemy or not thorns_status: return
	
	var tween := create_tween()
	
	tween.tween_property(enemy.sprite_2d, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(enemy.sprite_2d, "modulate", Color.DARK_RED, 0.2)
	tween.tween_callback(func(): Shaker.shake(enemy, 20.0, 0.4))
	
	tween.tween_callback(func():
		print("Phase 3! Duryudana's HP dropped below 30% and he is enraged!")
		var handler = enemy.get_node_or_null("StatusHandler")
		if handler:
			var new_thorns = thorns_status.duplicate() as Status
			
			new_thorns.stacks = thorns_amount 
			handler.add_status(new_thorns)
	)
	
	tween.tween_interval(0.4)
	tween.tween_property(enemy.sprite_2d, "scale", Vector2.ONE, 0.2)
	tween.tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.2)
	
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))
