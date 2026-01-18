#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

const LEMAH_STATUS = preload("res://statuses/lemah.tres")

var base_damage := 12
var lemah_duration := 2

@export var optional_sound: AudioStream
@export var self_damage_amount: int = 4

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var damage_effect = DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
	if targets.size() > 0:
		var tree = targets[0].get_tree()
		
		var player_targets = tree.get_nodes_in_group("player")
		
		if player_targets.size() > 0:
			var self_damage = DamageEffect.new()
			self_damage.amount = self_damage_amount
			self_damage.execute(player_targets)
	
	var status_effect := StatusEffect.new()
	var lemah := LEMAH_STATUS.duplicate()
	lemah.duration = lemah_duration
	status_effect.status = lemah
	status_effect.execute(targets)
