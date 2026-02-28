extends Relic

var current_relic_ui: RelicUI

func activate_relic(relic_ui: RelicUI) -> void:
	current_relic_ui = relic_ui
	
	if not Events.player_turn_started.is_connected(_on_turn_started):
		Events.player_turn_started.connect(_on_turn_started)

func _on_turn_started() -> void:
	if not is_instance_valid(current_relic_ui): return
	
	var tree = current_relic_ui.get_tree()
	
	await tree.create_timer(0.5).timeout 
	
	var cards_in_hand = tree.get_nodes_in_group("cards_in_hand") 
	
	print("RELIC: Chaos activated! Found ", cards_in_hand.size(), " cards in hand.")
	
	for card_ui: CardUI in cards_in_hand:
		card_ui.cost_override = randi_range(0, 2)
		card_ui._recheck_playability() 
			
	current_relic_ui.flash()
