extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/12.tscn"

var dialogues = [
	{"name": "", "text": "Так проходит мой день..."},
	{"name": "", "text": "Могло и лучше, но мне плевать...Как только закончу академию, выйду с тачкой и уеду в Москву"},
]

var current_index = 0

func _ready():
	GameManager.set_current_scene("res://scenes/levels/10.tscn")
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
