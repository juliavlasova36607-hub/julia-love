extends Control

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/20,1.tscn"

# Массив с диалогами (каждый элемент - словарь с именем говорящего и текстом)
var dialogue = [
 {"speaker": "Элиас", "text": "Оружие - продолжение механики"},
 {"speaker": "Элиас", "text": "Двигатель превращает энергию в движение. Пистолет - энергию в смерть"},
 {"speaker": "Элиас", "text": "Сегодня сборка-разборка M9. На время. Тот, кто провалит будут находится сутки в карцере "},
 {"speaker": "Элиас", "text": "Розария, давайте вы попробуете собрать M9"},
 {"name": "", "text": "Розария работаее. пальцы летают. 6,8 секунды "},
 {"speaker": "Элиас", "text": "Хорошо. Садись "},
 {"name": "", "text": "Я щас вернусь сказал преподаватель и ушёл"},
 {"name": "", "text": "Сзади подошёл Адам со своей компанией"},


]

var current_line = 0
var is_dialogue_active = true

@onready var dialog_text = $RichTextLabel
@onready var dialog_window = $TextureRect

func _ready():
	GameManager.set_current_scene("res://scenes/levels/20.tscn")
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
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Ошибка: сцена не найдена по пути ", next_scene_path)
