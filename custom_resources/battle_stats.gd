class_name BattleStats
extends Resource

@export var battle_name: String # <--- ADD THIS LINE
@export_range(0, 2) var battle_tier: int
@export_range(0.0, 10.0) var weight: float
@export var gold_max: int
@export var gold_min: int
@export var enemies: PackedScene 

var accumulated_weight: float = 0.0

func roll_gold_reward() -> int:
	return Rng.instance.randi_range(gold_min, gold_max)
