extends CanvasLayer

@onready var text_label: RichTextLabel = $RichTextLabel
@onready var color_rect: ColorRect = $ColorRect

var story_pages: Array[String] = []
var current_page := 0
var is_typing := false
var active_tween: Tween

func _ready() -> void:
	text_label.modulate.a = 0.0
	text_label.visible_ratio = 0
	
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

	await get_tree().create_timer(0.5).timeout
	
	var reveal_tween = create_tween()
	reveal_tween.tween_property(text_label, "modulate:a", 1.0, 0.5)
	await reveal_tween.finished
	
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
	var audio_tween = create_tween()
	audio_tween.tween_property($AudioStreamPlayer, "volume_db", -80, 1.0)
	
	var tween = create_tween()
	tween.tween_property(self, "offset:y", -720, 1.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	get_tree().change_scene_to_file("res://Scene/run/run.tscn")


func get_werkudara_story() -> Array[String]:
	return [
		"Semua amarah ini tidak lahir begitu saja. Ingatanku melesat kembali ke tahun-tahun kelam di [color=gray]Balairung Astina[/color].",
		"Namun, puncak kebiadaban mereka adalah saat [color=red]Dursasana[/color], atas perintah [color=red]Duryudana[/color], menyeret istriku, [color=white]Dewi Drupadi[/color].",
		"Aku melihat mereka mencoba menelanjangi istriku di depan para tetua yang hanya tertunduk bisu. Di sela tawa sinis [color=orange]Sengkuni[/color], hatiku mendidih.",
		"[color=red]\"Demi leluhurku! Aku tidak akan puas sebelum merobek dada Dursasana dengan tanganku sendiri dan meminum darahnya!\"[/color]",
		"Selama tiga belas tahun di pengasingan, bayangan itu terus membakar dadaku. Setiap tetes keringatku adalah tabungan dendam.",
		"Sengkuni, Dursasana, dan Duryudana... mereka adalah noda yang harus kuhapus agar martabat Pandawa kembali suci."
	]

func get_arjuna_story() -> Array[String]:
	return [
		"Bau asap dari perabuan malam tadi masih mencekik paru-paruku. Di padang [color=gray]Kurukshetra[/color] ini, aku menangisi sisa-sisa api yang melahap putraku, [color=white]Abimanyu[/color].",
		"Mereka menjebaknya. Anakku yang malang terkurung dalam labirin [color=gray]Cakrawyuha[/color], dikeroyok oleh para jenderal tua yang telah membuang kehormatan ksatria mereka.",
		"Dan [color=red]Jayadrata[/color]... pengecut itu menyegel jalan keluarnya. Ia menahan kami di luar, memastikan putraku mati dalam kepungan tanpa harapan.",
		"[color=red]\"Demi para dewa! Sebelum matahari terbenam hari ini, panahku akan memutus leher Jayadrata, atau aku sendiri yang akan melompat ke dalam api penyucian!\"[/color]",
		"Namun jalan menuju keadilan dijaga oleh dinding baja. Aku harus menembus pertahanan [color=red]Prabu Salya[/color], paman kami yang kini terjebak sumpah menjadi kusir musuhku.",
		"Dan jika dewata mengizinkan, di penghujung senja nanti takdir terbesarku telah menunggu. [color=orange]Adipati Karna[/color]... bayangan cerminku yang hidup dalam keangkuhan yang buta.",
		"Hari ini, busur [color=white]Gandewa[/color] tidak akan beristirahat. Biarkan anak panah ini yang menyanyikan lagu kematian bagi mereka yang merampas masa depan putraku."
]
