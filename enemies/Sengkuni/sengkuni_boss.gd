class_name Sengkuni
extends Enemy

enum Cheat { NONE, MANA_TAX_ATTACK, MANA_TAX_SKILL }
var current_cheat := Cheat.NONE

@onready var cheat_ui: Node2D = $CheatUI
@onready var cheat_label: Label = $CheatUI/CheatLabel
@onready var speech_bubble: Label = $SpeechBubble
@onready var bubble_base_y: float = speech_bubble.position.y

var speech_tween: Tween

func _ready() -> void:
	super._ready()
	add_to_group("boss")
	
	cheat_ui.modulate.a = 0 
	cheat_ui.scale = Vector2.ZERO
	speech_bubble.modulate.a = 0
	speech_bubble.hide()
	
	Events.battle_setup_completed.connect(_dramatic_entrance)
	Events.card_played.connect(_on_card_played)

func _dramatic_entrance() -> void:
	await get_tree().create_timer(0.6).timeout
	
	Shaker.shake(self, 20, 0.5) 
	var laugh_tween = create_tween().set_loops(3)
	laugh_tween.tween_property(sprite_2d, "position:y", -10, 0.05)
	laugh_tween.tween_property(sprite_2d, "position:y", 0, 0.05)
	
	say_something("Hehehe... bayar pajaknya, Werkudara!", 2.5)
	
	await get_tree().create_timer(1.2).timeout
	
	_roll_the_dice()

func do_turn() -> void:
	is_acting = true 
	if intent_ui:
		intent_ui.hide()
		
	await _roll_the_dice()
	
	await get_tree().create_timer(0.6).timeout
	
	super.do_turn()


func _roll_the_dice() -> void:
	cheat_ui.show()
	cheat_ui.modulate.a = 1.0
	cheat_ui.scale = Vector2.ONE
	
	var roll_tween = create_tween().set_loops(10)
	roll_tween.tween_callback(
		func():
			var random_text = ["MENGACAK DADU...", "PAJAK SKILL?", "PAJAK SERANGAN?", "KOSONG?"]
			cheat_label.text = random_text.pick_random()
	)
	roll_tween.tween_interval(0.05)
	
	await roll_tween.finished
	_lock_in_cheat()

func _lock_in_cheat() -> void:
	current_cheat = Cheat.MANA_TAX_ATTACK if randf() > 0.5 else Cheat.MANA_TAX_SKILL
	
	match current_cheat:
		Cheat.MANA_TAX_ATTACK: cheat_label.text = "PAJAK SERANGAN (+1)"
		Cheat.MANA_TAX_SKILL: cheat_label.text = "PAJAK SKILL (+1)"
	
	Events.boss_rules_changed.emit()
	
	var ui_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	ui_tween.tween_property(cheat_ui, "scale", Vector2(1.2, 1.2), 0.2)
	ui_tween.tween_property(cheat_ui, "scale", Vector2.ONE, 0.2)
	
	if current_cheat == Cheat.MANA_TAX_ATTACK:
		say_something("Senjatamu terlalu berat! Bayar!", 2.0)
	else:
		say_something("Terlalu banyak berpikir! Bayar pajak skill-mu!", 2.0)

# --- THE TAX & MOCKERY ---

func get_mana_tax(card: Card) -> int:
	match current_cheat:
		Cheat.MANA_TAX_ATTACK:
			return 1 if card.type == Card.Type.ATTACK else 0
		Cheat.MANA_TAX_SKILL:
			return 1 if card.type == Card.Type.SKILL else 0
	return 0

func _on_card_played(card: Card) -> void:
	# If the player plays a taxed card, mock them
	if get_mana_tax(card) > 0:
		var insults = ["Terlalu mahal?", "Dompetmu tipis!", "Pajak itu wajib!", "Jangan pelit!"]
		say_something(insults.pick_random(), 1.5)

func say_something(text: String, duration: float = 2.0) -> void:
	if not speech_bubble:
		return
		
	speech_bubble.text = text
	speech_bubble.show()
	
	speech_bubble.position.y = bubble_base_y + 5 
	
	if speech_tween and speech_tween.is_valid():
		speech_tween.kill()
		
	speech_tween = create_tween().set_parallel(false)
	speech_tween.parallel().tween_property(speech_bubble, "modulate:a", 1.0, 0.2)
	speech_tween.parallel().tween_property(speech_bubble, "position:y", bubble_base_y, 0.2)
	speech_tween.chain().tween_interval(duration)
	speech_tween.tween_property(speech_bubble, "modulate:a", 0.0, 0.3)
	speech_tween.tween_callback(speech_bubble.hide)

func _exit_tree() -> void:
	current_cheat = Cheat.NONE
