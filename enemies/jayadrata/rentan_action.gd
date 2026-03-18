class_name ActionApplyRentan
extends EnemyAction

@export var rentan_amount := 2
@export var rentan_resource: Resource 

func is_performable() -> bool:
	if not enemy or not rentan_resource:
		return false
	return true

func update_intent_text() -> void:
	intent.current_text = intent.base_text

func perform_action() -> void:
	if not enemy:
		Events.enemy_action_completed.emit(enemy)
		return

	var tween := create_tween()
	
	# Visual cue: Boss hops and turns purple
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y - 15, 0.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(enemy.sprite_2d, "modulate", Color(1.2, 0.5, 1.5), 0.2)
	
	tween.tween_callback(func():
		var player = enemy.get_tree().get_first_node_in_group("player")
		
		if player and rentan_resource:
			var applied_rentan = rentan_resource.duplicate()
			
			# CRITICAL FIX: Because your resource uses 'Duration' stack type, 
			# we MUST set duration to something higher than 0.
			applied_rentan.stacks = rentan_amount
			applied_rentan.duration = rentan_amount
			
			var handler = player.get_node_or_null("StatusHandler")
			
			if handler and handler.has_method("add_status"):
				handler.add_status(applied_rentan)
				print("Rentan applied to player with duration: ", rentan_amount)
			elif player.has_method("add_status"):
				player.add_status(applied_rentan)
			
			# Visual feedback: Shake the player
			if player.get("sprite_2d"):
				var p_tween = player.create_tween()
				var original_x = player.sprite_2d.position.x
				p_tween.tween_property(player.sprite_2d, "position:x", original_x + 10, 0.05)
				p_tween.tween_property(player.sprite_2d, "position:x", original_x - 10, 0.05)
				p_tween.tween_property(player.sprite_2d, "position:x", original_x, 0.05)
	)
	
	# Boss returns to normal
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y, 0.2).set_delay(0.2)
	tween.parallel().tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.2)
	
	tween.finished.connect(func():
		Events.enemy_action_completed.emit(enemy)
	)
