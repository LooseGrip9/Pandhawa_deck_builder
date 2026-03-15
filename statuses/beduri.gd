class_name StatusBerduri
extends Status

func get_tooltip() -> String:
	return "Darah Kurawa: Setiap kali menerima damage, memberikan %d damage kembali ke penyerang." % stacks

func initialize_status(_target: Node) -> void:
	if not _target.damaged.is_connected(_on_damaged.bind(_target)):
		_target.damaged.connect(_on_damaged.bind(_target))

func _on_damaged(_amount: int, _target: Node) -> void:
	var player = _target.get_tree().get_first_node_in_group("player")
	if player and player.has_method("take_damage"):
		print("Phase 3 Thorns triggered! Dealing %d damage to player." % stacks)
		
		if _target.get("sprite_2d"):
			var tween = _target.create_tween()
			tween.tween_property(_target.get("sprite_2d"), "modulate", Color.RED, 0.1)
			tween.tween_property(_target.get("sprite_2d"), "modulate", Color.WHITE, 0.1)
		
		player.take_damage(stacks, Modifier.Type.NO_MODIFIER)

func clear_status(_target: Node) -> void:
	if _target.damaged.is_connected(_on_damaged.bind(_target)):
		_target.damaged.disconnect(_on_damaged.bind(_target))
