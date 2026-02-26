extends Relic

@export var bonus_draw := 1

func activate_relic(relic_ui: RelicUI) -> void:
	print("--- RELIC SCRIPT EXECUTING ---")
	
	# 1. Find the Player node using the group (We know this works!)
	var player = relic_ui.get_tree().get_first_node_in_group("player")
	if not player:
		print("ERROR: Relic could not find player node!")
		return
		
	# 2. The Battle node is the parent of the Player node
	var battle = player.get_parent()
	
	# 3. Access the PlayerHandler and add the bonus
	if battle and "player_handler" in battle:
		battle.player_handler.extra_draws_this_turn += bonus_draw
		relic_ui.flash()
		print("SUCCESS: Kipas Ekor Yak added +%d draw. Total bonus is now: %d" % [bonus_draw, battle.player_handler.extra_draws_this_turn])
	else:
		print("ERROR: Found player, but could not find player_handler!")
