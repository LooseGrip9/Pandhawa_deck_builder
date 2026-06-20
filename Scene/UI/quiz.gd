extends Control

@onready var BackGroundSprite: Sprite2D = $BackGroundSprite
@onready var pertanyaan_label: RichTextLabel = $MarginContainer/VBoxContainer1/PertanyaanLabel
@onready var opsi_container: GridContainer = $MarginContainer/VBoxContainer1/OpsiContainer
@onready var judul_kuis: Label = $MarginContainer/VBoxContainer1/JudulKuis

@onready var popup_feedback: ColorRect = %PopUpFeedback
@onready var status_label: Label = $PopUpFeedback/CenterContainer/VBoxContainer2/StatusLabel

# Diubah menjadi 3 karena setiap bos memiliki 3 pertanyaan spesifik
const TOTAL_PERTANYAAN := 3

# =========================================================
# DATABASE WERKUDARA (Berdasarkan Urutan Boss)
# =========================================================
var kuis_werkudara_boss1: Array = [
	{
		"tanya": "Berdasarkan dialog pembuka, apa tuduhan utama Werkudara kepada Sengkuni terkait peristiwa di balairung Hastinapura?",
		"opsi": ["Sengkuni mencuri pusaka keraton", "Sengkuni memanipulasi dadu dan merancang penghinaan", "Sengkuni menantang Yudhistira berduel fisik", "Sengkuni membakar perkemahan Pandawa"],
		"jawaban": "Sengkuni memanipulasi dadu dan merancang penghinaan"
	},
	{
		"tanya": "Dalam dialognya, Sengkuni mengakui bahwa ia sudah tua. Apa yang ia sebut sebagai andalannya untuk mengalahkan Werkudara?",
		"opsi": ["Pedang beracun", "Pasukan pemanah", "Pasukan gajah raksasa", "Sihir Gandhara dan jebakan"],
		"jawaban": "Sihir Gandhara dan jebakan"
	},
	{
		"tanya": "Peristiwa kelam kelicikan Sengkuni mencerminkan sifat buruk yang sangat ditentang dalam budaya kita, yaitu...",
		"opsi": ["Menghalalkan segala cara dan memanipulasi kebenaran", "Terlalu berani mengambil risiko", "Sifat pasrah dan tidak berusaha", "Sifat hemat berlebihan"],
		"jawaban": "Menghalalkan segala cara dan memanipulasi kebenaran"
	}
]

var kuis_werkudara_boss2: Array = [
	{
		"tanya": "Saat Werkudara berhadapan dengan Dursasana di medan perang, di manakah posisi Dursasana karena ketakutannya?",
		"opsi": ["Bersembunyi di balik barisan perisai pengawalnya", "Di atas bukit yang sangat tinggi", "Di dalam istana Hastinapura", "Di dasar Danau Dwaita"],
		"jawaban": "Bersembunyi di balik barisan perisai pengawalnya"
	},
	{
		"tanya": "Menurut teriakan Werkudara, sumpah apa yang diucapkan oleh Drupadi setelah peristiwa pelecehan di masa lalu?",
		"opsi": ["Tidak memakai perhiasan emas", "Mengasingkan diri ke hutan", "Tidak akan menyanggul rambut sebelum dicuci darah Dursasana", "Akan membakar istana Hastinapura"],
		"jawaban": "Tidak akan menyanggul rambut sebelum dicuci darah Dursasana"
	},
	{
		"tanya": "Saat menghukum Dursasana, game mengingatkan prinsip 'Ngundhuh Wohing Pakarti'. Nilai moral dari filosofi ini adalah...",
		"opsi": ["Kekuatan fisik penentu segalanya", "Dendam harus dibalas dendam", "Setiap perbuatan (baik/jahat) pasti ada balasannya", "Kita bebas asal tidak ada yang melihat"],
		"jawaban": "Setiap perbuatan (baik/jahat) pasti ada balasannya"
	}
]

var kuis_werkudara_boss3: Array = [
	{
		"tanya": "Apa hal yang dibanggakan oleh Duryudana mengenai kondisi fisiknya saat menantang Werkudara di duel pamungkas?",
		"opsi": ["Bisa beregenerasi", "Tenaga seratus gajah", "Tubuhnya kebal terhadap segala senjata", "Bisa menghilang menjadi bayangan"],
		"jawaban": "Tubuhnya kebal terhadap segala senjata"
	},
	{
		"tanya": "Dalam perdebatan mereka, siapakah yang disalahkan oleh Duryudana atas kematian Bisma, Drona, dan Karna?",
		"opsi": ["Kesalahan Prabu Salya", "Tipu muslihat licik dari pihak Pandawa", "Kutukan para dewa", "Pengkhianatan pasukan sekutu"],
		"jawaban": "Tipu muslihat licik dari pihak Pandawa"
	},
	{
		"tanya": "Filosofi 'Suro Diro Joyo Ningrat, Lebur Dening Pangastuti' mengajarkan bahwa...",
		"opsi": ["Keangkuhan dan kekuasaan semena-mena pasti kalah oleh kebenaran", "Kekuatan militer pelindung terbaik", "Harus lebih licik dari musuh", "Kekuasaan tinggi tidak bisa dikalahkan"],
		"jawaban": "Keangkuhan dan kekuasaan semena-mena pasti kalah oleh kebenaran"
	}
]

