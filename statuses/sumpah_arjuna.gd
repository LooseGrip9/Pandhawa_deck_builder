class_name StatusSumpahArjuna
extends Status

func get_tooltip() -> String:
	return "Sumpah Matahari Tenggelam: Jika Jayadrata tidak dikalahkan dalam %d giliran, Arjuna akan membakar dirinya sendiri (Kalah)." % stacks

func initialize_status(_target: Node) -> void:
	if not Events.player_turn_ended.is_connected(_on_turn_ended.bind(_target)):
		Events.player_turn_ended.connect(_on_turn_ended.bind(_target))

func _on_turn_ended(_target: Node) -> void:
	stacks -= 1
	
	var handler = _target.get_node_or_null("StatusHandler")
	if handler:
		handler.statuses_changed.emit()
	
	print("Matahari semakin tenggelam... Sisa waktu: ", stacks, " giliran.")
	
	if stacks <= 0:
		_trigger_sunset(_target)

func _trigger_sunset(_target: Node) -> void:
	print("MATAHARI TENGGELAM! Arjuna gagal memenuhi sumpahnya!")
	
	var player = _target.get_tree().get_first_node_in_group("player")
	if player and player.has_method("take_damage"):
		
		Shaker.shake(player, 30.0, 1.0)
		if player.get("sprite_2d"):
			var tween = player.create_tween()
			tween.tween_property(player.sprite_2d, "modulate", Color.ORANGE_RED, 0.2)
			tween.tween_property(player.sprite_2d, "modulate", Color.RED, 0.2)
			tween.tween_property(player.sprite_2d, "modulate", Color.BLACK, 0.5)
		
		_target.get_tree().create_timer(0.4).timeout.connect(
			func(): player.take_damage(999, Modifier.Type.NO_MODIFIER)
		)

func clear_status(_target: Node) -> void:
	if Events.player_turn_ended.is_connected(_on_turn_ended.bind(_target)):
		Events.player_turn_ended.disconnect(_on_turn_ended.bind(_target))
