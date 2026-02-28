extends Relic

@export var heal_amount := 4
var current_relic_ui: RelicUI

func activate_relic(relic_ui: RelicUI) -> void:
	current_relic_ui = relic_ui
	
	if not Events.enemy_died.is_connected(_on_enemy_died):
		Events.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(_enemy: Enemy) -> void:
	if not is_instance_valid(current_relic_ui): return
	
	var tree = current_relic_ui.get_tree()
	var player = tree.get_first_node_in_group("player")
	
	if player and player.get("stats"):
		player.stats.health += heal_amount
		
		if player.stats.get("max_health"):
			player.stats.health = min(player.stats.health, player.stats.max_health)
		
		current_relic_ui.flash()
		player.stats.stats_changed.emit()
		print("RELIC: Life Steal! Current Health: ", player.stats.health)
