class_name  BattleReward
extends Control

const CARD_REWARDS = preload("res://Scene/UI/card_rewards.tscn")
const REWARD_BUTTON = preload("res://Scene/UI/reward_button.tscn")
const GOLD_ICON = preload("res://art/gold.png")
const CARD_ICON = preload("res://icon.png")
const GOLD_TEXT = "%s Rupiya"
const CARD_TEXT = "Tambah Kartu Baru"

@export var run_stats: RunStats
@export var character_stats: CharacterStats
@export var relic_handler: RelicHandler

@onready var rewards: VBoxContainer = %Rewards

var card_reward_total_weight := 0.0
var card_rarity_weights := {
	Card.Rarity.COMMON: 0.0,
	Card.Rarity.RARE: 0.0,
	Card.Rarity.SUPER_RARE: 0.0,
}

func _ready() -> void:
	for node: Node in rewards.get_children():
		node.queue_free()

func add_gold_reward(amount: int) -> void:
	var gold_reward := REWARD_BUTTON.instantiate() as RewardButton
	gold_reward.reward_icon = GOLD_ICON
	gold_reward.reward_text = GOLD_TEXT % amount
	gold_reward.pressed.connect(on_gold_reward_taken.bind(amount))
	rewards.add_child.call_deferred(gold_reward)

func add_relic_reward(relic: Relic) -> void:
	var relic_reward := REWARD_BUTTON.instantiate() as RewardButton
	relic_reward.reward_icon = relic.icon
	relic_reward.reward_text = relic.relic_name
	relic_reward.pressed.connect(on_relic_reward_taken.bind(relic))
	rewards.add_child.call_deferred(relic_reward)

func add_card_reward() -> void:
	var card_reward := REWARD_BUTTON.instantiate() as RewardButton
	card_reward.reward_icon = CARD_ICON
	card_reward.reward_text = CARD_TEXT
	card_reward.pressed.connect(_show_card_rewards)
	rewards.add_child.call_deferred(card_reward)

func _show_card_rewards() -> void:
	if not run_stats or not character_stats:
		return
	
	var card_rewards := CARD_REWARDS.instantiate() as CardRewards
	add_child(card_rewards)
	card_rewards.card_reward_selected.connect(_on_card_reward_taken)
	
	var card_reward_array: Array[Card] = []
	var available_cards: Array[Card] = character_stats.draftable_cards.cards.duplicate(true)
	
	for i in run_stats.card_rewards:
		_setup_card_chances()
		var roll := Rng.instance.randf_range(0.0, card_reward_total_weight)
		var accumulated_weight := 0.0 # Track weight progress
		
		for rarity: Card.Rarity in card_rarity_weights:
			var weight: float = card_rarity_weights[rarity]
			accumulated_weight += weight
			if roll <= accumulated_weight:
				_modify_weights(rarity)
				var picked_card := _get_random_available_card(available_cards, rarity)
				
				# Safety check: ensure we actually found a card of that rarity
				if picked_card:
					card_reward_array.append(picked_card)
					available_cards.erase(picked_card)
				
				break # Stop checking rarities, move to next card slot
	
	card_rewards.rewards = card_reward_array
	card_rewards.show()

func _setup_card_chances() -> void:
	card_reward_total_weight = run_stats.common_weight + run_stats.rare_weight + run_stats.super_rare_weight
	card_rarity_weights[Card.Rarity.COMMON] = run_stats.common_weight
	card_rarity_weights[Card.Rarity.RARE] = run_stats.rare_weight
	card_rarity_weights[Card.Rarity.SUPER_RARE] = run_stats.super_rare_weight

func _modify_weights(rarity_rolled: Card.Rarity) -> void:
	if rarity_rolled == Card.Rarity.SUPER_RARE:
		run_stats.super_rare_weight = RunStats.BASE_SUPER_RARE_WEIGHT
	else :
		run_stats.super_rare_weight = clampf(run_stats.super_rare_weight + 0.3, RunStats.BASE_SUPER_RARE_WEIGHT, 5.0)

func _get_random_available_card(available_cards: Array[Card], with_rartiy: Card.Rarity) -> Card:
	var all_possible_cards : = available_cards.filter(
		func(card: Card):
			return card.rarity == with_rartiy
	)
	return Rng.array_pick_random(all_possible_cards)

func _on_card_reward_taken(card: Card)-> void:
	if not character_stats or not card:
		return
	
	character_stats.deck.add_card(card)

func on_gold_reward_taken(amount: int) -> void:
	if not run_stats:
		return
	
	run_stats.gold += amount

func on_relic_reward_taken(relic: Relic) -> void:
	if not relic or not relic_handler:
		return
	
	relic_handler.add_relic(relic)
	
func _on_back_button_pressed() -> void:
	Events.battle_reward_exited.emit()
