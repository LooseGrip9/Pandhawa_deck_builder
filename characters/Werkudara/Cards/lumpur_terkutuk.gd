extends Card

const SLOW_STATUS = preload("res://statuses/lambat.tres")

@export var slow_amount := 2

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	if _targets.is_empty():
		return
	
	var slow_effect := StatusEffect.new()
	var slow := SLOW_STATUS.duplicate()
	
	slow.stacks = slow_amount 
	
	slow_effect.status = slow
	
	slow_effect.execute(_targets)
