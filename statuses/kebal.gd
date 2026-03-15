class_name StatusKekebalan
extends Status

func get_tooltip() -> String:
	return "Kekebalan Gandari: Kebal terhadap semua serangan (Menerima 0 Damage) selama ada Prajurit Kurawa yang hidup."

func initialize_status(_target: Node) -> void:
	Events.enemy_died.connect(_on_enemy_died.bind(_target))

func _on_enemy_died(_dead_enemy: Node, _target: Node) -> void:
	await _target.get_tree().create_timer(0.1).timeout
	
	var enemies = _target.get_tree().get_nodes_in_group("enemies")
	
	var minion_alive = false
	for enemy in enemies:
		if enemy != _target and not enemy.is_queued_for_deletion() and enemy.get("stats") and enemy.stats.health > 0:
			minion_alive = true
			break

	if not minion_alive:
		print("Phase 2! All minions dead! Shattering the Diamond Body!")
		
		var status_handler = _target.get_node_or_null("StatusHandler")
		if status_handler:
			for child in status_handler.get_children():
				var status_data = child.get("status")
				if status_data and status_data.id == "kebal":
					child.queue_free()
			
			if _target.get("sprite_2d"):
				var tween = _target.create_tween()
				tween.tween_property(_target.get("sprite_2d"), "modulate", Color.AQUA, 0.2)
				tween.tween_property(_target.get("sprite_2d"), "modulate", Color.WHITE, 0.2)
