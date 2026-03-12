class_name DukunSantetPassive
extends Node

var enemy: Enemy : set = _set_enemy
var target: Node2D 

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")

func _set_enemy(value: Enemy) -> void:
	enemy = value
	if enemy and not enemy.damaged.is_connected(_on_enemy_damaged):
		enemy.damaged.connect(_on_enemy_damaged)

func _on_enemy_damaged(amount: int) -> void:
	if amount <= 0:
		return

	var santet_status = enemy.status_handler.get_status("santet")
	
	if santet_status and target:
		if enemy.sprite_2d:
			var tween := create_tween()
			tween.tween_property(enemy.sprite_2d, "modulate", Color(1.0, 0.0, 0.0), 0.1)
			tween.tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.2)
		
		var damage_effect := DamageEffect.new()
		damage_effect.amount = amount
		damage_effect.execute([target])
		
		if Shaker:
			Shaker.shake(target, 8, 0.3)
