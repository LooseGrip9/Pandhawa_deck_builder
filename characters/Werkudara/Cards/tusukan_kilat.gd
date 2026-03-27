extends Card

@export var optional_sound: AudioStream
@export var damage := 4
var used_this_turn := false

func get_default_tooltip() -> String:
	return tooltip_text


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in targets:
		if target is Enemy:
			target.take_damage(damage, Modifier.Type.NO_MODIFIER)
	
	if not used_this_turn:
		used_this_turn = true
		
		var tree = targets[0].get_tree()
		var player_handler = tree.get_first_node_in_group("player_handler")
		
		if player_handler:
			_return_to_hand.call_deferred(player_handler)

func _return_to_hand(player_handler: PlayerHandler) -> void:
	player_handler.hand.add_card(self)
	
	if not Events.player_hand_drawn.is_connected(_reset_usage):
		Events.player_hand_drawn.connect(_reset_usage)

func _reset_usage() -> void:
	used_this_turn = false
