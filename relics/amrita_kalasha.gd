extends Relic

@export var max_hp_bonus := 30
@export var has_triggered := false

func activate_relic(relic_ui: RelicUI) -> void:
	if has_triggered:
		return
		
	var tree = relic_ui.get_tree()
	var player = tree.get_first_node_in_group("player")
	
	if player and player.get("stats"):
		var stats = player.stats
		
		stats.max_health += max_hp_bonus
		stats.health = stats.max_health
		
		has_triggered = true
		
		relic_ui.flash()
		stats.stats_changed.emit()
		print("RELIC: Life Fruit consumed. Max HP permanently increased.")
