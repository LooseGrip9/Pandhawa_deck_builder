extends Card

var _last_execution_frame: int = -1
@export var energy_gain := 2

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var current_frame = Engine.get_process_frames()
	if current_frame == _last_execution_frame:
		return
	_last_execution_frame = current_frame

	var tree := Engine.get_main_loop() as SceneTree
	var player_handler = tree.get_first_node_in_group("player_handler")
	var hand_node = tree.get_first_node_in_group("hand")
	
	if player_handler and player_handler.character:
		player_handler.character.mana += energy_gain
		player_handler.character.stats_changed.emit()

	if not hand_node:
		return
		
	var valid_cards = []
	for child in hand_node.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			if "card" in child and child.card != self:
				valid_cards.append(child)
				
	if valid_cards.size() > 0:
		var card_to_exhaust = valid_cards.pick_random()
		card_to_exhaust.call_deferred("queue_free")
