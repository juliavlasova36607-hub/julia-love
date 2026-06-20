extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/23,1.tscn"

var dialogues = [
	{"speaker": "", "text": ""}, # <-- ИСПРАВЛЕНО: "name" заменено на "speaker"
	{"speaker": "Рэй", "text": " "},
	{"speaker": "Рэй", "text": ""},
	{"speaker": "Розария", "text": ""},
	{"speaker": "Рэй", "text": ""},
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
	# <-- ИСПРАВЛЕНО: d["name"] заменено на d["speaker"]
	dialog_text.show_text(d["text"], d["speaker"])

func _on_dialog_text_next_dialogue():
	current_index += 1
	show_current_dialogue()

func transition_to_next_scene():
	await GameManager.change_scene_with_fade (next_scene_path)
