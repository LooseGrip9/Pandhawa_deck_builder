class_name Tooltip
extends PanelContainer

@export var fade_seconds = 0.2
@export var scroll_speed = 30.0
@export var scroll_delay = 1.5

@onready var tooltip_icon: TextureRect = %TooltipIcon
@onready var tooltip_text_label: RichTextLabel = %TooltipText

var tween: Tween
var scroll_tween: Tween
var is_visible:= true

func _ready() -> void:
	Events.card_tooltip_requested.connect(show_tooltip)
	Events.tooltip_hide_requested.connect(hide_tooltip)
	modulate = Color.TRANSPARENT
	hide()

func show_tooltip(icon: Texture, text: String) -> void:
	is_visible = true
	if tween:
		tween.kill()
	if scroll_tween:
		scroll_tween.kill()
	
	tooltip_icon.texture = icon
	tooltip_text_label.text = text
	tooltip_text_label.get_v_scroll_bar().value = 0
	
	tween = create_tween().set_ease(Tween.EASE_OUT). set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)
	
	# Wait for UI to resize, then start the loop
	await get_tree().process_frame
	start_scrolling_loop()

func start_scrolling_loop() -> void:
	if not is_visible: return

	var v_scroll = tooltip_text_label.get_v_scroll_bar()
	var max_scroll = v_scroll.max_value - v_scroll.page
	
	if max_scroll > 0:
		scroll_tween = create_tween()
		
		# 1. Wait at the top
		scroll_tween.tween_interval(scroll_delay)
		
		# 2. Scroll to bottom
		var duration = max_scroll / scroll_speed
		scroll_tween.tween_property(v_scroll, "value", max_scroll, duration).set_trans(Tween.TRANS_LINEAR)
		
		# 3. Wait at the bottom
		scroll_tween.tween_interval(scroll_delay)
		
		# 4. Reset to top and restart the function (Loop)
		scroll_tween.tween_callback(func():
			v_scroll.value = 0
			start_scrolling_loop()
		)

func hide_tooltip() -> void:
	is_visible = false
	if tween:
		tween.kill()
	if scroll_tween:
		scroll_tween.kill()
	
	get_tree().create_timer(fade_seconds, false).timeout.connect(hide_animation)

func hide_animation() -> void:
		if not is_visible:
			tween = create_tween().set_ease(Tween.EASE_OUT). set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_seconds)
			tween.tween_callback(hide)
