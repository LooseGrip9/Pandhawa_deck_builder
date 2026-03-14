class_name ActionPasangJerat
extends EnemyAction

@export var status_resource: Status 

func perform_action() -> void:
	if not enemy or not target: return
	
	var sprite := enemy.sprite_2d
	var original_scale := sprite.scale
	var is_attack_trap := randf() > 0.5
	
	var main_tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	main_tween.tween_property(sprite, "scale", original_scale * 1.6, 0.3)
	
	main_tween.tween_callback(func():
		Shaker.shake(enemy, 35.0, 0.4)
		
		var handler = target.get_node_or_null("StatusHandler")
		if handler:
			for child in handler.get_children():
				var status_data = child.get("status")
				if status_data and status_data.id == "jerat_sengkuni":
					child.queue_free()
			
			var new_jerat = status_resource.duplicate() as Status
			new_jerat.target_type = 0 if is_attack_trap else 1
			
			if handler.has_method("add_status"):
				handler.add_status(new_jerat)
			
			if enemy.has_method("_refresh_card_costs"):
				enemy._refresh_card_costs()
	)
	
	main_tween.tween_interval(0.4)
	main_tween.tween_property(sprite, "scale", original_scale, 0.3)
	
	main_tween.finished.connect(func(): 
		if enemy.get("doing_opening_move"): 
			enemy.doing_opening_move = false 
		else:
			Events.enemy_action_completed.emit(enemy)
	)
