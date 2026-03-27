class_name ActionVasaviCharge
extends EnemyAction

@export var execute_action: EnemyAction

func perform_action() -> void:
	if not enemy: return
	
	# Logic: Tell the universal picker what to do next turn
	if enemy.enemy_action_picker:
		enemy.enemy_action_picker.forced_next_action = execute_action
	
	# Visuals: Glow gold
	var tween := create_tween()
	tween.tween_property(enemy.sprite_2d, "modulate", Color(2, 2, 1), 0.5)
	
	tween.finished.connect(func(): 
		Events.enemy_action_completed.emit(enemy)
	)

func update_intent_text() -> void:
	intent.current_text = "Menghimpun Kekuatan Surya..."
