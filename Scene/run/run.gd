class_name Run
extends Node

const BATTLE_SCENE := preload("res://Scene/Battle/Battle.tscn")
const BATTLE_REWARD_SCENE := preload("res://Scene/Battle_Reward/Battle_reward.tscn")
const CAMPFIRE_SCENE := preload("res://Scene/Campfire/campfire.tscn")
const SHOP_SCENE := preload("res://Scene/Shop/shop.tscn")
const TREASURE_SCENE := preload("res://Scene/Treasure/treasure.tscn")
const WIN_SCREEN_SCENE := preload("res://Scene/win_screen/win_screen.tscn")
const GRIYA_SCENE := preload("res://Scene/Griya_Pitutur/Griya.tscn")
const MAIN_MENU_PATH := "res://Scene/UI/main_menu.tscn"

@export var run_startup: RunStartup

@onready var map: Map = $Map

@onready var current_view: Node = $CurrentView
@onready var gold_ui: GoldUI = %GoldUI
@onready var deck_button: CardPileOpener = %DeckButton
@onready var deck_view: CardPileView= %DeckView
@onready var health_ui: HealthUI = %HealthUI 
@onready var relic_handler: RelicHandler = %RelicHandler
@onready var relic_tooltip: RelicTooltip = %RelicToolip
@onready var pause_menu: PauseLayer = $PauseLayer

@onready var battle_button: Button = $DebugButton/Battle
@onready var campfire_button: Button = $DebugButton/Campfire
@onready var map_button: Button = $DebugButton/Map
@onready var rewards_button: Button = $DebugButton/Rewards
@onready var shop_button: Button = $DebugButton/Shop
@onready var treasure_button: Button = $DebugButton/Treasure

var stats: RunStats
var character: CharacterStats
var save_data: SaveGame

func _ready() -> void:
	print("--- RUN SCENE WOKE UP ---")
	
	if not run_startup:
		# Debug fallback: if testing Run.tscn directly
		if not character:
			var pandhawa := load("res://characters/Werkudara/werkudara.tres")
			character = pandhawa.create_instance()
		
		RunManager.current_character = character
		_start_run()
		return
	
	pause_menu.save_and_quit.connect(
		func():
			get_tree().change_scene_to_file(MAIN_MENU_PATH)
	)
	
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			character = run_startup.picked_character.create_instance()
			RunManager.current_character = character 
			print("1. RunManager set to: ", character.character_name)
			_start_run()
			
		RunStartup.Type.CONTINUED_RUN:
			_load_run()


func _start_run() -> void:
	print("2. Starting Run logic...")
	stats = RunStats.new()
	
	_setup_event_connections()
	_setup_top_bar()
	
	print("3. Calling map.generate_new_map()...")
	map.generate_new_map()
	map.unlock_floor(0)
	
	save_data = SaveGame.new()
	_save_run(true)


func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data, "Couldn't load last save")
	
	Rng.set_from_save_data(save_data.rng_seed, save_data.rng_state)
	stats = save_data.run_stats
	character = save_data.char_stats
	
	# CRITICAL: Re-sync the RunManager on load!
	RunManager.current_character = character
	
	character.deck = save_data.current_deck
	character.health = save_data.current_health
	relic_handler.add_relics(save_data.relics)
	_setup_top_bar()
	_setup_event_connections()
	
	map.load_map(save_data.map_data, save_data.floors_climbed, save_data.last_room)
	if save_data.last_room and not save_data.was_on_map:
		_on_map_exited(save_data.last_room)

func _save_run(was_on_map: bool) -> void:
	save_data.rng_seed = Rng.instance.seed
	save_data.rng_state = Rng.instance.seed
	save_data.run_stats = stats
	save_data.char_stats = character
	save_data.current_deck = character.deck
	save_data.current_health = character.health
	save_data.relics = relic_handler.get_all_relics()
	save_data.last_room = map.last_room
	save_data.map_data = map.map_data.duplicate()
	save_data.floors_climbed = map.floors_climbed
	save_data.was_on_map = was_on_map
	save_data.save_data()



