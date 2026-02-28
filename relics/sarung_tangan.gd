extends Relic

var attack_count := 0
var current_relic_ui: RelicUI

func activate_relic(relic_ui: RelicUI) -> void:
	current_relic_ui = relic_ui
	attack_count = 0
	
	if not Events.card_played.is_connected(_on_card_played):
		Events.card_played.connect(_on_card_played)
	if not Events.player_turn_ended.is_connected(_on_turn_ended):
		Events.player_turn_ended.connect(_on_turn_ended)

func _on_card_played(card: Card) -> void:
	if not is_instance_valid(current_relic_ui): return

	if card.type == Card.Type.ATTACK:
		attack_count += 1
		
		if attack_count == 2:
			_set_double_damage_flag(true)
			current_relic_ui.flash()
		
		elif attack_count >= 3:
			attack_count = 0
			_set_double_damage_flag(false)

func _on_turn_ended() -> void:
	attack_count = 0
	_set_double_damage_flag(false)

func _set_double_damage_flag(active: bool) -> void:
	var player_handler = current_relic_ui.get_tree().get_first_node_in_group("player_handler")
	if player_handler:
		player_handler.next_attack_doubled = active
		var tree = Engine.get_main_loop()
		var player = tree.get_first_node_in_group("player")
		if player and player.get("stats"):
			player.stats.stats_changed.emit()
