class_name ActionKarnaNagastra
extends EnemyAction

@export var base_damage := 15

func perform_action() -> void:
	if not enemy or not target: return
	
	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	# Visual: Karna stands perfectly still while a green projectile tracks the player
	tween.tween_property(enemy, "global_position", enemy.global_position + Vector2.UP * 20, 0.5)
	
	tween.tween_callback(func():
		var damage_effect := DamageEffect.new()
		damage_effect.amount = base_damage
		damage_effect.execute([target])
		
		# Lore: The Nagastra lowers Arjuna's defense
		if target.get("modifier_handler"):
			# Apply 'Vulnerable' or lower his block efficiency
			print("The Nagastra poisons Arjuna's defenses!")
	)
	
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))

func update_intent_text() -> void:
	intent.current_text = (intent.base_text % base_damage) + " & Lemah"
