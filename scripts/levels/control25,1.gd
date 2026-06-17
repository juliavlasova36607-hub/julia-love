extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/25,2.tscn"

var dialogues = [
	{"speaker": "Крис", "text": "Твой отец не хотел, чтобы ты не гоняла. Он хотел, чтобы ты была в безопасности"},
	{"speaker": "Крис", "text": "Он их писал моему отцу. За месяц до того, как его убили"},
	{"speaker": "Розария", "text": "Откуда ты знаешь про письма?"},
	{"speaker": "Крис", "text": "Они хранились в доме моего отца. После его смерти я нашёл их. Не уничтожил. Сохранил для тебя"},
	
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
