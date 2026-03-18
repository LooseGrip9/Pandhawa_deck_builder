class_name ActionSetyawatiSorrow
extends EnemyAction

@export var damage := 10

func perform_action() -> void:
	if not enemy or not target: return
	
	var modified_damage := damage
	if enemy.get("modifier_handler") and enemy.modifier_handler:
		modified_damage = enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var start_pos: Vector2 = enemy.global_position
	
	tween.tween_property(enemy, "global_position", target.global_position + Vector2.RIGHT * 40, 0.4)
	
	tween.tween_callback(func():
		var damage_effect := DamageEffect.new()
		damage_effect.amount = modified_damage
		damage_effect.execute([target])
		
		print("Salya's sorrow affects the player's strength!")
	)
	
	tween.tween_property(enemy, "global_position", start_pos, 0.4)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))

func update_intent_text() -> void:
	if not enemy or not target or not is_inside_tree(): return
	var modified_dmg := damage
	if enemy.get("modifier_handler") and enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	
	intent.current_text = intent.base_text % modified_dmg
