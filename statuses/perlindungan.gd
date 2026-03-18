class_name StatusShivasBoon
extends Status

func get_tooltip() -> String:
	return "Shiva's Boon: Selama ada prajurit yang hidup, damage yang diterima akan dialihkan ke prajurit."

func initialize_status(_target: Node) -> void:
	if not _target.damaged.is_connected(_on_damaged.bind(_target)):
		_target.damaged.connect(_on_damaged.bind(_target))

func _on_damaged(_amount: int, _target: Node) -> void:
	var allies = []
	var current_enemies = _target.get_tree().get_nodes_in_group("enemies")

	for entity in current_enemies:
		if entity != _target and not entity.is_queued_for_deletion():
			if entity.get("stats") and entity.stats.health > 0:
				allies.append(entity)
				
	if allies.size() > 0:
		var meat_shield = allies.pick_random()
		print("Shiva's Boon triggered! Deflecting %d damage to %s." % [_amount, meat_shield.name])
		
		if _target.get("sprite_2d"):
			var tween = _target.create_tween()
			tween.tween_property(_target.get("sprite_2d"), "modulate", Color(0.8, 0.8, 0.8), 0.1)
			tween.tween_property(_target.get("sprite_2d"), "modulate", Color.WHITE, 0.1)

		if _target.has_method("heal"):
			_target.heal(_amount)
		elif _target.get("stats") and _target.stats.has_method("heal"):
			_target.stats.heal(_amount)
		else:
			_target.stats.health += _amount

		if meat_shield.has_method("take_damage"):
			meat_shield.take_damage(_amount, Modifier.Type.NO_MODIFIER)

func clear_status(_target: Node) -> void:
	if _target.damaged.is_connected(_on_damaged.bind(_target)):
		_target.damaged.disconnect(_on_damaged.bind(_target))
