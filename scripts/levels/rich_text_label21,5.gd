extends RichTextLabel

signal next_dialogue_requested

@export var typing_speed: float = 40.0
@export var character_name_node: RichTextLabel
@export var blink_char: String = "█"  
@export var blink_speed: float = 0.5 

var is_typing: bool = false
var skip_current: bool = false
var is_blinking: bool = false
var full_text: String = ""
var blink_timer: Timer
var fade_rect: ColorRect = null
var is_last_dialogue: bool = false

func _ready():
	blink_timer = Timer.new()
	blink_timer.wait_time = blink_speed
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	add_child(blink_timer)

func show_text(new_text: String, character_name: String = "", last: bool = false):
	stop_blinking()
	is_last_dialogue = last
	
	if character_name_node and character_name != "":
		character_name_node.text = "[color=#ff0000]" + character_name + "[/color]"
	elif character_name_node:
		character_name_node.text = ""
	
	full_text = new_text
	text = new_text
	visible_characters = 0
	is_typing = true
	skip_current = false

	await start_typing()

func start_typing():
	var total_chars = text.length()
	
	while visible_characters < total_chars and not skip_current:
		await get_tree().create_timer(1.0 / typing_speed).timeout
		visible_characters += 1

	if skip_current:
		visible_characters = total_chars
	
	is_typing = false
	start_blinking()

func start_blinking():
	if not is_blinking and not is_typing:
		is_blinking = true
		text = full_text
		blink_timer.start()

func stop_blinking():
	if is_blinking:
		is_blinking = false
		blink_timer.stop()
		if text.length() > full_text.length():
			text = full_text

func _on_blink_timer_timeout():
	if is_blinking:
		if text == full_text:
			text = full_text + blink_char
		else:
			text = full_text

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		if is_typing:
			skip_current = true
		elif is_blinking:
			stop_blinking()
			if is_last_dialogue:
				start_fade_and_transition()
			else:
				next_dialogue_requested.emit()

func start_fade_and_transition():
	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.color.a = 0
	fade_rect.size = get_viewport().get_visible_rect().size
	get_tree().root.add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween.finished
	
	next_dialogue_requested.emit()
	fade_rect.queue_free()
