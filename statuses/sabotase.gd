class_name SabotageStatus
extends Status


@export var sound: AudioStream 

func apply_status(target: Node) -> void:
	var hand_ui = target.get_tree().get_first_node_in_group("hand")
	if not hand_ui:
		return
		
	await target.get_tree().create_timer(0.7).timeout
	
	var cards_in_hand = hand_ui.get_children()
	if cards_in_hand.is_empty():
		return
		
	var count = mini(stacks, cards_in_hand.size())
	
	for i in range(count):
		if cards_in_hand.is_empty():
			break
			
		var stolen_card = cards_in_hand.pick_random()
		cards_in_hand.erase(stolen_card)
		
		if sound and is_instance_valid(SFXPlayer):
			SFXPlayer.play(sound)
			
		var tween = target.create_tween()
		tween.tween_property(stolen_card, "modulate", Color.BLACK, 0.2)
		tween.parallel().tween_property(stolen_card, "scale", Vector2.ZERO, 0.2)
		tween.tween_callback(stolen_card.queue_free)
	
	if Shaker:
		Shaker.shake(target, 6, 0.2)
