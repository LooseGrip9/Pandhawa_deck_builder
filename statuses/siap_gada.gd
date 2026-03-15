class_name StatusMengisiGada
extends Status

@export var rentan_status: Status

var attacks_played := 0

func get_tooltip() -> String:
	return "Mengisi Gada: Akan melancarkan Kiamat Gada giliran depan! (Terima %d/3 Serangan untuk membatalkan)" % attacks_played

func initialize_status(_target: Node) -> void:
	attacks_played = 0
	if not Events.card_played.is_connected(_on_card_played.bind(_target)):
		Events.card_played.connect(_on_card_played.bind(_target))

func _on_card_played(card: Card, _target: Node) -> void:
	if card.type == Card.Type.ATTACK:
		attacks_played += 1
		print("Duryudana hit during charge! Attack count: ", attacks_played)
		
		if attacks_played >= 3:
			_break_stance(_target)

func _break_stance(_target: Node) -> void:
	print("STANCE BROKEN! Duryudana's attack was canceled!")
	var handler = _target.get_node_or_null("StatusHandler")
	
	if _target.get("sprite_2d"):
		var tween = _target.create_tween()
		tween.tween_property(_target.get("sprite_2d"), "modulate", Color.YELLOW, 0.2)
		tween.tween_property(_target.get("sprite_2d"), "modulate", Color.WHITE, 0.2)
		Shaker.shake(_target, 20.0, 0.5)
	
	if handler and rentan_status:
		var new_rentan = rentan_status.duplicate() as Status
		new_rentan.stacks = 2 
		handler.add_status(new_rentan)
		
	if handler:
		for child in handler.get_children():
			var data = child.get("status")
			if data and data.id == self.id:
				child.queue_free()

func clear_status(_target: Node) -> void:
	if Events.card_played.is_connected(_on_card_played.bind(_target)):
		Events.card_played.disconnect(_on_card_played.bind(_target))
