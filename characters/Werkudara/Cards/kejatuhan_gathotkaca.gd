#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

@export var optional_sound: AudioStream

var _last_execution_frame: int = -1
var base_damage = 20
var take_damage = 10

func get_default_tooltip() -> String:
	return tooltip_text % base_damage

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var current_frame = Engine.get_process_frames()
	if current_frame == _last_execution_frame:
		return
	
	_last_execution_frame = current_frame

	var tree := Engine.get_main_loop() as SceneTree
	
	var all_enemies = tree.get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			if enemy.has_method("take_damage"):
				enemy.take_damage(base_damage, Modifier.Type.NO_MODIFIER)
	
	var player = tree.get_first_node_in_group("player")
	if player and player.has_method("take_damage"):
		player.take_damage(take_damage, Modifier.Type.NO_MODIFIER)

	if optional_sound:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = optional_sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
