extends Relic

# Using preload is the safest way to guarantee the resource loads
var status_to_apply: Status = preload("res://statuses/lemah.tres")
@export var stacks := 1

func activate_relic(relic_ui: RelicUI) -> void:
	print("--- LEMAH RELIC EXECUTING ---")
	
	# 1. Find the player to anchor ourselves in the scene tree
	var player = relic_ui.get_tree().get_first_node_in_group("player")
	if not player:
		print("ERROR: Lemah Relic could not find player node!")
		return
		
	# 2. The Battle node is the parent of the Player
	var battle = player.get_parent()
	
	# 3. Find the EnemyHandler and loop through the enemies
	if battle and "enemy_handler" in battle:
		var enemies = battle.enemy_handler.get_children()
		print("DEBUG: Lemah Relic found %d enemies." % enemies.size())
		
		var applied_successfully = false
		for enemy in enemies:
			if is_instance_valid(enemy) and enemy.get("status_handler") and status_to_apply:
				var new_status = status_to_apply.duplicate()
				new_status.stacks = stacks
				enemy.status_handler.add_status(new_status)
				applied_successfully = true
				print("DEBUG: Applied Lemah to %s" % enemy.name)
				
		if applied_successfully:
			relic_ui.flash()
	else:
		print("ERROR: Found battle node, but no enemy_handler inside it!")
