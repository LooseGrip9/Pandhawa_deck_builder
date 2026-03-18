class_name ActionSummonKurawa
extends EnemyAction

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
		var new_minion = minion_scene.instantiate() as Enemy
		if new_minion:
			# 1. Add minion to the world
			enemy.get_parent().add_child(new_minion)
			
			# 2. Position in the ring (30px to 60px)
			var angle = randf() * TAU
			var distance = randf_range(30, 60)
			new_minion.global_position = enemy.global_position + (Vector2.from_angle(angle) * distance)
			
			# 3. Force base initialization
			if new_minion.has_method("update_enemy"):
				new_minion.update_enemy()
			
			# 4. THE ULTIMATE TETHER
			var picker: EnemyActionPicker = null
			for child in new_minion.get_children():
				if child is EnemyActionPicker:
					picker = child
					break
			
			if picker:
				picker.enemy = new_minion
				var chosen = picker.get_action()
				if chosen:
					# Force the action into the scene tree so it CANNOT be freed
					if chosen.get_parent():
						chosen.get_parent().remove_child(chosen)
					new_minion.add_child(chosen)
					
					# Link it and update UI
					chosen.enemy = new_minion
					new_minion.current_action = chosen
					new_minion.current_action.update_intent_text()
					if new_minion.get("intent_ui"):
						new_minion.intent_ui.update_intent(chosen.intent)
			
			var turn_func := ""
			var possible_funcs := ["_on_enemy_turn_started", "do_turn", "take_turn", "_on_turn_started"]
			for f in possible_funcs:
				if new_minion.has_method(f):
					turn_func = f
					break
			
			if turn_func != "":
				var callable_func = Callable(new_minion, turn_func)
				for s in Events.get_signal_list():
					var sn = s.name.to_lower()
					if "enemy" in sn and ("turn" in sn or "phase" in sn) and ("start" in sn or "begin" in sn):
						if not Events.is_connected(s.name, callable_func):
							Events.connect(s.name, callable_func)
						break
				
				# Manually trigger the first turn
				new_minion.call_deferred(turn_func)

			# 6. Spawn Animation
			new_minion.scale = Vector2.ZERO
			var spawn_tween = new_minion.create_tween()
			spawn_tween.tween_property(new_minion, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BOUNCE)
	)
	
	tween.tween_property(enemy.sprite_2d, "position:y", enemy.sprite_2d.position.y, 0.2).set_delay(0.2)
	tween.finished.connect(func():
		Events.enemy_action_completed.emit(enemy)
	)
