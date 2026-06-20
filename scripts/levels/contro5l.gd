extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/6.tscn"

var dialogues = [
	{"name": "", "text": "7:30 "},
	{"name": "", "text": "Сегодня типичный понедельник"},
	{"name": "", "text": "В аудитории, стоит хаос"},
	{"name": "", "text": "Это норма для моего класса..."},
	{"name": "", "text": "Зак всех донимает, Адам молча закатывает глаза, Элиас пытается всех успокоить, а я..."},
	{"name": "", "text": "просто молча смотрю"},
	{"name": "", "text": "Временами не могу поверить, что я вообще попала в эту академию"},
	{"name": "", "text": "Но, я считаю это к лучшему..."},
]

var current_index = 0

func _ready():
	GameManager.set_current_scene("res://scenes/levels/5.tscn")
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
	get_tree().change_scene_to_file(next_scene_path)