# =========================================================
# DATABASE ARJUNA (Berdasarkan Urutan Boss)
# =========================================================
var kuis_arjuna_boss1: Array = [
	{
		"tanya": "Bagaimana Arjuna menjelaskan peran spesifik Jayadrata dalam tragedi yang menimpa Abimanyu?",
		"opsi": ["Memanah Abimanyu dari belakang", "Menyegel jalan keluar formasi Cakrawyuha", "Mencuri senjata Abimanyu", "Menantang duel satu lawan satu"],
		"jawaban": "Menyegel jalan keluar formasi Cakrawyuha"
	},
	{
		"tanya": "Berdasarkan dialog, strategi apa yang dipakai Jayadrata untuk bertahan hidup hingga matahari terbenam?",
		"opsi": ["Kuda terbang", "Menggali terowongan", "Bersembunyi di balik sejuta prajurit dan benteng", "Menyamar jadi prajurit biasa"],
		"jawaban": "Bersembunyi di balik sejuta prajurit dan benteng"
	},
	{
		"tanya": "Sikap pengecut Jayadrata mengajarkan kita peringatan moral agar tidak...",
		"opsi": ["Mundur jika musuh canggih", "Membiarkan ketidakadilan terjadi dan menindas yang lemah", "Membantu orang miskin", "Terlalu cepat mengambil keputusan"],
		"jawaban": "Membiarkan ketidakadilan terjadi dan menindas yang lemah"
	}
]

var kuis_arjuna_boss2: Array = [
	{
		"tanya": "Arjuna menyebutkan alasan mengapa pamannya itu kini terpaksa berada di pihak Kurawa. Apa alasannya?",
		"opsi": ["Salya diusir Pandawa", "Salya dibayar Duryudana", "Salya ditipu di tengah jalan sehingga terjebak sumpah", "Salya membenci Pandawa"],
		"jawaban": "Salya ditipu di tengah jalan sehingga terjebak sumpah"
	},
	{
		"tanya": "Menurut ucapan Arjuna, serangan apa dari Prabu Salya yang paling dikhawatirkan meruntuhkan akal sehatnya?",
		"opsi": ["Panah api", "Cambuk sakti", "Ilusi optik", "Kata-kata (lidah) tajam dan cemoohannya"],
		"jawaban": "Kata-kata (lidah) tajam dan cemoohannya"
	},
	{
		"tanya": "Peristiwa Arjuna melawan Salya membawa pesan 'Jer Basuki Mawa Beya', yang berarti...",
		"opsi": ["Mewujudkan keadilan selalu menuntut pengorbanan", "Kesuksesan bisa dicapai instan", "Lebih baik menyerah jika berat", "Boleh mengorbankan teman demi karir"],
		"jawaban": "Mewujudkan keadilan selalu menuntut pengorbanan"
	}
]

var kuis_arjuna_boss3: Array = [
	{
		"tanya": "Apa alasan yang diucapkan Karna sehingga ia bersikeras menganggap kesetiaannya pada Duryudana adalah dharma-nya?",
		"opsi": ["Takut dibunuh", "Ingin merebut takhta", "Duryudana satu-satunya yang mengangkat derajatnya", "Dijanjikan kekuasaan tanpa batas"],
		"jawaban": "Duryudana satu-satunya yang mengangkat derajatnya"
	},
	{
		"tanya": "Di tengah pertarungan, keretanya tertahan. Menurut Karna, apa yang menahannya?",
		"opsi": ["Dipaku Arjuna", "Kudanya mati", "Beban zirah emas", "Kutukan masa lalunya yang menahan keretanya"],
		"jawaban": "Kutukan masa lalunya yang menahan keretanya"
	},
	{
		"tanya": "Arjuna meresapi prinsip 'Narimo ing Pandum' di akhir pertarungan. Ini mengajarkan sikap mental...",
		"opsi": ["Menyerah pada nasib", "Berikhtiar maksimal lalu ikhlas menerima hasil akhir", "Menuntut lebih dari yang didapat", "Mengandalkan orang lain"],
		"jawaban": "Berikhtiar maksimal lalu ikhlas menerima hasil akhir"
	}
]

