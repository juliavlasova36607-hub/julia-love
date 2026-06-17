extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/24,1.tscn"

var dialogues = [
	{"name": "", "text": "Вария подходит к Розарии, пока она сидит кушает в одиночестве"},
	{"name": "", "text": "За ней две подруги"},
	{"speaker": "Вария", "text": "Привет, утопленница. Как карцер? Понравилось?"},
	{"speaker": "Розария", "text": "Спроси у того, кто подкинул свечи. Он знаеет лучше"},
	{"speaker": "Вария", "text": "О, я не при делах. У меня алиби. Я была с Крисом"},
	
	
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
