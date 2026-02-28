extends Card

var base_damage := 4

func get_default_tooltip() -> String:
	return tooltip_text % base_damage

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var scene_root = targets[0].get_tree() if not targets.is_empty() else null
	if not scene_root:
		return

	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	
	var tween = scene_root.create_tween()
	
	for i in 2:
		tween.tween_callback(damage_effect.execute.bind(targets))
		tween.tween_interval(0.2)
