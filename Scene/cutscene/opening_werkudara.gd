extends CanvasLayer

@onready var text_label: RichTextLabel = $RichTextLabel
@onready var color_rect: ColorRect = $ColorRect

var story_pages: Array[String] = []
var current_page := 0
var is_typing := false
var active_tween: Tween

func _ready() -> void:
	# 1. INITIAL STATE: Keep everything clean and hidden
	# We ensure the label is fully transparent and has no text yet
	text_label.modulate.a = 0.0
	text_label.visible_ratio = 0
	
	# 2. DATA SETUP: Identify character from RunManager
	var character_name = ""
	if RunManager.current_character:
		character_name = RunManager.current_character.character_name
	
	match character_name:
		"Werkudara":
			story_pages = get_werkudara_story()
		"Arjuna":
			story_pages = get_arjuna_story()
		"Yudhistira":
			story_pages = ["Kekhilafanku di meja judi telah merenggut martabat kita. Namun, dharma harus tetap ditegakkan."]
		"Nakula", "Sadewa":
			story_pages = ["Kami berdiri di belakang saudara-saudara kami. Sumpah Pandawa adalah sumpah kami juga."]
		_:
			story_pages = ["Perang Bharatayuddha telah dimulai. Takdir Pandawa ada di tanganmu."]

	# 3. SEAMLESS REVEAL:
	# We wait 0.5 seconds so the transition from the previous scene feels "settled"
	await get_tree().create_timer(0.5).timeout
	
	# Gently fade in the Text Label so it doesn't "snap" in
	var reveal_tween = create_tween()
	reveal_tween.tween_property(text_label, "modulate:a", 1.0, 0.5)
	await reveal_tween.finished
	
	# 4. START STORY
	play_page()

func _input(event: InputEvent) -> void:
	var mouse_clicked = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	var key_pressed = event.is_action_pressed("ui_accept")
	
	if mouse_clicked or key_pressed:
		if event is InputEventKey and event.is_echo(): 
			return
			
		if is_typing:
			skip_typing_animation()
		else:
			advance_to_next_page()

func play_page() -> void:
	is_typing = true
	# In Godot 4.x, ensure 'bbcode_enabled' is checked in the Inspector
	text_label.text = "[center]" + story_pages[current_page] + "[/center]"
	text_label.visible_ratio = 0
	
	if active_tween:
		active_tween.kill()
		
	active_tween = create_tween()
	var duration = story_pages[current_page].length() * 0.03
	active_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	
	active_tween.finished.connect(func(): 
		is_typing = false
	)

func skip_typing_animation() -> void:
	if active_tween:
		active_tween.kill()
	text_label.visible_ratio = 1.0
	is_typing = false

func advance_to_next_page() -> void:
	current_page += 1
	if current_page < story_pages.size():
		play_page()
	else:
		start_game()

func start_game() -> void:
	# Fade out the audio if it's playing
	var audio_tween = create_tween()
	audio_tween.tween_property($AudioStreamPlayer, "volume_db", -80, 1.0)
	
	# Slide the intro away
	var tween = create_tween()
	tween.tween_property(self, "offset:y", -720, 1.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	get_tree().change_scene_to_file("res://Scene/run/run.tscn")

# --- STORY CONTENT ---

func get_werkudara_story() -> Array[String]:
	return [
		"Semua amarah ini tidak lahir begitu saja. Ingatanku melesat kembali ke tahun-tahun kelam di [color=gray]Balairung Astina[/color].",
		"Namun, puncak kebiadaban mereka adalah saat [color=red]Dursasana[/color], atas perintah [color=red]Duryudana[/color], menyeret istriku, [color=white]Dewi Drupadi[/color].",
		"Aku melihat mereka mencoba menelanjangi istriku di depan para tetua yang hanya tertunduk bisu. Di sela tawa sinis [color=orange]Sengkuni[/color], hatiku mendidih.",
		"[color=red]\"Demi leluhurku! Aku tidak akan puas sebelum merobek dada Dursasana dengan tanganku sendiri dan meminum darahnya!\"[/color]",
		"Selama tiga belas tahun di pengasingan, bayangan itu terus membakar dadaku. Setiap tetes keringatku adalah tabungan dendam.",
		"Sengkuni, Dursasana, dan Suryudana... mereka adalah noda yang harus kuhapus agar martabat Pandawa kembali suci."
	]

func get_arjuna_story() -> Array[String]:
	return [
		"Matahari mulai tenggelam di ufuk [color=gray]Kurusetra[/color]. Cahayanya yang jingga terasa seperti luka yang terbuka di langit.",
		"Di sampingku, [color=cyan]Krishna[/color] berdiri tenang. Namun di depanku, bayangan itu semakin nyata. [color=gold]Karna[/color].",
		"Dia adalah cermin dari segala hal yang bisa saja menjadi diriku. Kakak yang terbuang, ksatria yang setia pada janji yang salah.",
		"Dewa-dewa menanti busur [color=white]Gandiwa[/color] beradu dengan busur [color=gold]Vijaya[/color]. Ini bukan sekadar perang. Ini adalah [b]Karna Tanding[/b].",
		"Satu matahari harus tenggelam agar fajar yang baru bisa terbit. Maafkan aku, saudaraku. Hari ini, takdir harus diselesaikan."
	]
