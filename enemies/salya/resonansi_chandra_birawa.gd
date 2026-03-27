class_name ActionResonansiChandrabirawa
extends EnemyAction

@export var resonance_increase := 6

func perform_action() -> void:
	if not enemy: return
	
	var tween := create_tween()
	tween.tween_property(enemy.sprite_2d, "modulate", Color.YELLOW, 0.3)
	
	tween.tween_callback(func():
			enemy.stats.counter_damage += resonance_increase
			enemy.update_stats()
			print("Resonansi Chandrabirawa stacks! Total Counter: ", enemy.stats.counter_damage)
	)
	
	tween.tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.3).set_delay(0.5)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))
