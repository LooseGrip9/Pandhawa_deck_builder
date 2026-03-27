class_name LajuPassive
extends Node

var enemy: Enemy : set = _set_enemy
var target: Node2D

func _set_enemy(value: Enemy) -> void:
	enemy = value
	if enemy and not enemy.damaged.is_connected(_on_enemy_damaged):
		enemy.damaged.connect(_on_enemy_damaged)

func _on_enemy_damaged(amount: int) -> void:
	if amount >= 10:
		var momentum = enemy.status_handler.get_status("laju")
		
		if momentum:
			momentum.stacks = 0
			enemy.status_handler.remove_status("laju") 
			
			enemy.status_handler.statuses_changed.emit()
			enemy.update_intent()
			
			_play_tumble_animation()

func _play_tumble_animation() -> void:
	if not enemy.sprite_2d:
		return
		
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(enemy.sprite_2d, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(enemy.sprite_2d, "scale", Vector2.ONE, 0.2)
