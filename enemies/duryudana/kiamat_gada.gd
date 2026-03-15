class_name ActionKiamatGada
extends EnemyAction

@export var damage := 45

func is_performable() -> bool:
	if not enemy or not enemy.status_handler: return false
	
	for child in enemy.status_handler.get_children():
		var data = child.get("status")
		if data and data.id == "mengisi_gada":
			return true
	return false

func update_intent_text() -> void:
	var modified_dmg := damage
	if enemy and enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_DEALT)
	intent.current_text = intent.base_text % modified_dmg

func perform_action() -> void:
	if not enemy or not target: return
	
	var tween := create_tween()
	
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y - 100, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.2)
	
	tween.tween_property(enemy.sprite_2d, "position", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(func():
		Shaker.shake(target, 40.0, 0.5)
		
		var final_damage = enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
		if target.has_method("take_damage"):
			target.take_damage(final_damage, Modifier.Type.NO_MODIFIER)
		if enemy.status_handler:
			for child in enemy.status_handler.get_children():
				var data = child.get("status")
				if data and data.id == "mengisi_gada":
					child.queue_free()
	)
	
	tween.tween_interval(0.4)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))
