class_name ActionChandrabirawaResonance
extends EnemyAction

@export var resonance_amount := 5

func perform_action() -> void:
	if not enemy: return
	
	var tween := create_tween()
	tween.tween_property(enemy.sprite_2d, "modulate", Color.PURPLE, 0.3)
	
	tween.tween_callback(func():
		print("Aji Chandrabirawa is active! Every hit will be returned!")
	)
	
	tween.tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.3).set_delay(0.5)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))

func update_intent_text() -> void:
	intent.current_text = "Chandrabirawa: Counter-Attack Stance"
