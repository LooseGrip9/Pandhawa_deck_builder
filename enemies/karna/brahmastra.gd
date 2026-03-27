class_name ActionKarnaBrahmastra
extends EnemyAction

@export var damage := 20

func perform_action() -> void:
	if not enemy or not target: return
	
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	var start_pos: Vector2 = enemy.global_position
	
	tween.tween_property(enemy.sprite_2d, "modulate", Color.WHITE * 2, 0.4)
	
	tween.tween_callback(func():
		var damage_effect := DamageEffect.new()
		damage_effect.amount = damage
		if target.get("stats") and target.stats.block > 0:
			target.stats.block = floor(target.stats.block * 0.5)
			target.update_stats()
			
		damage_effect.execute([target])
		Shaker.shake(target, 20, 0.3)
	)
	
	tween.tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.2)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))

func update_intent_text() -> void:
	var modified_dmg := damage
	if enemy and enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_DEALT)
	intent.current_text = intent.base_text % modified_dmg
