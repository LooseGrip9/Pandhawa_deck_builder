class_name Battle
extends Node2D

const ENDING_CUTSCENE = preload("res://Scene/UI/ending_cutscene.tscn")

@export var battle_stats: BattleStats
@export var char_stats: CharacterStats
@export var music: AudioStream
@export var relics: RelicHandler

@export_group("Dialogue Settings")
@export var text_speed: float = 0.03

@onready var battle_ui: BattleUI = $BattleUI as BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler as PlayerHandler
@onready var player: Player = $Player as Player
@onready var enemy_handler: EnemyHandler = $EnemyHandler as EnemyHandler

@onready var dialogue_ui: Control = %DialogueUI
@onready var dialogue_text: RichTextLabel = %DialogueText 

# Captured at start to prevent "Invalid Access" errors later
var active_boss_id: String = ""
var in_cutscene: bool = false
var dialogue_index: int = 0
var current_dialogue: Array[String] = []
var text_tween: Tween
var is_typing: bool = false

func _ready() -> void:
	$ColorRect/AnimationPlayer.play("fade_out")
	if dialogue_ui:
		dialogue_ui.hide()
	
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)

func start_battle() -> void:
	MusicPlayer.play(music, true)
	battle_ui.char_stats = char_stats
	player.stats = char_stats
	player_handler.relics = relics
	enemy_handler.setup_enemies(battle_stats)
	
	# --- CAPTURE BOSS ID FROM EnemyStats ---
	for enemy in enemy_handler.get_children():
		if "stats" in enemy and enemy.stats is EnemyStats:
			var eid = enemy.stats.id
			if eid == "Duryudana" or eid == "Karna":
				active_boss_id = eid
				print("FINAL BOSS DETECTED: ", active_boss_id)
	
	enemy_handler.reset_enemy_actions()
	player_handler.start_battle(char_stats)
	battle_ui.initialize_card_pile_ui()
	
	if is_instance_valid(relics):
		if not relics.relics_activated.is_connected(_on_relics_activated):
			relics.relics_activated.connect(_on_relics_activated)
	
	if "intro_dialogue" in battle_stats and battle_stats.intro_dialogue.size() > 0:
		_start_cutscene(battle_stats.intro_dialogue)
	else:
		_begin_combat_phase()

func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0:
		var is_final_boss = active_boss_id == "Duryudana" or active_boss_id == "Karna"
		var is_final_floor = RunManager.current_floor >= 44
		
		if is_final_boss or is_final_floor:
			battle_ui.hide()
			var ending = ENDING_CUTSCENE.instantiate()
			add_child(ending)
			ending.setup_ending(active_boss_id if active_boss_id != "" else "Duryudana")
			
			await ending.cutscene_finished
			get_tree().change_scene_to_file("res://Scene/UI/main_menu.tscn")
			return
		
		if is_instance_valid(relics):
			relics.activate_relics_by_type(Relic.Type.END_OF_COMBAT)
		else:
			Events.battle_over_screen_requested.emit("Menang!", BattleOverPanel.Type.WIN)

func _start_cutscene(dialogue_array: Array[String]) -> void:
	in_cutscene = true
	current_dialogue = dialogue_array
	dialogue_index = 0
	if dialogue_ui: dialogue_ui.show()
	_show_next_dialogue_line()

func _show_next_dialogue_line() -> void:
	if dialogue_index < current_dialogue.size():
		var next_line = current_dialogue[dialogue_index]
		if dialogue_text:
			dialogue_text.text = next_line
			dialogue_text.visible_characters = 0 
			is_typing = true
			if text_tween: text_tween.kill()
			text_tween = create_tween()
			var duration = next_line.length() * text_speed
			text_tween.tween_property(dialogue_text, "visible_characters", next_line.length(), duration)
			text_tween.finished.connect(_on_typing_finished)
		dialogue_index += 1
	else:
		in_cutscene = false
		if dialogue_ui: dialogue_ui.hide()
		_begin_combat_phase()

func _on_typing_finished() -> void:
	is_typing = false

func _begin_combat_phase() -> void:
	if is_instance_valid(relics):
		relics.activate_relics_by_type(Relic.Type.START_OF_COMBAT)
	var start_turn_callable = func():
		Events.player_turn_started.emit()
		player_handler.start_turn()
	get_tree().process_frame.connect(start_turn_callable, CONNECT_ONE_SHOT)

func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.END_OF_COMBAT:
			Events.battle_over_screen_requested.emit("Menang!", BattleOverPanel.Type.WIN)

func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Kalah!", BattleOverPanel.Type.LOSE)

func _on_enemy_turn_ended() -> void:
	Events.player_turn_started.emit()
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()

func _input(event: InputEvent) -> void:
	if in_cutscene and event.is_action_pressed("left_mouse"):
		get_viewport().set_input_as_handled()
		if is_typing:
			if text_tween: text_tween.kill()
			dialogue_text.visible_characters = -1 
			is_typing = false
		else:
			_show_next_dialogue_line()
		return
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		if OS.is_debug_build(): _debug_kill_all_enemies()

func _debug_kill_all_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(9999, Modifier.Type.NO_MODIFIER) 
		else:
			enemy.queue_free()
