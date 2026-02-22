#meta-name: Card Logic
extends Card

# Point these directly to your actual resource files
const KYAT_STATUS = preload("res://statuses/kyat.tres")
const TANGKAS_STATUS = preload("res://statuses/tangkas.tres")

@export var buff_amount := 1

func get_default_tooltip() -> String:
	return tooltip_text % buff_amount

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % buff_amount

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	# 1. Find the player
	var tree = _targets[0].get_tree() if _targets.size() > 0 else Engine.get_main_loop()
	var player_nodes = tree.get_nodes_in_group("player")
	
	if player_nodes.is_empty():
		return
		
	var player = player_nodes[0]
	var target_array: Array[Node] = [player]
	
	# 2. Apply Kyat (Strength) to the Player
	var kyat_effect := StatusEffect.new()
	var kyat := KYAT_STATUS.duplicate()
	kyat.stacks = buff_amount 
	kyat_effect.status = kyat
	kyat_effect.execute(target_array)
	
	# 3. Apply Tangkas (Dexterity) to the Player
	var tangkas_effect := StatusEffect.new()
	var tangkas := TANGKAS_STATUS.duplicate()
	tangkas.stacks = buff_amount 
	tangkas_effect.status = tangkas
	tangkas_effect.execute(target_array)
