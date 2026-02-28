extends Relic

@export var card_to_add: Card
@export var amount := 1

func activate_relic(relic_ui: RelicUI) -> void:
	var tree = relic_ui.get_tree()
	
	# Wait for Battle.gd to finish shuffling the opening hand
	await tree.process_frame
	await tree.process_frame
	
	var player = tree.get_first_node_in_group("player")
	
	# 1. Trace Check: Find Player Stats
	if not player or not player.get("stats"):
		print("RELIC ERROR: Could not find Player or CharacterStats!")
		return
		
	var stats = player.stats
	
	# 2. Trace Check: Find the Draw Pile
	if not stats.get("draw_pile"):
		print("RELIC ERROR: CharacterStats does not have a 'draw_pile' variable! Let me know what your deck variable is named.")
		return
		
	# 3. The Injection
	for i in range(amount):
		var temporary_card = card_to_add.duplicate()
		
		# Check how your CardPile resource handles new cards
		if stats.draw_pile.has_method("add_card"):
			stats.draw_pile.add_card(temporary_card)
		elif "cards" in stats.draw_pile:
			stats.draw_pile.cards.append(temporary_card)
			
	# 4. Visuals and Confirmation
	relic_ui.flash()
	print("RELIC SUCCESS: Brahmastra armed! Added %s to the deck." % card_to_add.id)
	
	# 5. Force the UI counters to update
	var battle_ui = tree.get_first_node_in_group("battle_ui") 
	if battle_ui and battle_ui.has_method("initialize_card_pile_ui"):
		battle_ui.initialize_card_pile_ui()
