class_name ActionAmuk
extends EnemyAction

@export var damage_per_hit := 2
@export var hit_count := 4


func update_intent_text() -> void:
	var modified_damage := damage_per_hit
	
	if enemy and enemy.modifier_handler:
		modified_damage = enemy.modifier_handler.get_modified_value(modified_damage, Modifier.Type.DMG_DEALT)
		
	intent.current_text = intent.base_text % [modified_damage, hit_count]

func perform_action() -> void:
	if not enemy or not target: 
		return

	var sprite := enemy.sprite_2d
	var original_pos := sprite.position
	
	var tween := create_tween()
	
	tween.tween_property(sprite, "position", original_pos + Vector2(20, 0), 0.2).set_trans(Tween.TRANS_SINE)
	
	for i in range(hit_count):
		tween.tween_property(sprite, "position", original_pos + Vector2(-30, 0), 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		
		tween.tween_callback(func():
			Shaker.shake(target, 15.0, 0.15) 
			
			var final_damage = damage_per_hit
			if enemy.modifier_handler:
				final_damage = enemy.modifier_handler.get_modified_value(final_damage, Modifier.Type.DMG_DEALT)
			
			if target.has_method("take_damage"):
				target.take_damage(final_damage, Modifier.Type.NO_MODIFIER)
		)
		
		tween.tween_property(sprite, "position", original_pos + Vector2(10, 0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(sprite, "position", original_pos, 0.2).set_trans(Tween.TRANS_SINE)
	
	tween.finished.connect(func(): 
		Events.enemy_action_completed.emit(enemy)
	)
