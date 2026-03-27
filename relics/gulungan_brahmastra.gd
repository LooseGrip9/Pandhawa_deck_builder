extends Relic

@export var card_to_add: Card
@export var amount := 1

func activate_relic(relic_ui: RelicUI) -> void:
	var tree = relic_ui.get_tree()
	
	await tree.process_frame
	await tree.process_frame
	
	var player = tree.get_first_node_in_group("player")
	
	if not player or not player.get("stats"):
		print("RELIC ERROR: Could not find Player or CharacterStats!")
		return
		
	var stats = player.stats
	
	if not stats.get("draw_pile"):
		print("RELIC ERROR: CharacterStats does not have a 'draw_pile' variable!")
		return
		
	for i in range(amount):
		var temporary_card = card_to_add.duplicate()
		
		if stats.draw_pile.has_method("add_card"):
			stats.draw_pile.add_card(temporary_card)
		elif "cards" in stats.draw_pile:
			stats.draw_pile.cards.append(temporary_card)
			
	relic_ui.flash()
	print("RELIC SUCCESS: Brahmastra armed! Added %s to the deck." % card_to_add.id)
	
	var battle_ui = tree.get_first_node_in_group("battle_ui") 
	if battle_ui and battle_ui.has_method("initialize_card_pile_ui"):
		battle_ui.initialize_card_pile_ui()
