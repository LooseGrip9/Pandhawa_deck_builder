class_name EnemyHandler
extends Node2D

func setup_enemies(battle_stats: BattleStats) -> void:
	if not battle_stats:
		return
	
	for enemy: Enemy in get_children():
		enemy.queue_free()
	
	var all_new_enemies := battle_stats.enemies.instantiate()
	
	for new_enemy: Node2D in all_new_enemies.get_children():
		var new_enemy_child := new_enemy.duplicate() as Enemy
		add_child(new_enemy_child)
	
	all_new_enemies.queue_free()

func _ready() -> void:
	Events.enemy_action_completed.connect(_on_enemy_action_completed)

func reset_enemy_actions() -> void:
	var enemy: Enemy
	for child in get_children():
		enemy = child as Enemy
		if not enemy:
			continue
		
		enemy.current_action = null
		enemy.update_action()

func start_turn() -> void:
	if get_child_count() == 0:
		return
	
	for child in get_children():
		var enemy := child as Enemy
		if enemy:
			enemy.do_turn()
			return

func _on_enemy_action_completed(enemy: Enemy) -> void:
	var all_enemies := []
	for child in get_children():
		if child is Enemy:
			all_enemies.append(child)
	
	var index := all_enemies.find(enemy)
	
	if index == all_enemies.size() - 1:
		Events.enemy_turn_ended.emit()
		return
	
	var next_enemy := all_enemies[index + 1] as Enemy
	next_enemy.do_turn()
	
