extends Card

@export var base_damage := 5

func get_default_tooltip() -> String:
	return tooltip_text % base_damage


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var tree: SceneTree = null
	if not targets.is_empty():
		tree = targets[0].get_tree()
	
	if not tree: 
		return

	var handler = tree.get_first_node_in_group("player_handler") as PlayerHandler

	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	
	var tween = tree.create_tween()
	
	tween.tween_callback(damage_effect.execute.bind(targets))
	tween.tween_interval(0.2)
	
	if handler:
		tween.tween_callback(handler.draw_cards.bind(1))
