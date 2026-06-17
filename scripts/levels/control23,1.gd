extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/23,2.tscn"

var dialogues = [
	{"name": "", "text": "Они идут на крышую Садятся. Рэй начинает читать свои стихи"},
	{"speaker": "Рэй", "text": "я не прошу тебя любить меня. Я прошу - не ломайся. Потому что если ты сломаешься, этот мир станет совсем серый."},
	{"speaker": "Рэй", "text": "А я не выношу серость. Я привык к крови и розам."},
	{"name": "", "text": "Розария молчит"},
	{"name": "", "text": "Где то там мост. Свобода. Но сейчас она думает не о побеге..."},
	{"name": "", "text": "Она думает о Крисе..."},
	
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
