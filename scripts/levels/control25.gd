extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/25,1.tscn"

var dialogues = [
	{"name": "", "text": "Вечером, Розария пошла так называют в этой академии могильник машин, это типо свалки старых машин"},
	{"name": "", "text": "Рзных иномарок, которые лежат в овраге за приделом с академией"},
	{"name": "", "text": "На этом могильнике Розария нашла ей нужную деталь на skyline, это было редкий датчик давления"},
	
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
	get_tree().change_scene_to_file(next_scene_path)
