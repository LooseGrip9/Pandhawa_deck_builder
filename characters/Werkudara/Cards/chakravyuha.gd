#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

@export var block_amount := 15
@export var counter_amount := 5
@export var optional_sound: AudioStream

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in targets:
		var stats = target.get("stats") as Stats
		if stats:
			stats.block += block_amount
			stats.counter_damage += counter_amount
			stats.stats_changed.emit()
