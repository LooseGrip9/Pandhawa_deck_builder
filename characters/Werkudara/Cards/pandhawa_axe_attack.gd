extends Card

var base_damage := 6

func get_default_tooltip() -> String:
	return tooltip_text % base_damage


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var bonus := 0
	var main_scene = Engine.get_main_loop().current_scene
	if "stats" in main_scene and main_scene.stats:
		bonus = main_scene.stats.bonus_damage

	var damage_effect := DamageEffect.new()
	# Add the bonus to the base damage BEFORE modifiers are calculated
	var final_base = base_damage + bonus
	damage_effect.amount = modifiers.get_modified_value(final_base, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
