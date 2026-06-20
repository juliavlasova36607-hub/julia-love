extends Control

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/19.tscn"

# Массив с диалогами (каждый элемент - словарь с именем говорящего и текстом)
var dialogue = [
 {"name": "", "text": "Хорошая тачка, жалко, что ты её утопила"},
 {"name": "", "text": "Она резко оборачивается. Рядом с машиной стоит Зак"},
 {"speaker": "Розария", "text": "Ты следил за мной? "},
 {"speaker": "Зак", "text": "Я слежу за всеми. Это моя работа. Ну, одна из"},
 {"name": "", "text": "Он проводит палец по ржавому крылу"},
 {"speaker": "Зак", "text": "RB26DETT. Два турбонагнетателя. 280 сил в стоке. Но этот мотор перебран. Кто-то вложил в него душу. Ты?"},
 {"speaker": "Розария", "text": "Отец. Он подарил мне эту машину перед смертью. Всё что он мне сккзал: Береги её."},
 {"speaker": "Розария", "text": "Это единстенное, что я могу тебе оставить."},
 {"speaker": "Розария", "text": "А я... я угнала чужую тачку. На спор. Разбила. А эту утопила. Сама"},
 {"name": "", "text": "Зак смотрит долго на неё"},
 {"speaker": "Зак", "text": "Знаешь, что хуже преступления?Чувство вины. Оно сожрёт тебя бытрее, чем любой надзритель"},
 {"speaker": "Зак", "text": "Хочешьвыбраться отсюда?"},
 {"speaker": "Розария", "text": "Больше всего на свете..."},
 {"speaker": "Розария", "text": "Тогда почини этот skyline. Сделай его быстрее, чем он был. Я помогу. Связь, хакерство, информация"},
 {"speaker": "Розария", "text": "А ты автомеханик, и когда машина будет готова уедем вместе"},
 {"name": "", "text": "Я смотрю перекидываю взгляд в его глаза и с небольшим страхом соглашаюсь..."},

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