func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0). queue_free()

	get_tree().paused = false
	var new_view := scene.instantiate()
	current_view.add_child(new_view)
	
	map.hide_map()
	
	return new_view

func show_map() -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
		
	map.show_map()
	map.unlock_next_room()
	
	_save_run(true)

func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_won)
	Events.battle_reward_exited.connect(show_map)
	Events.campfire_exited.connect(show_map)
	Events.map_exited.connect(_on_map_exited)
	Events.shop_exited.connect(show_map)
	Events.treasure_room_exited.connect(_on_treasure_room_exited)
	Events.room_exited.connect(show_map)
	
	battle_button.pressed.connect(_change_view.bind(BATTLE_SCENE))
	campfire_button.pressed.connect(_change_view.bind(CAMPFIRE_SCENE))
	map_button.pressed.connect(show_map)
	rewards_button.pressed.connect(_change_view.bind(BATTLE_REWARD_SCENE))
	shop_button.pressed.connect(_change_view.bind(SHOP_SCENE))
	treasure_button.pressed.connect(_change_view.bind(TREASURE_SCENE))

func _on_battle_room_entered(room: Room) -> void:
	var battle_scene: Battle = _change_view(BATTLE_SCENE) as Battle
	battle_scene.char_stats = character
	battle_scene.battle_stats = room.battle_stats
	battle_scene.relics = relic_handler
	battle_scene.start_battle()

func _on_campfire_entered(room: Room) -> void:
	var campfire := _change_view(CAMPFIRE_SCENE) as Campfire
	campfire.char_stats = character

func _on_treasure_room_entered() -> void:
	var treasure_scene := _change_view(TREASURE_SCENE) as Treasure
	treasure_scene.relic_handler = relic_handler
	treasure_scene.character_stats = character 
	treasure_scene.generate_relic()
	
func _on_treasure_room_exited(relic: Relic) -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.relic_handler = relic_handler
	
	reward_scene.add_relic_reward(relic)

func _on_shop_entered() -> void:
	var shop := _change_view(SHOP_SCENE) as Shop
	shop.char_stats = character
	shop.run_stats = stats
	shop.relic_handler = relic_handler
	Events.shop_entered.emit(shop)
	shop.populate_shop()

func _on_battle_won() -> void:
	if map.floors_climbed == MapGenerator.FLOORS:
		var win_screen := _change_view(WIN_SCREEN_SCENE) as WinScreen
		win_screen.character = character
	else:
		show_regular_battle_rewards()

func _setup_top_bar():
	character.stats_changed.connect(health_ui._update_stats.bind(character))
	health_ui._update_stats(character)
	gold_ui.run_stats = stats
	relic_handler.add_relics(character.starting_relics)
	Events.relic_tooltip_requested.connect(relic_tooltip.show_tooltip)
	deck_button.card_pile = character.deck
	deck_view.card_pile = character.deck
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))

func show_regular_battle_rewards() -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	
	reward_scene.add_gold_reward(map.last_room.battle_stats.roll_gold_reward())
	reward_scene.add_card_reward()

func _on_map_exited(room: Room) -> void:
	match room.type:
		Room.Type.MONSTER:
			_on_battle_room_entered(room)
		Room.Type.TREASURE:
			_on_treasure_room_entered()
		Room.Type.SHOP:
			_on_shop_entered()
		Room.Type.CAMPFIRE:
			_on_campfire_entered(room)
		Room.Type.BOSS:
			_on_battle_room_entered(room)
		Room.Type.GRIYA_PITUTUR:
			# 1. Simpan baris ke global SEBELUM pindah scene
			RunManager.baris_kamar_saat_ini = room.row 
			
			# 2. Buka scene seperti biasa
			_change_view(GRIYA_SCENE)
