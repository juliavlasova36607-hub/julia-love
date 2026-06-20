extends Control

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/21,17.tscn"

# Массив с диалогами (каждый элемент - словарь с именем говорящего и текстом)
var dialogue = [
 {"name": "", "text": "Розария берёт бумагу. Пальцы не слушаются. В это время подходит Зак"},
 {"name": "", "text": "На лице никаких эмоций. Но внутри всё рушится"},
 {"speaker": "Розария", "text": "Зачем ты мне это показываешь?"},
 {"speaker": "Крис", "text": "Чтобы ты знала.Когда будешь смотреть на меня - смотрела на сына человека, который забрал твоего отца"},
 {"speaker": "Крис", "text": "И чтобы ты поняла: мы здесь не просто так"},
 {"speaker": "Крис", "text": "Мы здесь потому что наши отцы заплатили кровью за наше место в этом аду"},
 {"name": "", "text": "Тут в разговор вмешивается Зак"},
 {"speaker": "Зак", "text": "Хватит, Крис. Она не просила правды"},
 {"speaker": "Крис", "text": "А тебя никто не спрашивал, хакер"},
 {"name": "", "text": "Между ними напряжение. Розария вдруг делает пару шагов вперёд. Встаёт между ними"}, 

]  

var current_line = 0
var is_dialogue_active = true

@onready var dialog_text = $RichTextLabel
@onready var dialog_window = $TextureRect

func _ready():
	GameManager.set_current_scene("res://scenes/levels/21,16.tscn")
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
