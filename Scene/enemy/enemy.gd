class_name Sengkuni
extends Enemy

@onready var cheat_label: Label = $CheatUI/CheatLabel
@onready var speech_bubble: Label = $SpeechBubble
@onready var bubble_base_y: float = speech_bubble.position.y

func _ready() -> void:
	super._ready()
	Events.battle_setup_completed.connect(_dramatic_entrance)

func _dramatic_entrance() -> void:
	say_something("Rasakan Jerat Sengkuni, Werkudara!")
	await get_tree().create_timer(1.0).timeout
	_roll_the_dice()

func do_turn() -> void:
	is_acting = true
	if intent_ui: intent_ui.hide()
	await _roll_the_dice()
	super.do_turn()

func _roll_the_dice() -> void:
	# Visual "Rolling" effect
	for i in range(10):
		cheat_label.text = ["MENGACAK...", "JERAT SKILL?", "JERAT SERANGAN?"].pick_random()
		await get_tree().create_timer(0.05).timeout
	
	_apply_jerat()

func _apply_jerat() -> void:
	var is_attack = randf() > 0.5
	cheat_label.text = "JERAT SERANGAN" if is_attack else "JERAT SKILL"
	
	# Apply Status to Player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Remove old jerat first
		for s in player.status_handler.get_statuses():
			if s is StatusJeratSengkuni: player.status_handler.remove_status(s)
		
		# Add new jerat
		var snare = preload("res://statuses/jerat_sengkuni.tres").duplicate()
		snare.target_type = 0 if is_attack else 1 # 0=Attack, 1=Skill
		snare.stacks = 1
		player.status_handler.add_status(snare)
	
	Events.boss_rules_changed.emit()
	say_something("Satu langkah salah, dan kau terjepit!")

func say_something(text: String) -> void:
	speech_bubble.text = text
	speech_bubble.show()
	var t = create_tween()
	t.tween_property(speech_bubble, "modulate:a", 1.0, 0.2)
	t.tween_interval(1.5)
	t.tween_property(speech_bubble, "modulate:a", 0.0, 0.2)
	t.tween_callback(speech_bubble.hide)
