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

# === НОВАЯ ПЕРЕМЕННАЯ ===
var use_settings_speed: bool = true  # если true — берём скорость из файла настроек

func _ready():
	blink_timer = Timer.new()
	blink_timer.wait_time = blink_speed
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	add_child(blink_timer)
	
	# === НОВЫЙ КОД: загружаем скорость из настроек ===
	load_speed_from_settings()

func show_text(new_text: String, character_name: String = ""):
	stop_blinking()
	
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
			next_dialogue_requested.emit()

# === НОВЫЕ ФУНКЦИИ ===

# Загружает скорость текста из файла настроек
func load_speed_from_settings():
	if not use_settings_speed:
		return
	
	if not FileAccess.file_exists("user://settings.cfg"):
		print("RichTextLabel: файл настроек не найден, использую typing_speed = ", typing_speed)
		return
	
	var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line()
			if line == "":
				continue
			
			if line.begins_with("text_speed="):
				var value = line.split("=")[1]
				var new_speed = float(value)
				if new_speed > 0:
					typing_speed = new_speed
					print("RichTextLabel: скорость текста загружена - ", typing_speed, " симв/сек")
				break
		
		file.close()

# Обновляет скорость текста в реальном времени (можно вызвать из меню настроек)
func update_typing_speed(new_speed: float):
	if new_speed > 0:
		typing_speed = new_speed
		print("RichTextLabel: скорость текста изменена на ", typing_speed)

# Возвращает текущую скорость
func get_typing_speed() -> float:
	return typing_speed
