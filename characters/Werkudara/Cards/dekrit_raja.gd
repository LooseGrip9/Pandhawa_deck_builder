extends Card

const KYAT_STATUS = preload("res://statuses/kyat.tres")
const TANGKAS_STATUS = preload("res://statuses/tangkas.tres")

@export var buff_amount := 1
@export var optional_sound: AudioStream

func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	
	var tree = _targets[0].get_tree() if _targets.size() > 0 else Engine.get_main_loop()
	var player_nodes = tree.get_nodes_in_group("player")
	
	if player_nodes.is_empty():
		return
		
	var player = player_nodes[0]
	var target_array: Array[Node] = [player]
	
	var kyat_effect := StatusEffect.new()
	var kyat := KYAT_STATUS.duplicate()
	kyat.stacks = buff_amount 
	kyat_effect.status = kyat
	kyat_effect.execute(target_array)
	
	var tangkas_effect := StatusEffect.new()
	var tangkas := TANGKAS_STATUS.duplicate()
	tangkas.stacks = buff_amount 
	tangkas_effect.status = tangkas
	tangkas_effect.execute(target_array)

	if sound:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
