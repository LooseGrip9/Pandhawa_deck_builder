extends Relic

var attack_played_this_turn := false
var current_relic_ui: RelicUI

func activate_relic(relic_ui: RelicUI) -> void:
	current_relic_ui = relic_ui
	attack_played_this_turn = false
	
	if not Events.card_played.is_connected(_on_card_played):
		Events.card_played.connect(_on_card_played)
	if not Events.player_turn_started.is_connected(_on_turn_started):
		Events.player_turn_started.connect(_on_turn_started)

func _on_turn_started() -> void:
	attack_played_this_turn = false
	print("RELIC: New turn started. First attack will be doubled.")

func _on_card_played(card: Card) -> void:
	if not is_instance_valid(current_relic_ui): return
	
	if card.type == Card.Type.ATTACK and not attack_played_this_turn:
		attack_played_this_turn = true
		print("RELIC: First attack detected! Playing %s twice." % card.id)
		
		current_relic_ui.flash()
		
		var tree = current_relic_ui.get_tree()
		var timer = tree.create_timer(0.3)
		timer.timeout.connect(_play_card_again.bind(card))

func _play_card_again(card: Card) -> void:
	var tree = Engine.get_main_loop()
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	var targets: Array[Node] = []
	var enemies = tree.get_nodes_in_group("enemies")
	var player = tree.get_first_node_in_group("player")
	
	if card.target == Card.Target.SINGLE_ENEMY:
		if not enemies.is_empty():
			targets.append(enemies[0])
	else:
		targets = card._get_targets(enemies if not enemies.is_empty() else [player])

	if player and player.get("modifier_handler"):
		card.apply_effects(targets, player.modifier_handler)
