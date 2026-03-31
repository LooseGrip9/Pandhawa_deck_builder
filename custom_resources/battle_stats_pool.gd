class_name BattleStatsPool
extends Resource

@export var pool: Array[BattleStats]

# CHANGED: Exactly 4 slots for Tiers 0, 1, 2, and 3
var total_weights_by_tier := [0.0, 0.0, 0.0, 0.0] 

func get_battle_by_name(target_name: String) -> BattleStats:
	for battle in pool:
		if battle != null and battle.battle_name == target_name:
			return battle
	
	push_error("BattleStatsPool: Could not find boss named " + target_name)
	return null

func _get_all_battles_for_tier(tier: int) -> Array[BattleStats]:
	return pool.filter(
		func(battle: BattleStats):
			return battle != null and battle.battle_tier == tier
	)

func _setup_weight_for_tier(tier: int) -> void:
	var battles := _get_all_battles_for_tier(tier)
	
	for battle: BattleStats in battles:
		total_weights_by_tier[tier] += battle.weight
		battle.accumulated_weight = total_weights_by_tier[tier]

func get_random_battle_for_tier(tier: int) -> BattleStats:
	var roll := Rng.instance.randf_range(0.0, total_weights_by_tier[tier])
	var battles := _get_all_battles_for_tier(tier)
	
	for battle: BattleStats in battles:
		if battle.accumulated_weight > roll:
			return battle
	
	return null

func setup() -> void:
	total_weights_by_tier = [0.0, 0.0, 0.0, 0.0] 
	
	for i in 4:
		_setup_weight_for_tier(i)
