extends Card

@export var base_damage := 15

func get_default_tooltip() -> String:
	return tooltip_text % base_damage

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var bonus := _get_global_bonus_damage()
	var final_base = base_damage + bonus
	
	var final_damage = modifiers.get_modified_value(final_base, Modifier.Type.DMG_DEALT)
	
	var damage_effect := DamageEffect.new()
	damage_effect.amount = final_damage
	damage_effect.sound = sound
	damage_effect.execute(targets)
