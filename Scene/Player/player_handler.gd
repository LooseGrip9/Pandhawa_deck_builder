class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

# This forces Godot to find the node named "Hand" automatically
@onready var hand: Hand = $"../BattleUI/Hand"

var character: CharacterStats

func _ready() -> void:
	Events.card_played.connect(_on_card_played)

func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.duplicate(true)
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	start_turn()

func start_turn() -> void:
	character.block = 0
	character.reset_mana()
	draw_cards(character.cards_per_turn)

func end_turn() -> void:
	print("DEBUG: Player End Turn Started")
	hand.disable_hand()
	
	discard_cards()

func draw_card() -> void:
	reshuffle_deck_from_discard()
	
	# SAFETY CHECK: Only draw if we actually have cards
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

func _on_card_played(card: Card) -> void:
	character.discard.add_card(card)
