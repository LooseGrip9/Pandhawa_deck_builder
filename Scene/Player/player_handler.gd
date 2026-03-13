class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var player: Player
@export var relics: RelicHandler
@onready var hand: Hand = $"../BattleUI/Hand"


var extra_draws_this_turn := 0
var character: CharacterStats
var pending_energy := 0
var turns_locked := 0
var cards_played_this_turn := 0 
var retain_hand_once := false
var is_first_turn := true
var next_card_is_free: bool = false
var next_attack_doubled: bool = false
var last_played_attack: Card = null

func _ready() -> void:
	Events.card_played.connect(_on_card_played)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	
	# 1. ADD THIS LINE: Listen for Sengkuni's lies
	Events.card_added_to_deck.connect(_on_card_added_to_deck)
	
	Events.energy_gain_requested.connect(
		func(amt):
			pending_energy += amt)

func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.duplicate(true)
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	
	character.block = 0
	is_first_turn = true
	
	relics.relics_activated.connect(_on_relics_activated)
	player.status_handler.statuses_applied.connect(_on_statuses_applied)

func start_turn() -> void:
	cards_played_this_turn = 0 
	
	if player:
		player.has_taken_damage_this_turn = false
	
	character.counter_damage = 0
	
	if not is_first_turn:
		character.block = 0
		
	is_first_turn = false
	
	character.stats_changed.emit()
	
	character.reset_mana()
	character.mana += pending_energy
	pending_energy = 0
	
	
	if turns_locked > 0:
		hand.disable_hand()
		hand.modulate = Color(0.5, 0.5, 0.5, 1.0)
		print("Locked Turn! Remaining after this: ", turns_locked - 1)
		turns_locked -= 1 
	else:
		hand.enable_hand()
		hand.modulate = Color.WHITE
	
	relics.activate_relics_by_type(Relic.Type.START_OF_TURN)
	player.status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)

func _on_player_hand_drawn() -> void:
	if hand.modulate != Color.WHITE:
		hand.disable_hand()
		print("Enforcing lock on newly drawn cards.")
	else:
		hand.enable_hand()

func end_turn() -> void:
	hand.disable_hand()
	relics.activate_relics_by_type(Relic.Type.END_OF_TURN)
	player.status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)

func draw_card() -> void:
	reshuffle_deck_from_discard()
	
	var card = character.draw_pile.draw_card()
	if card:
		if card.get("id") == "Fitnah":
			character.take_damage(3)
			
			var player_sprite = player.get_node("Sprite2D")
			var damage_tween = create_tween()
			damage_tween.tween_property(player_sprite, "modulate", Color.RED, 0.1)
			damage_tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.1)
			
			Shaker.shake(player, 15, 0.2)
			
			var boss = get_tree().get_first_node_in_group("boss")
			if boss and boss.has_method("say_something"):
				boss.say_something("Makan itu fitnah!")
		
		hand.add_card(card)

func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit()
	)

func _on_card_added_to_deck(card: Card) -> void:
	if not character:
		return

	var card_to_add = card.duplicate()
	character.draw_pile.add_card(card_to_add)
	character.draw_pile.shuffle()
	print("DECK UPDATED: Added ", card.id, " to draw pile. New total: ", character.draw_pile.cards.size())

func discard_cards() -> void:
	if retain_hand_once:
		retain_hand_once = false 
		Events.player_hand_discarded.emit()
		return

	if hand.get_child_count() == 0:
		Events.player_hand_discarded.emit()
		return
		
	var tween := create_tween()
	for card_ui in hand.get_children():
		if card_ui.card.get("id") == "Fitnah":
			tween.tween_callback(
				func(): 
					print("Sengkuni's lies fade away... (Exhausted)")
					card_ui.queue_free()
			)
		else:
			tween.tween_callback(character.discard.add_card.bind(card_ui.card))
			tween.tween_callback(hand.discard_card.bind(card_ui))
		
		tween.tween_interval(HAND_DISCARD_INTERVAL)
		
	tween.finished.connect(
		func():
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
	
	var cards_in_hand := hand.get_children()
	for card_ui in cards_in_hand:
		character.draw_pile.add_card(card_ui.card)
		card_ui.queue_free()
	
	character.draw_pile.shuffle()
	
	get_tree().create_timer(0.1).timeout.connect(func():
		draw_cards(cards_to_draw)
	)

func _on_card_played(card: Card) -> void:
	var snare_tax := 0
	for status in player.status_handler.get_statuses():
		if status is StatusJeratSengkuni:
			snare_tax += status.get_extra_cost(card)
	
	if snare_tax > 0 and not next_card_is_free:
		character.mana -= snare_tax
		print("Mana terjerat: ", snare_tax)

	cards_played_this_turn += 1
	
	if card.type == Card.Type.ATTACK:
		last_played_attack = card
	
	if card.get("used_this_turn") == true:
		return 
	
	if card.exhausts or card.type == Card.Type.POWER:
		return
	
	character.discard.add_card(card)

func _on_statuses_applied(type: Status.Type) -> void:
	match type:
		Status.Type.START_OF_TURN:
			var total_to_draw = character.cards_per_turn + extra_draws_this_turn
			
			draw_cards(total_to_draw)
			
			extra_draws_this_turn = 0
			
		Status.Type.END_OF_TURN:
			discard_cards()

func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_TURN:
			pass
		Relic.Type.END_OF_TURN:
			pass
