class_name ActionProvokasi
extends EnemyAction

@export var provokasi_status: Status

func is_performable() -> bool:
	if not enemy or not enemy.get("stats"):
		return false
		
	var is_low_hp = enemy.stats.health <= 100
	
	var already_has_taunt = false
	if enemy.status_handler:
		for child in enemy.status_handler.get_children():
			var status_data = child.get("status")
			if status_data and status_data.id == "provokasi":
				already_has_taunt = true
				
	return is_low_hp and not already_has_taunt


func update_intent_text() -> void:
	intent.current_text = intent.base_text

func perform_action() -> void:
	if not enemy or not target: 
		return

	var sprite := enemy.sprite_2d
	var original_scale := sprite.scale
	
	var tween := create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(sprite, "scale", original_scale * 1.3, 0.2)
	tween.tween_property(sprite, "modulate", Color.RED, 0.2)
	
	tween.tween_callback(func():
		Shaker.shake(enemy, 15.0, 0.3)
		
		var handler = enemy.get_node_or_null("StatusHandler")
		if handler and handler.has_method("add_status") and provokasi_status:
			var new_taunt = provokasi_status.duplicate() as Status
			
			new_taunt.stacks = 1 
			
			handler.add_status(new_taunt)
			print("Phase 2! Dursasana reached 100 HP and used Provokasi!")
	)
	
	tween.tween_interval(0.5)
	tween.tween_property(sprite, "scale", original_scale, 0.2)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	tween.finished.connect(func(): 
		Events.enemy_action_completed.emit(enemy)
	)
