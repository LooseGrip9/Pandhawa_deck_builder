extends Card

@export var optional_sound: AudioStream
@export var damage := 4
var used_this_turn := false

func get_default_tooltip() -> String:
	return tooltip_text


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	# 1. Standard Damage Logic
	for target in targets:
		if target is Enemy:
			target.take_damage(damage, Modifier.Type.NO_MODIFIER)
	
	# 2. Return to Hand Logic
	if not used_this_turn:
		used_this_turn = true
		
		# We find the PlayerHandler to trigger a special draw
		var tree = targets[0].get_tree()
		var player_handler = tree.get_first_node_in_group("player_handler")
		
		if player_handler:
			# We call a deferred function to add it back 
			# so it doesn't vanish while the current 'play' logic is finishing
			_return_to_hand.call_deferred(player_handler)

func _return_to_hand(player_handler: PlayerHandler) -> void:
	player_handler.hand.add_card(self)
	
	# Connect to the reset signal if not already connected
	if not Events.player_hand_drawn.is_connected(_reset_usage):
		Events.player_hand_drawn.connect(_reset_usage)

func _reset_usage() -> void:
	used_this_turn = false
