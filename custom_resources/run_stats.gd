class_name RunStats
extends Resource

signal gold_changed

const STARTING_GOLD := 300
const BASE_CARD_REWARD := 3
const BASE_COMMON_WEIGHT := 6.0
const BASE_RARE_WEIGHT := 3.7
const BASE_SUPER_RARE_WEIGHT := 0.3

@export var starting_block: int = 0
@export var bonus_damage := 0
@export var gold_multiplier := 1.0
@export var gold := STARTING_GOLD : set = set_gold
@export var card_rewards := BASE_CARD_REWARD
@export_range(0.0, 10.0) var common_weight := BASE_COMMON_WEIGHT
@export_range(0.0, 10.0) var rare_weight := BASE_RARE_WEIGHT
@export_range(0.0, 10.0) var super_rare_weight := BASE_SUPER_RARE_WEIGHT

func set_gold(new_amount: int) -> void:
	gold = new_amount 
	gold_changed.emit()

func reset_weights() -> void:
	common_weight = BASE_COMMON_WEIGHT
	rare_weight = BASE_RARE_WEIGHT
	super_rare_weight = BASE_SUPER_RARE_WEIGHT
