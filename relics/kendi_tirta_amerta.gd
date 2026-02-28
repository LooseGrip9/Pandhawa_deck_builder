extends Relic

@export var bonus_mana := 3

func activate_relic(relic_ui: RelicUI) -> void:
	var tree = relic_ui.get_tree()
	
	await tree.process_frame
	await tree.process_frame
	
	var player = tree.get_first_node_in_group("player")
	
	if player and player.get("stats"):
		player.stats.mana += bonus_mana
		
		relic_ui.flash()
		player.stats.stats_changed.emit()
