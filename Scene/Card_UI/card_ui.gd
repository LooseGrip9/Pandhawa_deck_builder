class_name CardUI
extends Control

signal reparent_requested(which_card_ui: CardUI)

const BASE_STYLEBOX := preload("uid://bejfgssf7o5x4")
const DRAG_STYLEBOX := preload("uid://lt8vhl320kla")
const HOVER_STYLEBOX := preload("uid://cmvjwhw7catm6")

# --- VISUAL SETTINGS ---
@export_group("Visual Effects")
@export var tilt_intensity: float = 15.0 
@export var scale_amount: float = 1.15 
@export var hover_speed: float = 0.1 
# -----------------------

@export var card: Card : set = _set_card
@export var char_stats: CharacterStats : set = _set_char_stats

# --- UPDATED PATHS FOR CANVAS GROUP ---
@onready var visuals: CanvasGroup = $CanvasGroup
@onready var panel: Panel = $CanvasGroup/Panel
@onready var cost: Label = $CanvasGroup/Panel/Cost
@onready var icon: TextureRect = $CanvasGroup/Panel/Icon
# --------------------------------------

@onready var drop_point_detector: Area2D = $Drop_Point_Detector
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
@onready var targets: Array[Node] = []

var original_index := 0
var parent: Control
var tween: Tween
var hover_tween: Tween # Separate tween for visual effects
var playable := true : set = _set_playable
var disabled := false

# Shader Variables
var _target_rot_x: float = 0.0
var _target_rot_y: float = 0.0

func _ready() -> void:
	# --- VISUAL SETUP ---
	# 1. Center the CanvasGroup so rotation happens from the middle
	var center = panel.size / 2
	visuals.position = center
	
	# 2. Shift children back so they stay visually aligned
	for child in visuals.get_children():
		if child is Control:
			child.position -= center
	
	# 3. Manual Theme Fix (CanvasGroup blocks theme inheritance)
	if theme:
		cost.theme = theme
	# --------------------

	card_state_machine.init(self)
	Events.card_drag_started.connect(_on_card_drag_or_aiming_state_started)
	Events.card_aim_started.connect(_on_card_drag_or_aiming_state_started)
	Events.card_drag_ended.connect(_on_card_drag_or_aim_ended)
	Events.card_aim_ended.connect(_on_card_drag_or_aim_ended)

func _process(delta: float) -> void:
	# Smoothly update shader parameters for the tilt effect
	if not visuals.material:
		return
		
	var current_x = visuals.material.get_shader_parameter("x_rot")
	var current_y = visuals.material.get_shader_parameter("y_rot")
	
	if current_x == null or current_y == null:
		return

	var new_x = lerp(float(current_x), _target_rot_x, delta * 10.0)
	var new_y = lerp(float(current_y), _target_rot_y, delta * 10.0)
	
	visuals.material.set_shader_parameter("x_rot", new_x)
	visuals.material.set_shader_parameter("y_rot", new_y)

func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)
	
	# --- TILT LOGIC ---
	if event is InputEventMouseMotion:
		var center = panel.size / 2
		# Calculate mouse position relative to center
		var local_mouse = panel.get_local_mouse_position() - center
		
		_target_rot_y = (local_mouse.x / center.x) * -tilt_intensity
		_target_rot_x = (local_mouse.y / center.y) * tilt_intensity

func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()
	
	# --- POP UP ANIMATION ---
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	hover_tween.tween_property(visuals, "scale", Vector2.ONE * scale_amount, hover_speed)

func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()
	
	# --- RESET VISUALS ---
	_target_rot_x = 0.0
	_target_rot_y = 0.0
	
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	hover_tween.tween_property(visuals, "scale", Vector2.ONE, hover_speed)

func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)

func play() -> void:
	if not card:
		return
	
	# Added support for single target logic if you have it
	var play_targets: Array[Node] = targets
	
	card.play(play_targets, char_stats)
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
	cost.text = str(card.cost)
	icon.texture = card.icon

func _set_playable(value: bool) -> void:
	playable = value
	if not playable:
		cost.add_theme_color_override("font_color", Color.RED)
		icon.modulate = Color(1, 1, 1, 0.5)
	else:
		cost.remove_theme_color_override("font_color")
		icon.modulate = Color(1, 1, 1, 1)

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	char_stats.stats_changed.connect(_on_char_stats_changed)

func _on_card_drag_or_aiming_state_started(used_card: CardUI) -> void:
	if used_card == self:
		return
	
	disabled = true

func get_aim_start_position() -> Vector2:
	if has_node("AimStart"):
		return $AimStart.global_position
	
	return global_position + Vector2(12.5, 25)
		
func _on_card_drag_or_aim_ended(_card: CardUI) -> void:
	disabled = false
	self.playable = char_stats.can_play_card(card)

func _on_char_stats_changed() -> void:
	self.playable = char_stats.can_play_card(card)
