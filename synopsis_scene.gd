extends Control

@onready var story_text: RichTextLabel = $StoryText

const NEXT_SCENE_PATH = "res://Scene/UI/character_selector.tscn" 

var pages: Array = [
	"Epos Mahabharata bukan sekadar kisah peperangan, melainkan cermin bagi jiwa manusia.\n\nKisah ini bermula dari keserakahan Kurawa yang merampas takhta Hastinapura melalui kelicikan di atas meja dadu.",
	"Setelah 13 tahun menderita dalam pengasingan, segala upaya damai dari pihak Pandhawa telah diusahakan. Namun, kesombongan menolak keadilan.\n\nDemi menegakkan [color=#ffd700][b]Dharma[/b][/color] (kebenaran), pedang pada akhirnya terpaksa dihunus.",
	"Di padang Kurusetra, pecahlah perang suci [color=#ff0000][b]Bharatayuddha[/b][/color]. \n\nIni bukanlah sekadar ajang balas dendam, melainkan ujian berat di mana para ksatria harus memerangi guru dan kerabat mereka sendiri demi membasmi kebatilan.",
    "Melalui perjalanan ini, pelajarilah makna tanggung jawab, keteguhan hati, dan pengorbanan.\n\nSiapakah ksatria yang akan kau telusuri jejak langkah dan nilai moralnya?"
]

var current_page: int = 0
var tween: Tween

func _ready() -> void:
	story_text.bbcode_enabled = true
	play_page(current_page)

func play_page(page_index: int) -> void:
	story_text.text = pages[page_index]
	story_text.visible_characters = 0
	
	await get_tree().process_frame 
	
	var total_chars = story_text.get_total_character_count()
	var duration = total_chars * 0.04 
	
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween()
	
	if total_chars > 0:
		tween.tween_property(story_text, "visible_characters", total_chars, duration)
	else:
		story_text.visible_characters = -1 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		
		var total_chars = story_text.get_total_character_count()
		
		if story_text.visible_characters < total_chars and story_text.visible_characters != -1:
			if tween and tween.is_running():
				tween.kill()
			story_text.visible_characters = total_chars
			
		else:
			current_page += 1
			if current_page < pages.size():
				play_page(current_page) 
			else:
				transition_to_game()

func transition_to_game() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/character_selector.tscn")
