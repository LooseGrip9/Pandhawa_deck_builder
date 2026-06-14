extends Control

@onready var background_sprite: Sprite2D = $BackgroundSprite
@onready var color_rect: ColorRect = $OverlayGelap
@onready var story_text: RichTextLabel = $RichTextLabel

var data_werkudara: Array = [
	{
		"cerita": [
			"Di pelataran candi yang dingin ini, kabut sihir [color=orange]Sengkuni[/color] berusaha merayap masuk ke dalam pikiranmu.",
			"Kau memejamkan mata, memegang teguh ajaran ksatria: [color=white]'Blaka Suta'[/color]. Berbicara apa adanya, tanpa topeng, tanpa kemunafikan.",
			"Bahasa yang bermanis-manis sering kali diciptakan oleh para tiran untuk menyembunyikan niat busuk dan meninggikan derajat mereka di atas yang lain.",
			"Namun di matamu, semua manusia lahir setara. Kejujuranmu yang lugas bukanlah sebuah kekasaran, melainkan wujud keadilan yang menolak kompromi dengan kebohongan."
		],
		"gambar": preload("res://art/werkudara_1.png") 
	},
	{
		"cerita": [
			"Udara terasa panas. Di balik barisan perisai di kejauhan, [color=red]Dursasana[/color] bersembunyi. Tanganmu bergetar menahan amarah yang telah mengendap belasan tahun.",
			"Tahan napasmu, Werkudara. Ingatlah hukum alam yang tak pernah tidur: [color=white]'Ngundhuh Wohing Pakarti'[/color].",
			"Setiap manusia diberi kebebasan untuk bertindak, namun tidak ada satupun yang bisa lari dari konsekuensi tindakannya. Masa lalu akan selalu menagih hutangnya.",
			"Kau bukan algojo yang digerakkan oleh dendam buta. Kau adalah instrumen alam semesta yang hadir untuk menyeimbangkan kembali timbangan keadilan."
		],
		"gambar": preload("res://art/werkudara_2.png")
	},
	{
		"cerita":[
			"Tinggal satu langkah lagi. Sang Raja, [color=red]Duryudana[/color], menantangmu dengan tubuh yang dibalut mantra kebal senjata.",
			"Dihadapkan pada kekuatan yang mustahil, jiwa leluhur berbisik di batinmu: [color=white]'Suro Diro Joyo Ningrat, Lebur Dening Pangastuti'[/color].",
			"Segala bentuk kekuasaan, kesaktian, dan keangkuhan duniawi pasti akan hancur oleh kelembutan nurani dan kebenaran sejati.",
			"Kekuatan tertinggimu bukanlah pada otot atau [color=white]Gada Rujakpolo[/color], melainkan pada kemurnian niatmu. Biarkan kesombongannya menjadi beban yang akan meremukkan dirinya sendiri."
		],
		"gambar": preload("res://art/werkudara_3.png")
	}
]

var data_arjuna: Array = [
	{
		"cerita": [
			"Matahari bergeser turun, membawa batas waktumu semakin dekat. Di balik benteng prajurit, [color=red]Jayadrata[/color] menanti kegagalanmu.",
			"Kematian [color=white]Abimanyu[/color] merobek nuranimu, memancing amarah yang membutakan. Namun kau tahu, anak panah takkan mengenai sasaran jika ditarik oleh lengan yang gemetar karena emosi.",
			"Resapi ajaran [color=white]'Lembah Manah'[/color]. Kerendahan hati menuntunmu pada ketenangan batin. Kecerdasan sejati bermula dari penguasaan diri.",
			"Jernihkan pikiranmu dari kabut duka. Ubah keputusasaan menjadi fokus mutlak yang akan menuntun panahmu menembus ruang dan waktu."
		],
		"gambar": preload("res://art/werkudara_1.png")
	},
	{
		"cerita": [
			"Di ufuk sana, kereta [color=red]Prabu Salya[/color] menghalangimu. Kau dihadapkan pada pilihan tersulit: mengangkat senjata melawan pamanmu sendiri.",
			"Suara sang kusir agung bergema memecah kebimbanganmu: [color=white]'Jer Basuki Mawa Beya'[/color]. Setiap kedamaian dan kebaikan selalu menuntut harga yang harus dibayar.",
			"Integritas tidak datang dengan mudah. Menegakkan kebenaran sering kali memaksamu menebas rantai kepentingan pribadi dan menelan getirnya pengorbanan.",
			"Teguhkan pendirianmu. Kesedihan yang kau pikul hari ini adalah pondasi bagi keadilan dan kedamaian dunia di masa depan."
		],
		"gambar": preload("res://art/werkudara_2.png")
	},
	{
		"cerita": [
			"Kereta emas [color=orange]Adipati Karna[/color] memantulkan cahaya terik Kurukshetra. Jantungmu berdegup kencang menyadari saat penentuan nasib telah tiba.",
			"Kau memandang rival abadimu. Di titik ini, ajaran [color=white]'Narimo ing Pandum'[/color] merasuk ke dalam relung jiwamu.",
			"Ini bukanlah kepasrahan yang lemah. Ini adalah puncak kesadaran ksatria: berjuang hingga batas terakhir kemampuan manusia, lalu melepaskan keangkuhan atas hasilnya.",
			"Tanggalkan ego yang ingin membuktikan siapa yang terhebat. Lakukan tugasmu dengan ikhlas, dan biarkan semesta yang menentukan akhir dari kisah ini."
		],
		"gambar": preload("res://art/werkudara_3.png")
	}
]

var halaman_cerita: Array = []
var current_page: int = 0
var tween: Tween

func _ready() -> void:
	story_text.bbcode_enabled = true
	
	var nama_karakter = RunManager.current_character.character_name if RunManager.current_character else "Arjuna"
	var data_terpilih: Dictionary
	
	# MEMBACA LANGSUNG DARI RUN MANAGER
	var row_peta = RunManager.baris_kamar_saat_ini
	var index_cerita = clampi(floori(row_peta / 15.0), 0, 2)
	
	print("DEBUG: Baris Peta = ", row_peta, " | Tampil Cerita = ", index_cerita)
	
	if nama_karakter == "Werkudara":
		data_terpilih = data_werkudara[index_cerita]
	else:
		data_terpilih = data_arjuna[index_cerita]
	
	halaman_cerita = data_terpilih["cerita"]
	
	var texture_gambar = data_terpilih["gambar"]
	background_sprite.texture = texture_gambar
	
	await get_tree().process_frame
	skala_sprite_ke_layar(texture_gambar)
	
	play_page(0)

func skala_sprite_ke_layar(tex: Texture2D) -> void:
	if tex == null: return
	
	var img_size = tex.get_size()
	var screen_size = get_viewport_rect().size
	var scale_factor = screen_size / img_size
	
	background_sprite.scale = scale_factor

func play_page(page_index: int) -> void:
	story_text.text = halaman_cerita[page_index]
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
			if current_page < halaman_cerita.size():
				play_page(current_page)
			else:
				akhiri_event()

func akhiri_event() -> void:
	Events.room_exited.emit()
	queue_free()
