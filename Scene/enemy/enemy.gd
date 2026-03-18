class_name Enemy
extends Area2D

const ARROW_OFFSET := 5
const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")
signal damaged(amount: int)

@export var stats: EnemyStats : set = set_enemy_stats

@onready var modifier_handler: ModifierHandler = $Modifier_Handler
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI as StatsUI
@onready var intent_ui: IntentUI = $IntentUI as IntentUI
@onready var status_handler: StatusHandler = $StatusHandler

@export var stunned_intent: Intent
@export var kebal_status: Status
@export var sumpah_status: Status
@export var deflect_status: Status
@export var sunset_vow: Status

var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action

var opening_move_performed := false
var doing_opening_move := false

func _ready() -> void:
	if status_handler:
		status_handler.statuses_changed.connect(update_intent)
	
	Events.card_played.connect(func(_card): call_deferred("update_intent"))
	Events.player_hand_drawn.connect(func(): call_deferred("update_intent"))
	Events.player_hand_discarded.connect(func(): call_deferred("update_intent"))

func set_current_action(value: EnemyAction)-> void:
	current_action = value
	update_intent()

func set_enemy_stats(value: EnemyStats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		stats.stats_changed.connect(update_action)
		
		update_enemy()

func setup_ai() -> void:
	if enemy_action_picker:
		enemy_action_picker.queue_free()
	
	var new_action_picker := stats.ai.instantiate() as EnemyActionPicker
	
	if new_action_picker:
		add_child(new_action_picker)
		enemy_action_picker = new_action_picker
		enemy_action_picker.enemy = self

func update_action() -> void:
	if not enemy_action_picker:
		return
	
	if not current_action:
		current_action = enemy_action_picker.get_action()
		return
	
	var new_conditional_action := enemy_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action
	
func update_stats() -> void:
	stats_ui.update_stats(stats)

func update_enemy() -> void:
	if not stats is Stats:
		return
	if not is_inside_tree():
		await ready
	
	sprite_2d.texture = stats.art
	arrow.position = Vector2.RIGHT * (sprite_2d.get_rect().size.x / 2 + ARROW_OFFSET)
	setup_ai()
	update_stats()
	
	if stats.id == "Sengkuni" and not opening_move_performed:
		opening_move_performed = true
		_apply_opening_move()
	elif stats.id == "Duryudana" and not opening_move_performed:
		opening_move_performed = true
		call_deferred("_apply_diamond_body")
	elif stats.id == "Jayadrata" and not opening_move_performed:
		opening_move_performed = true
		call_deferred("_apply_sunset_vow")

func _apply_opening_move() -> void:
	await get_tree().process_frame
	
	if not enemy_action_picker:
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player: return

	for action in enemy_action_picker.get_children():
		if action is ActionPasangJerat:
			doing_opening_move = true
			
			action.enemy = self
			action.target = player
			action.perform_action()
			current_action = action
			
			_refresh_card_costs()
			break

func update_intent() -> void:
	if not is_inside_tree() or stats.health <= 0:
		return

	var allowed_actions := 1
	
	if modifier_handler:
		allowed_actions = modifier_handler.get_modified_value(allowed_actions, Modifier.Type.ACTION_COUNT)
	
	if allowed_actions <= 0:
		if stunned_intent:
			intent_ui.update_intent(stunned_intent)
			intent_ui.show()
		else:
			intent_ui.hide()
		return

	intent_ui.show()
	if current_action:
		current_action.update_intent_text()
		intent_ui.update_intent(current_action.intent)

func _refresh_card_costs() -> void:
	var cards = get_tree().get_nodes_in_group("cards_in_hand")
	for card_ui in cards:
		if card_ui.has_method("_recheck_playability"):
			card_ui._recheck_playability()

func do_turn() -> void:
	print("--- ENEMY TURN STARTING ---")
	print("Enemy name: ", name)
	print("Current Action picked: ", current_action)
	
	if stats:
		stats.block = 0
		update_stats()
	
	if not current_action:
		Events.enemy_action_completed.emit(self)
		return
	
	var allowed_actions := 1
	
	if modifier_handler:
		allowed_actions = modifier_handler.get_modified_value(allowed_actions, Modifier.Type.ACTION_COUNT)
	
	if allowed_actions <= 0:
		Events.enemy_action_completed.emit(self)
		return
	
	current_action.perform_action()
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.get("stats"):
		var player_stats = player.stats as Stats
		var action_name : String = current_action.get_script().get_path().to_lower()
		var is_attacking := action_name.contains("attack")
		
		if is_attacking and player_stats.counter_damage > 0:
			get_tree().create_timer(0.4).timeout.connect(
				func(): take_damage(player_stats.counter_damage, Modifier.Type.NO_MODIFIER)
			)

func take_damage(damage: int, which_modifier: Modifier.Type) -> void:
	if stats.health <= 0:
		return
	
	if stats.id == "Jayadrata":
		var allies = []
		var current_enemies = get_tree().get_nodes_in_group("enemies")
		
		for entity in current_enemies:
			if entity != self and not entity.is_queued_for_deletion():
				if entity.get("stats") and entity.stats.health > 0:
					allies.append(entity)
					
		if allies.size() > 0:
			var meat_shield = allies.pick_random()
			print("Shiva's Boon triggered! Deflected ", damage, " damage to ", meat_shield.name)
			
			var deflect_tween = create_tween()
			deflect_tween.tween_property(sprite_2d, "modulate", Color(0.8, 0.8, 0.8), 0.1)
			deflect_tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)
			
			meat_shield.take_damage(damage, which_modifier)
			return
	
	var actual_damage = damage
	if stats.id == "Duryudana" and status_handler:
		for child in status_handler.get_children():
			var status_data = child.get("status")
			if status_data and status_data.id == "kebal":
				actual_damage = 0
				print("BLOCKED! Diamond Body reduced damage to 0!")
				break

	sprite_2d.material = WHITE_SPRITE_MATERIAL
	
	var modified_damage := modifier_handler.get_modified_value(actual_damage, which_modifier)
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(modified_damage))
	
	tween.tween_callback(func(): damaged.emit(modified_damage))
	
	tween.tween_interval(0.2)
	
	tween.finished.connect(
		func():
			sprite_2d.material = null
			
			if stats.health <= 0:
				Events.enemy_died.emit(self)
				queue_free()
	)

func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()

func _on_area_entered(_area: Area2D) -> void:
	arrow.show()

func _apply_diamond_body() -> void:
	var handler = get_node_or_null("StatusHandler")
	if handler and kebal_status:
		var starting_kebal = kebal_status.duplicate() as Status
		starting_kebal.stacks = 1
		
		handler.add_status(starting_kebal)
		print("Phase 1: Duryudana enters the battlefield with Kekebalan Gandari!")

func _apply_sunset_vow() -> void:
	var handler = get_node_or_null("StatusHandler")
	if handler:
		if sumpah_status:
			var starting_vow = sumpah_status.duplicate() as Status
			starting_vow.stacks = 8
			handler.add_status(starting_vow)
			print("Jayadrata hides! The 8-turn Sunset Vow begins!")
			
		if deflect_status:
			var starting_deflect = deflect_status.duplicate() as Status
			starting_deflect.stacks = 1
			handler.add_status(starting_deflect)
			print("Deflection Tooltip added to UI!")
