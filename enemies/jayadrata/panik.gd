class_name ActionJayadrataDesperate
extends EnemyAction

@export var damage := 18 

func is_performable() -> bool:
	if not enemy: return false
	
	var enemies = enemy.get_tree().get_nodes_in_group("enemies")
	return enemies.size() == 1

func perform_action() -> void:
	if not enemy or not target: return
	
	var modified_damage := damage
	if enemy.get("modifier_handler") and enemy.modifier_handler:
		modified_damage = enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	var start_pos: Vector2 = enemy.global_position
	var end_pos: Vector2 = target.global_position + Vector2.RIGHT * 32
	
	tween.tween_callback(Shaker.shake.bind(enemy, 25, 0.4))
	tween.tween_interval(0.4)

func update_intent_text() -> void:
	if not enemy or not target or not is_inside_tree(): return
		
	var player := target as Player
	var modified_dmg := damage
	
	if enemy.get("modifier_handler") and enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
		
	if player and player.get("modifier_handler") and player.modifier_handler:
		modified_dmg = player.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	
	intent.current_text = intent.base_text % modified_dmg
