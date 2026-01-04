#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

@export var optional_sound: AudioStream
@export var self_damage_amount: int = 5

func apply_effects(targets: Array[Node]) -> void:
	var damage_effect = DamageEffect.new()
	damage_effect.amount = 12
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
	if targets.size() > 0:
		var tree = targets[0].get_tree()
		
		var player_targets = tree.get_nodes_in_group("player")
		
		if player_targets.size() > 0:
			var self_damage = DamageEffect.new()
			self_damage.amount = self_damage_amount
			self_damage.execute(player_targets)
