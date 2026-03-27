class_name ActionPanahWijayadanu
extends EnemyAction

@export var damage := 12

func perform_action() -> void:
	if not enemy or not target: return
	
	var modified_damage := damage
	if enemy.get("modifier_handler") and enemy.modifier_handler:
		modified_damage = enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var start_pos: Vector2 = enemy.global_position
	
	tween.tween_property(enemy, "global_position", start_pos + Vector2.LEFT * 30, 0.15)
	
	tween.tween_callback(func():
		var damage_effect := DamageEffect.new()
		damage_effect.amount = modified_damage
		damage_effect.execute([target])
		Shaker.shake(target, 15, 0.2)
	)
	
	tween.tween_property(enemy, "global_position", start_pos, 0.3)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))

func update_intent_text() -> void:
	if not enemy or not target or not is_inside_tree(): return
	var player := target as Player
	var modified_dmg := damage
	
	if enemy.get("modifier_handler") and enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	if player and player.get("modifier_handler") and player.modifier_handler:
		modified_dmg = player.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	
	intent.current_text = intent.base_text % modified_dmg
