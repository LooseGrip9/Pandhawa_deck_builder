class_name ActionKarnaBhargavastra
extends EnemyAction

@export var bhargava_status: Status # Drag your 'bhargavastra_status.tres' here

func perform_action() -> void:
	if not enemy or not target: return
	
	var tween := create_tween()
	tween.tween_property(enemy.sprite_2d, "modulate", Color.GOLD, 0.3)
	
	tween.tween_callback(func():
		if target.has_node("StatusHandler") and bhargava_status:
			var status_handler = target.get_node("StatusHandler")
			var instance = bhargava_status.duplicate()
			status_handler.add_status(instance)
			
		print("Bhargavastra covers the sky! Arrows fall every time Arjuna moves.")
	)
	
	tween.tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.3)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))

func update_intent_text() -> void:
	intent.current_text = "Hujan Panah"
