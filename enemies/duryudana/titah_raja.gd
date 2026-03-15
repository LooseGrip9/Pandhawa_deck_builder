class_name ActionTitahRaja
extends EnemyAction

@export var block_amount := 8

func is_performable() -> bool:
	if not enemy: return false
	
	var enemies = enemy.get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e != enemy and not e.is_queued_for_deletion() and e.get("stats") and e.stats.health > 0:
			return true
			
	return false

func update_intent_text() -> void:
	intent.current_text = intent.base_text % block_amount

func perform_action() -> void:
	if not enemy: return
	
	var tween := create_tween()
	
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y - 15, 0.2).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(func():
		print("Duryudana used Titah Raja! The Kurawa raise their shields!")
		
		if enemy.get("stats"):
			enemy.stats.block += block_amount
			
		var enemies = enemy.get_tree().get_nodes_in_group("enemies")
		for e in enemies:
			if e != enemy and not e.is_queued_for_deletion() and e.get("stats") and e.stats.health > 0:
				e.stats.block += block_amount
				
				if e.get("sprite_2d"):
					var minion_tween = e.create_tween()
					minion_tween.tween_property(e.sprite_2d, "modulate", Color.BLUE, 0.2)
					minion_tween.tween_property(e.sprite_2d, "modulate", Color.WHITE, 0.2)
	)
	
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y, 0.2).set_delay(0.2)
	
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))
