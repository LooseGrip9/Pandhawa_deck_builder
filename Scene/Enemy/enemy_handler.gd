class_name EnemyHandler
extends Node2D

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
	
