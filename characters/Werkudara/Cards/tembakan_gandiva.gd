extends Card

@export var optional_sound: AudioStream

var _last_execution_frame: int = -1
var base_damage = 5

func get_default_tooltip() -> String:
	return tooltip_text % base_damage

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var current_frame = Engine.get_process_frames()
	if current_frame == _last_execution_frame:
		return
	_last_execution_frame = current_frame

	var tree := Engine.get_main_loop() as SceneTree
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	if not player_handler:
		return

	var damage = base_damage
	if player_handler.cards_played_this_turn > 1:
		damage = base_damage * 2

	for target in targets:
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(damage, Modifier.Type.NO_MODIFIER)
			
	if optional_sound and targets.size() > 0:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = optional_sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
