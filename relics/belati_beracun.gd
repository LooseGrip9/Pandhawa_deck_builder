extends Relic

@export var poison_amount := 3
@export var poison_status_res: PoisonStatus

func activate_relic(relic_ui: RelicUI) -> void:
	var tree = relic_ui.get_tree()
	var enemies = tree.get_nodes_in_group("enemies")
	
	for enemy in enemies:
		var status_handler = enemy.get_node_or_null("StatusHandler")
		
		if status_handler and poison_status_res:
			var poison = poison_status_res.duplicate() 
			poison.stacks = poison_amount
			
			status_handler.add_status(poison)
	
	relic_ui.flash()
	print("POISON RELIC: Applied 3 poison to all enemies.")
