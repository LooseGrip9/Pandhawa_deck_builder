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
