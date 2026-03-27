extends Card

@export var optional_sound: AudioStream

const PLATED_ARMOR_STATUS = preload("res://statuses/lempeng_zirah.tres")

@export var armor_amount := 4

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var tree = _targets[0].get_tree() if _targets.size() > 0 else Engine.get_main_loop()
	var player_nodes = tree.get_nodes_in_group("player")
	
	if player_nodes.is_empty():
		return
		
	var player = player_nodes[0]
	var target_array: Array[Node] = [player]
	
	var armor_effect := StatusEffect.new()
	var armor := PLATED_ARMOR_STATUS.duplicate()
	

	armor.stacks = armor_amount 
	
	armor_effect.status = armor
	armor_effect.execute(target_array)
