class_name Battle
extends Node2D

@export var battle_stats: BattleStats
@export var char_stats: CharacterStats
@export var music: AudioStream
@export var relics: RelicHandler

@onready var battle_ui: BattleUI = $BattleUI as BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler as PlayerHandler
@onready var player: Player = $Player as Player
@onready var enemy_handler: EnemyHandler = $EnemyHandler as EnemyHandler

func _ready() -> void:
	$ColorRect/AnimationPlayer.play("fade_out")
	
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
	enemy_handler.reset_enemy_actions()
	
	player_handler.start_battle(char_stats)
	battle_ui.initialize_card_pile_ui()
	
	if is_instance_valid(relics):
		if not relics.relics_activated.is_connected(_on_relics_activated):
			relics.relics_activated.connect(_on_relics_activated)
		
		relics.activate_relics_by_type(Relic.Type.START_OF_COMBAT)
	
	var start_turn_callable = func():
		Events.player_turn_started.emit()
		player_handler.start_turn()
		
	get_tree().process_frame.connect(start_turn_callable, CONNECT_ONE_SHOT)

func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_COMBAT:
			pass 
		Relic.Type.END_OF_COMBAT:
			Events.battle_over_screen_requested.emit("Edan Menang!", BattleOverPanel.Type.WIN)

func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Njir Kalah", BattleOverPanel.Type.LOSE)

func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0:
		if is_instance_valid(relics):
			relics.activate_relics_by_type(Relic.Type.END_OF_COMBAT)
		else:
			Events.battle_over_screen_requested.emit("Edan Menang!", BattleOverPanel.Type.WIN)

func _on_enemy_turn_ended() -> void:
	Events.player_turn_started.emit()
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		if OS.is_debug_build():
			_debug_kill_all_enemies()

func _debug_kill_all_enemies() -> void:
	print("DEBUG: Instakill activated!")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	

	enemies.sort_custom(func(a, b):
		var a_is_jayadrata = a.get("stats") and a.stats.id == "Jayadrata"
		return not a_is_jayadrata
	)
	
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(9999, Modifier.Type.NO_MODIFIER) 
		else:
			enemy.queue_free()
