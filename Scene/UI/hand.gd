class_name Hand
extends Control

@export var player: Player
@export var char_stats: CharacterStats
@onready var card_ui := preload("res://Scene/Card_UI/card_ui.tscn")

@export_group("Hand Curves")
@export var height_curve: Curve 
@export var rotation_curve: Curve

@export_group("Hand Settings")
@export var x_separation: float = 30.0
@export var y_amplitude: float = 20.0 
@export var rot_intensity: float = 10.0
@export var lerp_speed: float = 10.0 

func _process(delta: float) -> void:
	update_card_positions(delta)

func update_card_positions(delta: float) -> void:
	var cards = get_children()
	if cards.is_empty():
		return
	
	var total_width = (cards.size() - 1) * x_separation
	var start_x = -total_width / 2.0
	
	for i in range(cards.size()):
		var card = cards[i]
		
		if not card is CardUI:
			continue
			
		if card.card_state_machine.current_state:
			var state_name = card.card_state_machine.current_state.name
			if state_name == "Drag" or state_name == "Aiming":
				continue

		var t: float = 0.5
		if cards.size() > 1:
			t = float(i) / float(cards.size() - 1)
			
		var target_x = start_x + (i * x_separation)
		var target_y = 0.0
		var target_rot = 0.0
		
		if height_curve:
			target_y = -height_curve.sample(t) * y_amplitude
			
		if rotation_curve:
			target_rot = rotation_curve.sample(t) * rot_intensity
		
		card.position = card.position.lerp(Vector2(target_x, target_y), lerp_speed * delta)
		card.rotation_degrees = lerp(card.rotation_degrees, target_rot, lerp_speed * delta)

func add_card(card: Card) -> void:
	var new_card_ui := card_ui.instantiate()
	add_child(new_card_ui)
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.card = card
	new_card_ui.parent = self
	new_card_ui.char_stats = char_stats
	new_card_ui.player_modifiers = player.modifier_handler

func discard_card(card: CardUI) -> void:
	card.queue_free()

func disable_hand() -> void:
	for card in get_children():
		card.disabled = true

func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
	var new_index := clampi(child.original_index, 0, get_child_count())
	move_child.call_deferred(child, new_index)
