class_name ActionVasaviExecute
extends EnemyAction

@export var damage := 60

func perform_action() -> void:
	if not enemy or not target: return
	
	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	var start_pos = enemy.global_position
	
	# Visuals: The Spear strike
	tween.tween_property(enemy, "global_position", target.global_position, 0.1)
	tween.tween_callback(func():
		var damage_effect := DamageEffect.new()
		damage_effect.amount = damage
		damage_effect.execute([target])
		Shaker.shake(target, 40, 0.4)
	)
	
	# Return and reset colors
	tween.tween_property(enemy, "global_position", start_pos, 0.2)
	tween.tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.1)
	
	tween.finished.connect(func(): 
		Events.enemy_action_completed.emit(enemy)
	)

func update_intent_text() -> void:
	var modified_dmg := damage
	if enemy and enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_DEALT)
	intent.current_text = intent.base_text % modified_dmg
