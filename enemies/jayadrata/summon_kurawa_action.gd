class_name ActionSummonKurawa
extends EnemyAction

# Drag your Kurawa Guard enemy scene (.tscn) into this slot in the Inspector!
@export var minion_scene: PackedScene 
@export var max_minions := 2

func is_performable() -> bool:
	if not enemy or not minion_scene:
		return false
	
	var current_enemies = enemy.get_tree().get_nodes_in_group("enemies")
	
	
	if (current_enemies.size() - 1) >= max_minions:
		return false
		
	return true

func update_intent_text() -> void:
	intent.current_text = intent.base_text

func perform_action() -> void:
	if not enemy or not minion_scene:
		Events.enemy_action_completed.emit(enemy)
		return

	var tween := create_tween()
	
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y - 15, 0.2).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(func():
		print("Jayadrata is stalling! A Kurawa Guard enters the battlefield!")
		
		var new_minion = minion_scene.instantiate() as Enemy
		if new_minion:
			enemy.get_parent().add_child(new_minion)
			
			new_minion.global_position = enemy.global_position + Vector2(-80, 0)
			
			new_minion.scale = Vector2.ZERO
			var spawn_tween = new_minion.create_tween()
			spawn_tween.tween_property(new_minion, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BOUNCE)
	)
	
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y, 0.2).set_delay(0.2)
	
	tween.finished.connect(func():
		Events.enemy_action_completed.emit(enemy)
	)
