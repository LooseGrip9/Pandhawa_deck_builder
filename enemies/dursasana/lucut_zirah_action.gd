class_name ActionLucutZirah
extends EnemyAction

@export var damage := 12

func update_intent_text() -> void:
	var modified_damage := damage
	
	if enemy and enemy.modifier_handler:
		modified_damage = enemy.modifier_handler.get_modified_value(modified_damage, Modifier.Type.DMG_DEALT)
		
	intent.current_text = intent.base_text % modified_damage

func perform_action() -> void:
	if not enemy or not target: return

	var sprite := enemy.sprite_2d
	var original_pos := sprite.position
	
	# Find the Player's sprite so we can knock it backwards
	var target_sprite: Node2D = target.get("sprite_2d")
	if not target_sprite:
		target_sprite = target.get_node_or_null("Sprite2D")
	if not target_sprite:
		target_sprite = target 
		
	var target_original_pos := target_sprite.position
	
	var tween := create_tween()
	
	# 1. THE WINDUP: Dursasana leaps high up and pulls back
	tween.tween_property(sprite, "position", original_pos + Vector2(30, -80), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.15)
	
	# 2. THE SLAM: Crashes down diagonally into the player
	tween.tween_property(sprite, "position", original_pos + Vector2(-50, 10), 0.15).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	# 3. IMPACT: Damage and Block Strip happen the exact frame he hits
	tween.tween_callback(func():
		Shaker.shake(target, 40.0, 0.4) # Huge screen shake

		var player_stats = target.get("stats")
		if player_stats and player_stats.block > 0:
			player_stats.block = 0
			print("Dursasana shattered your Block!")
		
		var final_damage = damage
		if enemy.modifier_handler:
			final_damage = enemy.modifier_handler.get_modified_value(final_damage, Modifier.Type.DMG_DEALT)
		
		if target.has_method("take_damage"):
			target.take_damage(final_damage, Modifier.Type.NO_MODIFIER) 
	)
	
	# 4. THE KNOCKBACK: Player is sent flying backward and slightly up from the force
	tween.tween_property(target_sprite, "position", target_original_pos + Vector2(-60, -20), 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	# Hold the pose for a moment to emphasize the weight of the blow
	tween.tween_interval(0.25)
	
	# 5. RECOVERY: Both Dursasana and the Player return to their normal combat stances
	tween.tween_property(sprite, "position", original_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(target_sprite, "position", target_original_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))
