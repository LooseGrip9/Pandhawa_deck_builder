extends CanvasLayer

signal cutscene_finished 

@onready var story_label: RichTextLabel = %EndingLabel

var current_line := 0
var lines: Array[String] = []
var tween: Tween

func _ready() -> void:
	story_label.visible_ratio = 0.0

func setup_ending(boss_id: String) -> void:
	match boss_id:
		"Duryudana":
			lines = [
				"Gada itu jatuh menghantam debu [color=gray]Kurukshetra[/color] dengan berat.",
				"[color=red]Duryudana[/color], Raja Kurawa yang angkuh, akhirnya telah gugur.",
				"Perang delapan belas hari itu berakhir dalam kesunyian yang berdarah.",
				"Pandawa bersaudara berdiri sebagai pemenang...",
				"...namun mereka berdiri di atas pusara saudara mereka sendiri.",
				"Dharma telah ditegakkan."
			]
		"Karna":
			lines = [
				"Roda kereta itu tetap tertancap tak berdaya di dalam lumpur.",
				"Panah [color=white]Arjuna[/color] telah menemukan sasarannya, memenuhi takdir yang tertulis di bintang.",
				"Seorang kakak telah gugur di tangan adiknya sendiri.",
				"Matahari terbenam bagi ksatria terhebat yang pernah dikenal dunia.",
				"Kemenangan terasa sepahit abu di mulut para [color=white]Pandawa[/color]."
			]
		_:
			lines = ["Perang Bharatayuddha telah berakhir. Dharma telah ditegakkan."]
	_show_next_line()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse") or event.is_action_pressed("ui_accept"):
		if story_label.visible_ratio < 1.0:
			if tween: tween.kill()
			story_label.visible_ratio = 1.0
		else:
			_show_next_line()

func _show_next_line() -> void:
	if current_line < lines.size():
		story_label.text = "[center]" + lines[current_line] + "[/center]"
		story_label.visible_ratio = 0.0
		var duration = lines[current_line].length() * 0.03
		current_line += 1
		
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(story_label, "visible_ratio", 1.0, duration)
	else:
		_finish_ending()

func _finish_ending() -> void:
	# FIX: CanvasLayer doesn't have modulate, so we fade the label instead
	var fade = create_tween()
	
	# Fade the text
	fade.tween_property(story_label, "modulate:a", 0.0, 0.5)
	
	# If you have a background node, fade it too so the screen doesn't "pop"
	# Adjust "$ColorRect" to match your actual background node name
	if has_node("ColorRect"):
		fade.parallel().tween_property($ColorRect, "modulate:a", 0.0, 0.5)
	
	# Crucial: This await will now finish because the properties exist!
	await fade.finished
	
	cutscene_finished.emit()
	queue_free()
