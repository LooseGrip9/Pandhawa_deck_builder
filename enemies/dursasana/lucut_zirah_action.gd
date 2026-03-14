class_name ActionLucutZirah
extends EnemyAction

@export var damage := 12

func perform_action() -> void:
	if not enemy or not target: return

	var sprite := enemy.sprite_2d
	var original_pos := sprite.position
	
	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	tween.tween_property(sprite, "position", original_pos + Vector2(30, 0), 0.4)
	tween.tween_interval(0.1)
	
	tween.tween_property(sprite, "position", original_pos - Vector2(40, 0), 0.1)
	tween.tween_callback(func():
		Shaker.shake(target, 30.0, 0.4) 

		var player_stats = target.get("stats")
		if player_stats and player_stats.block > 0:
			player_stats.block = 0
			print("Dursasana destroyed your Block!")
		
		var final_damage = damage
		if enemy.modifier_handler:
			final_damage = enemy.modifier_handler.get_modified_value(final_damage, Modifier.Type.DMG_DEALT)
		
		if target.has_method("take_damage"):
			target.take_damage(final_damage)
	)
	
	tween.tween_property(sprite, "position", original_pos, 0.3)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))
