class_name Enemy
extends Area2D

const ARROW_OFFSET := 5
const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

@export var stats: EnemyStats : set = set_enemy_stats

@onready var modifier_handler: ModifierHandler = $Modifier_Handler
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI as StatsUI
@onready var intent_ui: IntentUI = $IntentUI as IntentUI
@onready var status_handler: StatusHandler = $StatusHandler

var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action

func _ready() -> void:
	if status_handler:
		status_handler.statuses_changed.connect(update_intent)

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
	
	var new_action_picker: EnemyActionPicker = stats.ai.instantiate()
	add_child(new_action_picker)
	enemy_action_picker = new_action_picker
	enemy_action_picker. enemy = self

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

func update_intent() -> void:
	if current_action:
		current_action.update_intent_text()
		intent_ui.update_intent(current_action.intent)

func do_turn() -> void:
	stats.block = 0
	
	if not current_action:
		return
	
	var allowed_actions := 1
	
	if modifier_handler:
		allowed_actions = modifier_handler.get_modified_value(allowed_actions, Modifier.Type.ACTION_COUNT)
	
	if allowed_actions <= 0:
		print("%s is too Slow to act this turn!" % name)
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
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	var modified_damage := modifier_handler.get_modified_value(damage, which_modifier)
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(modified_damage))
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
