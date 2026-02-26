# small_conch.gd
extends Relic

var cards_played_this_turn := 0
var current_relic_ui: RelicUI

func activate_relic(relic_ui: RelicUI) -> void:
	current_relic_ui = relic_ui
	cards_played_this_turn = 0
	
	if not Events.card_played.is_connected(_on_card_played):
		Events.card_played.connect(_on_card_played)
	if not Events.player_turn_ended.is_connected(_on_turn_ended):
		Events.player_turn_ended.connect(_on_turn_ended)


func _on_card_played(_card: Card) -> void:
	if not is_instance_valid(current_relic_ui): return

	cards_played_this_turn += 1
	
	if cards_played_this_turn == 4:
		_set_free_card_flag(true)
		current_relic_ui.flash()
		
	elif cards_played_this_turn >= 5:
		cards_played_this_turn = 0

func _on_turn_ended() -> void:
	cards_played_this_turn = 0
	_set_free_card_flag(false)

func _set_free_card_flag(is_free: bool) -> void:
	var tree = Engine.get_main_loop()
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	if player_handler:
		player_handler.next_card_is_free = is_free
		
		# Force the UI to refresh so you can see if the card is playable
		var player = tree.get_first_node_in_group("player")
		if player and player.stats:
			player.stats.stats_changed.emit()
			player.stats.stats_changed.emit()

func char_stats_changed_manually() -> void:
	var tree = Engine.get_main_loop()
	var player = tree.get_first_node_in_group("player")
	if player and player.get("stats"):
		player.stats.stats_changed.emit()