# =========================================================

var pertanyaan_terpilih: Array = []
var indeks_saat_ini: int = 0
var skor_pemain: int = 0
var menunggu_klik_lanjut: bool = false 
var kuis_tamat: bool = false

func _ready() -> void:
	popup_feedback.hide()
	menunggu_klik_lanjut = false
	kuis_tamat = false
	
	var nama_karakter = RunManager.current_character.character_name if RunManager.current_character else "Arjuna"
	var row_peta = RunManager.baris_kamar_saat_ini
	var data_kuis_aktif: Array = []
	
	# Memilih kuis berdasarkan karakter dan baris (lantai) saat ini
	if nama_karakter == "Werkudara":
		if row_peta < 15:
			data_kuis_aktif = kuis_werkudara_boss1.duplicate()
		elif row_peta < 30:
			data_kuis_aktif = kuis_werkudara_boss2.duplicate()
		else:
			data_kuis_aktif = kuis_werkudara_boss3.duplicate()
	else:
		if row_peta < 15:
			data_kuis_aktif = kuis_arjuna_boss1.duplicate()
		elif row_peta < 30:
			data_kuis_aktif = kuis_arjuna_boss2.duplicate()
		else:
			data_kuis_aktif = kuis_arjuna_boss3.duplicate()
	
	data_kuis_aktif.shuffle()
	pertanyaan_terpilih = data_kuis_aktif.slice(0, TOTAL_PERTANYAAN)
	
	tampilkan_kuis()

func tampilkan_kuis() -> void:
	popup_feedback.hide()
	menunggu_klik_lanjut = false
	
	for tombol in opsi_container.get_children():
		tombol.disabled = false
	
	judul_kuis.text = "EVALUASI BOS (" + str(indeks_saat_ini + 1) + " / " + str(TOTAL_PERTANYAAN) + ")"
	
	var kuis_saat_ini = pertanyaan_terpilih[indeks_saat_ini]
	pertanyaan_label.text = "[center]" + kuis_saat_ini["tanya"] + "[/center]"
	
	var opsi_acak = kuis_saat_ini["opsi"].duplicate()
	opsi_acak.shuffle()
	
	var tombol_tombol = opsi_container.get_children()
	for i in range(tombol_tombol.size()):
		var tombol = tombol_tombol[i] as Button
		tombol.text = opsi_acak[i]
		
		if tombol.pressed.is_connected(_on_opsi_pressed):
			tombol.pressed.disconnect(_on_opsi_pressed)
		tombol.pressed.connect(_on_opsi_pressed.bind(tombol.text))

func _on_opsi_pressed(jawaban_pemain: String) -> void:
	for tombol in opsi_container.get_children():
		tombol.disabled = true
	
	var kuis_saat_ini = pertanyaan_terpilih[indeks_saat_ini]
	
	if jawaban_pemain == kuis_saat_ini["jawaban"]:
		status_label.text = "BENAR!"
		status_label.modulate = Color.GREEN
		skor_pemain += 1
	else:
		status_label.text = "SALAH!\nJawaban benar: " + kuis_saat_ini["jawaban"]
		status_label.modulate = Color.RED
	
	popup_feedback.show()
	await get_tree().create_timer(0.1).timeout
	menunggu_klik_lanjut = true

func _input(event: InputEvent) -> void:
	if menunggu_klik_lanjut:
		if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or event.is_action_pressed("ui_accept"):
			menunggu_klik_lanjut = false
			
			if kuis_tamat:
				Events.quiz_completed.emit()
				queue_free()
			else:
				lanjut_pertanyaan()

func lanjut_pertanyaan() -> void:
	indeks_saat_ini += 1
	
	if indeks_saat_ini < TOTAL_PERTANYAAN:
		tampilkan_kuis()
	else:
		_selesaikan_kuis()

func _selesaikan_kuis() -> void:
	kuis_tamat = true
	
	# Kalkulasi skor skala 0-100
	var skor_akhir := int((float(skor_pemain) / TOTAL_PERTANYAAN) * 100)
	
	print("Kuis Selesai! Skor Akhir: ", skor_akhir)
	
	status_label.text = "KUIS SELESAI!\nSkor Anda: " + str(skor_akhir)
	status_label.modulate = Color.YELLOW 
	
	popup_feedback.show()
	await get_tree().create_timer(0.1).timeout
	menunggu_klik_lanjut = true

func _process(_delta):
	if BackGroundSprite and BackGroundSprite.texture:
		var tex = BackGroundSprite.texture
		var screen_size = get_viewport_rect().size
		BackGroundSprite.scale = screen_size / tex.get_size()
