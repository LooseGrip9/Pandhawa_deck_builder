class_name LajuStatus
extends Status

@export var damage_per_stack := 3

func get_tooltip() -> String:
	var total_bonus = stacks * damage_per_stack
	return tooltip % total_bonus

func get_bonus_damage() -> int:
	return stacks * damage_per_stack
