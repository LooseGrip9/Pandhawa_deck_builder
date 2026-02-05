class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var player: Player
@export var relics: RelicHandler
@onready var hand: Hand = $"../BattleUI/Hand"

var character: CharacterStats
var pending_energy := 0

func _ready() -> void:
	Events.card_played.connect(_on_card_played)
	Events.energy_gain_requested.connect(
		func(amt):
			pending_energy += amt)

func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.duplicate(true)
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	relics.relics_activated.connect(_on_relics_activated)
	player.status_handler.statuses_applied.connect(_on_statuses_applied)
	start_turn()

func start_turn() -> void:
	character.counter_damage = 0
	character.block = 0
	character.stats_changed.emit()
	
	character.reset_mana()
	
	character.mana += pending_energy
	pending_energy = 0
	
	relics.activate_relics_by_type(Relic.Type.START_OF_TURN)
	player.status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)

func end_turn() -> void:
	hand.disable_hand()
	relics.activate_relics_by_type(Relic.Type.END_OF_TURN)
	player.status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)

func draw_card() -> void:
	reshuffle_deck_from_discard()
	
	var card = character.draw_pile.draw_card()
	if card:
		hand.add_card(card)

func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit()
	)

func discard_cards() -> void:
	if hand.get_child_count() == 0:
		Events.player_hand_discarded.emit()
		return
		
	var tween := create_tween()
	for card_ui in hand.get_children():
		tween.tween_callback(character.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
		
	tween.finished.connect(
		func():
			print("DEBUG: Hand Discarded. Signal Emitting.")
			Events.player_hand_discarded.emit()
	)

func reshuffle_deck_from_discard() -> void:
	if not character.draw_pile.empty():
		return
	
	while not character.discard.empty():
		character.draw_pile.add_card(character.discard.draw_card())
	
	character.draw_pile.shuffle()

func redraw_hand(amount: int = 0) -> void:
	var cards_to_draw := amount if amount > 0 else character.cards_per_turn
	
	# 2. Move current hand to draw pile
	var cards_in_hand := hand.get_children()
	for card_ui in cards_in_hand:
		character.draw_pile.add_card(card_ui.card)
		card_ui.queue_free()
	
	# 3. Shuffle (using your custom method)
	character.draw_pile.shuffle()
	
	# 4. Draw the new cards
	# We use a small timer or 'call_deferred' to ensure queue_free has finished
	get_tree().create_timer(0.1).timeout.connect(func():
		draw_cards(cards_to_draw)
	)

func _on_card_played(card: Card) -> void:
	if card.exhausts or card.type == Card.Type.POWER:
		return
	
	character.discard.add_card(card)

func _on_statuses_applied(type: Status.Type) -> void:
	match type:
		Status.Type.START_OF_TURN:
			draw_cards(character.cards_per_turn)
		Status.Type.END_OF_TURN:
			discard_cards()

func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_TURN:
			pass
		Relic.Type.END_OF_TURN:
			pass
