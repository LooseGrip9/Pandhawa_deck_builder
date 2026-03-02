extends Relic

var has_triggered_this_turn := false
var current_relic_ui: RelicUI

func activate_relic(relic_ui: RelicUI) -> void:
	current_relic_ui = relic_ui
	has_triggered_this_turn = false
	
	if not Events.player_turn_started.is_connected(_on_turn_started):
		Events.player_turn_started.connect(_on_turn_started)
		
	if not Events.card_played.is_connected(_on_card_played):
		Events.card_played.connect(_on_card_played)

func _on_turn_started() -> void:
	has_triggered_this_turn = false

func _on_card_played(card: Card) -> void:
	if has_triggered_this_turn: return
	if not is_instance_valid(current_relic_ui): return
	
	if card.type != Card.Type.ATTACK: 
		return 
		
	if card.cost != 0: 
		return 
		
	var tree = current_relic_ui.get_tree()
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	if player_handler:
		if player_handler.has_method("draw_cards"):
			player_handler.draw_cards(1)
		elif player_handler.has_method("draw_card"):
			player_handler.draw_card()
			
		has_triggered_this_turn = true
		current_relic_ui.flash()
