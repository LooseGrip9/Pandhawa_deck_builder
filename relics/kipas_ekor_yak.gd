extends Relic

@export var bonus_draw := 1

func activate_relic(relic_ui: RelicUI) -> void:
	print("--- RELIC SCRIPT EXECUTING ---")
	
	var player = relic_ui.get_tree().get_first_node_in_group("player")
	if not player:
		print("ERROR: Relic could not find player node!")
		return
		
	var battle = player.get_parent()
	
	if battle and "player_handler" in battle:
		battle.player_handler.extra_draws_this_turn += bonus_draw
		relic_ui.flash()
		print("SUCCESS: Kipas Ekor Yak added +%d draw. Total bonus is now: %d" % [bonus_draw, battle.player_handler.extra_draws_this_turn])
	else:
		print("ERROR: Found player, but could not find player_handler!")
