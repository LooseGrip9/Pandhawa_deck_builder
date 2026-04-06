#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

@export var hp_loss := 5
@export var energy_gain := 2

@export var optional_sound: AudioStream

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in targets:
		var stats = target.get("stats")
		if stats:
			stats.health -= hp_loss
			stats.mana += energy_gain
			
			Events.player_hit.emit()
			
			var sprite = target.get_node_or_null("Sprite2D")
			if sprite:
				Shaker.shake(sprite, 15.0, 0.3)
			
			if stats.has_signal("stats_changed"):
				stats.stats_changed.emit()
			
			if stats.health <= 0:
				pass
				
	if optional_sound and targets.size() > 0:
		var tree = targets[0].get_tree()
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = optional_sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
