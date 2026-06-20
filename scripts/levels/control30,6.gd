extends Control

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/30,6.tscn"

# Массив с диалогами
var dialogue = [
	{"name": "", "text": "Машина уезжает в ночь"},
	{"name": "", "text": "Дорога уходит вдаль..."},
	{"name": "", "text": "Это была долгая история..."},
	{"name": "", "text": "Но все когда-нибудь заканчивается."},
	{"name": "", "text": "Спасибо, что прошли этот путь вместе с нами!"}
]  

var current_line = 0
var is_dialogue_active = true
var is_ending_processed = false  # Флаг для предотвращения множественных переходов

@onready var dialog_text = $RichTextLabel
@onready var dialog_window = $TextureRect

func _ready():
	print("🎬 Концовка началась!")
	show_current_line()
	focus_mode = Control.FOCUS_ALL
	grab_focus()

func _input(event):
	if is_ending_processed:
		return
	
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()):
		if is_dialogue_active:
			next_line()

func next_line():
	current_line += 1
	
	if current_line >= dialogue.size():
		end_dialogue()
	else:
		show_current_line()

func show_current_line():
	var current = dialogue[current_line]
	
	# Получаем имя говорящего
	var speaker_name = ""
	if current.has("speaker"):
		speaker_name = current["speaker"]
	elif current.has("name"):
		speaker_name = current["name"]
	else:
		speaker_name = ""
	
	# Если имя пустое, показываем только текст
	if speaker_name == "":
		dialog_text.text = current["text"]
	else:
		dialog_text.text = speaker_name + ": " + current["text"]

func end_dialogue():
	if is_ending_processed:
		return
	
	is_ending_processed = true
	is_dialogue_active = false
	dialog_text.text = ""
	print("🎬 Диалог завершен")
	
	# Показываем сообщение о возврате в меню
	dialog_text.text = "Возвращение в главное меню..."
	await get_tree().create_timer(1.0).timeout
	
	# Очищаем флаги в GameManager
	GameManager.clear_return()
	get_tree().paused = false
	
	# Переход с затемнением
	await GameManager.change_scene_with_fade("res://scenes/ui/menu.tscn")
