class_name ActionBersiapGada
extends EnemyAction

@export var charge_status: Status # Drag your mengisi_gada.tres here!

func is_performable() -> bool:
	if not enemy: return false
	
	# Condition 1: Minions must be dead (Phase 2)
	var enemies = enemy.get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e != enemy and not e.is_queued_for_deletion() and e.get("stats") and e.stats.health > 0:
			return false # Minion still alive
			
	# Condition 2: Don't perform if already charging
	if enemy.status_handler:
		for child in enemy.status_handler.get_children():
			var data = child.get("status")
			if data and data.id == "mengisi_gada":
				return false
				
	return true

func update_intent_text() -> void:
	intent.current_text = intent.base_text # "Bersiap: Kiamat Gada!"

func perform_action() -> void:
	if not enemy or not charge_status: return
	
	var handler = enemy.get_node_or_null("StatusHandler")
	if handler:
		var new_charge = charge_status.duplicate() as Status
		new_charge.stacks = 1
		handler.add_status(new_charge)
		print("Duryudana is charging his mace!")
		
	Events.enemy_action_completed.emit(enemy)
