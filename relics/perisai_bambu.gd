extends Relic

@export var block_bonus := 4

func activate_relic(owner: RelicUI) -> void:
	var player_nodes = owner.get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty(): return
		
	var block_effect := BlockEffect.new()
	block_effect.amount = block_bonus
	block_effect.execute(player_nodes)
	
	owner.flash()
