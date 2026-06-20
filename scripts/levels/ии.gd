extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/10.tscn"

var dialogues = [
	{"name": "", "text": "Да да, Кай и Крис будьте хорошими мальчиками."},
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

	var is_last = (current_index == dialogues.size() - 1)
	var d = dialogues[current_index]
	dialog_text.show_text(d["text"], d["name"], is_last)

func _on_dialog_text_next_dialogue():
	current_index += 1
	show_current_dialogue()

func transition_to_next_scene():
	get_tree().change_scene_to_file(next_scene_path)
