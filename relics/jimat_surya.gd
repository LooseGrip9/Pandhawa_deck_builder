extends Relic

@export var initial_kyat := 1
@export var kyat_status_res: KyatStatus # Drag your kyat_status.tres here [cite: 2026-02-12]

func activate_relic(relic_ui: RelicUI) -> void:
	var tree = relic_ui.get_tree()
	var player = tree.get_first_node_in_group("player")
	
	if player:
		var status_handler = player.get_node_or_null("StatusHandler")
		
		if status_handler and kyat_status_res:
			var kyat = kyat_status_res.duplicate()
			kyat.stacks = initial_kyat
			
			status_handler.add_status(kyat)
	
	relic_ui.flash()
	print("RELIC: Start of combat Kyat applied (+%d Damage)." % initial_kyat)
