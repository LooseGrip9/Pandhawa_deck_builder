class_name KyatStatus
extends Status


var KYAT_STATUS = preload("res://statuses/kyat.tres")
var stacks_per_turn := 2

func apply_status(_target: Node) -> void:
	print("Apply kyat Status")
	
	var status_effect = StatusEffect.new()
	var kyat := KYAT_STATUS.duplicate()
	kyat.stacks = stacks_per_turn
	status_effect.status = kyat
	status_effect.execute([_target])
	
	status_applied.emit(self)
