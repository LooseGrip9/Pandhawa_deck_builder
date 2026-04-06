class_name Treasure
extends Control

@export var treasure_relic_pool: Array[Relic]
@export var relic_handler: RelicHandler
@export var character_stats: CharacterStats

@onready var animation_player: AnimationPlayer = %AnimationPlayer
var found_relic: Relic

func generate_relic() -> void:
	var available_relics := treasure_relic_pool.filter(
		func(relic: Relic):
			var can_appear := relic.can_appear_as_reward(character_stats)
			var already_had_it := relic_handler.has_relic(relic.id)
			return can_appear and not already_had_it
	)
	
	if available_relics.is_empty():
		print("All relics collected! Awarding 500 gold.")
		if character_stats:
			character_stats.gold += 500
			
		found_relic = null
		return
	
	found_relic = Rng.array_pick_random(available_relics)

func _on_treasure_opened() -> void:
	Events.treasure_room_exited.emit(found_relic)

func _on_treasure_chest_gui_input(event: InputEvent) -> void:
	if animation_player.current_animation == "open":
		return
	
	if event.is_action_pressed("left_mouse"):
		animation_player.play("open")
