extends Control

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/30,1.tscn"

# Массив с диалогами (каждый элемент - словарь с именем говорящего и текстом)
var dialogue = [
 {"name": "", "text": "Рядом стоит Зак, Кай, Рэй, Крис. Даже Вария стоит "},
 {"speaker": "Вария", "text": "Не подумайте, что я помогаю. Я просто хочу, чтобы эта дрянь уехала и я забыла о ней "},
 {"speaker": "Крис", "text": "Я еду с тобой"},
 {"speaker": "Розария", "text": "А Вария?"},
 {"speaker": "Крис", "text": "Она остаётся, это её выбор"},
 {"speaker": "Кай", "text": "Я остаюсь. Кто-то же должен взорвать эту академию после вашего побега"},
 {"speaker": "Рэй", "text": "Я отвлеку охрану. Ты заслуживаешь свободу"},

]  

var current_line = 0
var is_dialogue_active = true

@onready var dialog_text = $RichTextLabel
@onready var dialog_window = $TextureRect

func _ready():
	show_current_line()
	focus_mode = Control.FOCUS_ALL
	grab_focus()

func _input(event):
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
	
	# ПРОВЕРЯЕМ: есть ли ключ "speaker", если нет - используем "name"
	var speaker_name = ""
	if current.has("speaker"):
		speaker_name = current["speaker"]
	elif current.has("name"):
		speaker_name = current["name"]
	else:
		speaker_name = ""  # на случай, если нет ни того, ни другого
	
	# Если имя пустое, показываем только текст
	if speaker_name == "":
		dialog_text.text = current["text"]
	else:
		dialog_text.text = speaker_name + ": " + current["text"]

func end_dialogue():
	is_dialogue_active = false
	dialog_text.text = ""
	print("Диалог завершен")
	
	# ПЕРЕХОД НА СЛЕДУЮЩУЮ СЦЕНУ (ДОБАВЛЯЕМ ЭТОТ КОД)
	if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
		await GameManager.change_scene_with_fade (next_scene_path)
	else:
		print("Ошибка: сцена не найдена по пути ", next_scene_path)
