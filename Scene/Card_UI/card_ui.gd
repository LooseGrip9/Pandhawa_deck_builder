class_name CardUI
extends Control

signal reparent_requested(which_card_ui: CardUI)

const BASE_STYLEBOX := preload("uid://bejfgssf7o5x4")
const DRAG_STYLEBOX := preload("uid://lt8vhl320kla")
const HOVER_STYLEBOX := preload("uid://cmvjwhw7catm6")

@export_group("Visual Effects")
@export var tilt_intensity: float = 15.0 
@export var scale_amount: float = 1.15 
@export var hover_speed: float = 0.1 

@export var player_modifiers: ModifierHandler
@export var card: Card : set = _set_card
@export var char_stats: CharacterStats : set = _set_char_stats

@onready var card_visuals: CardVisuals = $CardVisuals
@onready var canvas_group: CanvasGroup = $CardVisuals/CanvasGroup
@onready var drop_point_detector: Area2D = $Drop_Point_Detector
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
@onready var targets: Array[Node] = []

var original_index := 0
var parent: Control
var tween: Tween
var hover_tween: Tween 
var playable := true : set = _set_playable
var disabled := false
var cost_override: int = -1

var _target_rot_x: float = 0.0
var _target_rot_y: float = 0.0

func _ready() -> void:
	
	add_to_group("cards_in_hand")
	var center = card_visuals.size / 2
	card_visuals.position = center
	
	for child in card_visuals.get_children():
		if child is CanvasItem:
			child.position -= center
	if theme:
		card_visuals.theme = theme
		
	card_state_machine.init(self)
	Events.card_drag_started.connect(_on_card_drag_or_aiming_state_started)
	Events.card_aim_started.connect(_on_card_drag_or_aiming_state_started)
	Events.card_drag_ended.connect(_on_card_drag_or_aim_ended)
	Events.card_aim_ended.connect(_on_card_drag_or_aim_ended)

func _process(delta: float) -> void:
	if not canvas_group.material:
		return
	var current_x = canvas_group.material.get_shader_parameter("x_rot")
	var current_y = canvas_group.material.get_shader_parameter("y_rot")
	if current_x == null or current_y == null:
		return
	var new_x = lerp(float(current_x), _target_rot_x, delta * 10.0)
	var new_y = lerp(float(current_y), _target_rot_y, delta * 10.0)
	canvas_group.material.set_shader_parameter("x_rot", new_x)
	canvas_group.material.set_shader_parameter("y_rot", new_y)

func get_active_enemy_modifier() -> ModifierHandler:
	if targets.is_empty() or targets.size() > 1 or not targets[0] is Enemy:
		return null
	return targets[0].modifier_handler

func request_tooltip() -> void:
	var enemy_modifiers := get_active_enemy_modifier()
	var updated_tooltip := card.get_updated_tooltip(player_modifiers, enemy_modifiers)
	Events.card_tooltip_requested.emit(card.icon, updated_tooltip)

func _input(event: InputEvent) -> void:
	if disabled:
		return
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	if disabled:
		return
	card_state_machine.on_gui_input(event)
	if event is InputEventMouseMotion:
		var center = card_visuals.size / 2
		var local_mouse = card_visuals.get_local_mouse_position() - center
		_target_rot_y = (local_mouse.x / center.x) * -tilt_intensity
		_target_rot_x = (local_mouse.y / center.y) * tilt_intensity

func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()
	var stylebox: StyleBoxFlat = HOVER_STYLEBOX.duplicate()
	stylebox.bg_color = card.RARITY_COLORS[card.rarity].lightened(0.1)
	card_visuals.panel.add_theme_stylebox_override("panel", stylebox)
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	hover_tween.tween_property(card_visuals, "scale", Vector2.ONE * scale_amount, hover_speed)

func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()
	var stylebox: StyleBoxFlat = BASE_STYLEBOX.duplicate()
	stylebox.bg_color = card.RARITY_COLORS[card.rarity]
	card_visuals.panel.add_theme_stylebox_override("panel", stylebox)
	_target_rot_x = 0.0
	_target_rot_y = 0.0
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	hover_tween.tween_property(card_visuals, "scale", Vector2.ONE, hover_speed)

func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)

func play() -> void:
	if not card:
		return
	var play_targets: Array[Node] = targets
	card.play(play_targets, char_stats, player_modifiers)
	queue_free()

func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)

func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	targets.erase(area)

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	card = value
	card_visuals.card = card

func _set_playable(value: bool) -> void:
	playable = value
	if not playable:
		card_visuals.add_theme_color_override("font_color", Color.RED)
		card_visuals.modulate = Color(1, 1, 1, 0.5)
	else:
		card_visuals.remove_theme_color_override("font_color")
		card_visuals.modulate = Color(1, 1, 1, 1)

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	if not char_stats.stats_changed.is_connected(_on_char_stats_changed):
		char_stats.stats_changed.connect(_on_char_stats_changed)
	_on_char_stats_changed()

func _on_card_drag_or_aiming_state_started(used_card: CardUI) -> void:
	if used_card == self:
		var stylebox: StyleBoxFlat = DRAG_STYLEBOX.duplicate()
		stylebox.bg_color = card.RARITY_COLORS[card.rarity]
		card_visuals.panel.add_theme_stylebox_override("panel", stylebox)
		return
	disabled = true

func get_aim_start_position() -> Vector2:
	if card_visuals.has_node("AimStart"):
		return card_visuals.get_node("AimStart").global_position
	if has_node("AimStart"):
		return $AimStart.global_position
	return global_position + (size / 2)
		
func _on_card_drag_or_aim_ended(_card: CardUI) -> void:
	disabled = false
	call_deferred("_recheck_playability")
	if _card == self:
		var stylebox: StyleBoxFlat = BASE_STYLEBOX.duplicate()
		stylebox.bg_color = card.RARITY_COLORS[card.rarity]
		card_visuals.panel.add_theme_stylebox_override("panel", stylebox)

func _on_char_stats_changed() -> void:
	_recheck_playability()

# CardUI.gd

func _recheck_playability() -> void:
	var player_handler = get_tree().get_first_node_in_group("player_handler")
	var is_free = player_handler and player_handler.next_card_is_free
	
	var current_cost = card.cost
	if is_free:
		current_cost = 0
	elif cost_override != -1:
		current_cost = cost_override

	var is_modified = is_free or (cost_override != -1 and cost_override != card.cost)
	card_visuals.update_cost(current_cost, is_modified)

	var can_afford = char_stats.mana >= current_cost
	
	var requirements_met = true
	if card.has_method("is_playable"):
		requirements_met = card.is_playable(get_parent())
		
	self.playable = can_afford and requirements_met
