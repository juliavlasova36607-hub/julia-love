extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/3.tscn"

var dialogues = [
	{"name": "", "text": "Я открываю глаза "},
	{"name": "", "text": "Потолок — белого цвета, с трещинами. Вместо капельницы — провод, воткнутый в разбитый аккумулятор"},
	{"name": "", "text": "На соседней койке спит парень "},
	{"name": "", "text": "Я пытаюсь сесть. Тело ломит..."},
	{"name": "", "text": "«Как выбраться?» — первая мысль"},
	{"name": "", "text": "Я ошибалась. Выбраться отсюда нельзя"},
	{"name": "", "text": "Прошлое некое количество времени и я поняла..."},
	{"name": "", "text": "Поняла, что хочу уехать отсюда, как можно скорее..."},
]

var current_index = 0

func _ready():
	if dialog_text == null:
		print("ОШИБКА: не найдено DialogText")
		return
	
	dialog_text.next_dialogue_requested.connect(_on_dialog_text_next_dialogue)
	
	show_current_dialogue()

func show_current_dialogue():
	if current_index >= dialogues.size():
		transition_to_next_scene()
		return
	
	var d = dialogues[current_index]
	dialog_text.show_text(d["text"], d["name"])

func _on_dialog_text_next_dialogue():
	current_index += 1
	show_current_dialogue()

func transition_to_next_scene():
	await GameManager.change_scene_with_fade (next_scene_path)
