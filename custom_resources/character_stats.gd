class_name CharacterStats
extends Stats

@export_group("Visual")
@export var character_name: String
@export_multiline var description: String
@export var portrait: Texture

@export_group("Gameplay Data")
@export var draftable_cards: CardPile
@export var starting_deck: CardPile
@export var cards_per_turn: int
@export var max_mana: int
@export var starting_relics: Array[Relic]
@export var battle_pool: BattleStatsPool

var mana: int : set = set_mana
var deck: CardPile
var discard: CardPile
var draw_pile: CardPile

func set_mana (value: int) -> void:
	mana = value
	stats_changed.emit()
	
func reset_mana() -> void:
	mana = max_mana

func take_damage(damage: int) -> void:
	var initial_health := health
	super.take_damage(damage)
	if initial_health > health:
		Events.player_hit.emit()

func can_play_card(card: Card) -> bool:
	return mana >= card.cost
	
func reset_counter() -> void:
	counter_damage = 0
	stats_changed.emit()

func create_instance() -> Resource:
	var instance: CharacterStats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	instance.reset_mana()
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_pile = instance.deck.duplicate()
	instance.discard = CardPile.new()
	
	# Safety: If the array is null for some reason, initialize it as empty
	if starting_relics:
		instance.starting_relics = starting_relics.duplicate()
	else:
		instance.starting_relics = []
		
	return instance
