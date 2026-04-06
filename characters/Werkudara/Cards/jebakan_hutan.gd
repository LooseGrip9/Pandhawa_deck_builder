extends Card

const RENTAN_STATUS = preload("res://statuses/rentan.tres")

@export var rentan_stacks := 3
@export var counter_amount := 10
@export var optional_sound: AudioStream

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:

	var status_effect := StatusEffect.new()
	var rentan := RENTAN_STATUS.duplicate()
	
	rentan.duration = rentan_stacks 
	
	status_effect.status = rentan
	status_effect.execute(targets)
	
	if targets.is_empty(): return
	var tree := targets[0].get_tree()
	
	# 2. Apply Counter damage to the player
	var player_nodes = tree.get_nodes_in_group("player")
	
	if player_nodes.size() > 0:
		var player = player_nodes[0]
		var player_stats = player.get("stats") as Stats
		
		if player_stats:
			player_stats.counter_damage += counter_amount
			player_stats.stats_changed.emit()
			
	if optional_sound:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = optional_sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
