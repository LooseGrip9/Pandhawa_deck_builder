extends Relic

@export var bonus_draw := 1

func activate_relic(relic_ui: RelicUI) -> void:
	var tree := relic_ui.get_tree()
	if not tree: return
	
	var player = tree.get_first_node_in_group("player")
	
	if not is_instance_valid(player):
		return
		
	var battle = player.get_parent()
	
	if is_instance_valid(battle) and is_instance_valid(battle.get("player_handler")):
		var handler = battle.player_handler
		if is_instance_valid(handler) and "extra_draws_this_turn" in handler:
			handler.extra_draws_this_turn += bonus_draw
			relic_ui.flash()
			print("SUCCESS: Kipas Ekor Yak added draw.")
