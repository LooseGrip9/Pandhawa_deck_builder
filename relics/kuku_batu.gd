extends Relic

@export var kyat_amount := 2
# Preload your Kyat resource exactly like your 'lemah' example
var kyat_status_to_apply: Status = preload("res://statuses/kyat.tres")

var is_primed := false 
var applied_kyat: Status = null # Track the duplicated resource for cleanup
var current_relic_ui: RelicUI

func activate_relic(relic_ui: RelicUI) -> void:
	current_relic_ui = relic_ui
	is_primed = false
	applied_kyat = null
	
	if not Events.player_turn_ended.is_connected(_on_turn_ended):
		Events.player_turn_ended.connect(_on_turn_ended)
	if not Events.player_turn_started.is_connected(_on_turn_started):
		Events.player_turn_started.connect(_on_turn_started)

func _on_turn_ended() -> void:
	if not is_instance_valid(current_relic_ui): return
	
	var tree = current_relic_ui.get_tree()
	var player = tree.get_first_node_in_group("player")
	if not player: return

	if applied_kyat and player.get("status_handler"):
		if player.status_handler.has_method("remove_status"):
			player.status_handler.remove_status(applied_kyat)
		else:
			applied_kyat.stacks = 0 
			
		applied_kyat = null
		print("RELIC: Turn ended. Tasbih Indrakila Kyat faded.")
		
	if player.get("stats") and player.stats.mana > 0:
		is_primed = true
		current_relic_ui.flash()
		print("RELIC: Unused mana detected! Primed for Kyat next turn.")
	else:
		is_primed = false

func _on_turn_started() -> void:
	if not is_instance_valid(current_relic_ui): return
	if not is_primed: return 
	
	var tree = current_relic_ui.get_tree()
	var player = tree.get_first_node_in_group("player")
	
	if player and player.get("status_handler") and kyat_status_to_apply:
		
		applied_kyat = kyat_status_to_apply.duplicate()
		applied_kyat.stacks = kyat_amount
		
		player.status_handler.add_status(applied_kyat)
			
		is_primed = false 
		current_relic_ui.flash()
		print("RELIC: Tasbih Indrakila complete! Gained %d Kyat." % kyat_amount)
