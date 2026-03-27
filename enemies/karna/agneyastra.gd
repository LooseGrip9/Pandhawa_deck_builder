class_name ActionKarnaAgneyastra
extends EnemyAction

@export var damage := 3
@export var times := 5

func perform_action() -> void:
	if not enemy or not target: return
	
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var start_pos: Vector2 = enemy.global_position
	
	tween.tween_property(enemy.sprite_2d, "modulate", Color.ORANGE_RED, 0.1)
	
	for i in range(times):
		tween.tween_callback(func():
			var damage_effect := DamageEffect.new()
			damage_effect.amount = damage
			damage_effect.execute([target])
		)
		tween.tween_interval(0.1)
	
	tween.tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.2)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))

func update_intent_text() -> void:
	var modified_dmg := damage
	if enemy and enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_DEALT)
	intent.current_text = intent.base_text % modified_dmg
