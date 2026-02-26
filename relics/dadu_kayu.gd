extends Relic

@export var damage := 3

func activate_relic(owner: RelicUI) -> void:
	var enemies := owner.get_tree().get_nodes_in_group("enemies")
	
	if enemies.is_empty():
		return
		
	var target = enemies.pick_random()
	
	var damage_effect := DamageEffect.new()
	damage_effect.amount = damage
	damage_effect.receiver_modifier_type = Modifier.Type.NO_MODIFIER
	
	damage_effect.execute([target])
	
	owner.flash()
