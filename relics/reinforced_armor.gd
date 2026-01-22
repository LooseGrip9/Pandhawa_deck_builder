extends Relic

@export var block_bonus := 3

func activate_relic(_owner: RelicUI) -> void:
	var player := _owner.get_tree().get_nodes_in_group("player")
	var block_effect := BlockEffect.new()
	block_effect.amount = block_bonus
	block_effect.execute(player)
	
	_owner.flash()
