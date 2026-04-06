extends Card

@export var optional_sound: AudioStream

var _last_execution_frame: int = -1

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var current_frame = Engine.get_process_frames()
	if current_frame == _last_execution_frame:
		return
	_last_execution_frame = current_frame

	var tree := Engine.get_main_loop() as SceneTree
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	if player_handler:
		player_handler.retain_hand_once = true
		
	if optional_sound:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = optional_sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
