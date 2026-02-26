# damage_relic.gd (Beras Prajurit or Keris)
extends Relic

@export var damage_bonus := 1

func initialize_relic(owner: RelicUI) -> void:
	var run = _get_run_node(owner)
	if run and run.stats:
		run.stats.bonus_damage += damage_bonus
		owner.flash()

func _get_run_node(node: Node) -> Node:
	var current = node
	while current != null:
		if current is Run: return current
		current = current.get_parent()
	return null
