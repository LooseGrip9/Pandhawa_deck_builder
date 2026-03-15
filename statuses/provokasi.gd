class_name StatusProvokasi
extends Status

@export var kuat_status: Status

func initialize_status(_target: Node) -> void:
	if not Events.card_played.is_connected(_on_card_played.bind(_target)):
		Events.card_played.connect(_on_card_played.bind(_target))

func _on_card_played(card: Card, _target: Node) -> void:
	if card.type == Card.Type.SKILL:
		_apply_kuat(_target)

func _apply_kuat(_target: Node) -> void:
	var handler = _target.get_node_or_null("StatusHandler")
	if handler and handler.has_method("add_status") and kuat_status:
		
		var new_kuat = kuat_status.duplicate() as Status
		new_kuat.stacks = 1
		handler.add_status(new_kuat)
		
		if _target.get("sprite_2d"):
			var tween = _target.create_tween()
			tween.tween_property(_target.get("sprite_2d"), "modulate", Color.RED, 0.1)
			tween.tween_property(_target.get("sprite_2d"), "modulate", Color.WHITE, 0.2)
			
		print("Player blocked! Dursasana gained Kuat.")

func clear_status(_target: Node) -> void:
	if Events.card_played.is_connected(_on_card_played.bind(_target)):
		Events.card_played.disconnect(_on_card_played.bind(_target))
