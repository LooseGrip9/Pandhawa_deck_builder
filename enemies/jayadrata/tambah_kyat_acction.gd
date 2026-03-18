class_name ActionBuffKyat
extends EnemyAction

@export var kyat_amount := 5
@export var kyat_resource: Resource 

var has_used := false

func is_performable() -> bool:
	if not enemy or not kyat_resource:
		return false

	if has_used:
		return false
		
	var current_enemies = enemy.get_tree().get_nodes_in_group("enemies")
	
	if current_enemies.size() <= 1:
		return false
		
	return true

func update_intent_text() -> void:
	intent.current_text = intent.base_text

func perform_action() -> void:
	if not enemy:
		Events.enemy_action_completed.emit(enemy)
		return

	has_used = true

	var tween := create_tween()
	
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y - 15, 0.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(enemy.sprite_2d, "modulate", Color(1.5, 0.5, 0.5), 0.2)
	
	tween.tween_callback(func():
		var current_enemies = enemy.get_tree().get_nodes_in_group("enemies")
		for ally in current_enemies:
			if ally != enemy:
				
				if kyat_resource:
					# 1. Duplicate the resource to avoid modifying the original file
					var applied_kyat = kyat_resource.duplicate()
					
					# 2. Set the values inside the resource object
					applied_kyat.stacks = kyat_amount
					applied_kyat.duration = kyat_amount # Crucial for 'Duration' stack types!
					
					# 3. Pass only the ONE argument (the resource object)
					if ally.get("status_handler") and ally.status_handler.has_method("add_status"):
						ally.status_handler.add_status(applied_kyat)
					elif ally.has_method("add_status"):
						ally.add_status(applied_kyat)
					elif ally.has_method("apply_status"):
						ally.apply_status(applied_kyat)
				
				if ally.get("sprite_2d"):
					var ally_tween = ally.create_tween()
					ally_tween.tween_property(ally.sprite_2d, "scale", Vector2(1.2, 1.2), 0.1)
					ally_tween.tween_property(ally.sprite_2d, "scale", Vector2.ONE, 0.1)
	)
	
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y, 0.2).set_delay(0.2)
	tween.parallel().tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.2)
	
	tween.finished.connect(func():
		Events.enemy_action_completed.emit(enemy)
	)
