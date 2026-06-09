extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "3.tscn"

var dialogues = [
	{"name": "", "text": "Потому что эта академия стала для меня как дом..."},
	{"name": "", "text": "Я учусь тут первую неделю, и я поняла что мне не хочется уходить отсюда ..."},
	{"name": "", "text": "У меня мало друзей, но мне нравится пару парней..."},
	{"name": "", "text": "Но самое главное для меня, что тут большое количество машин..."},
	{"name": "", "text": "К примеру там альфа ромео джулия..."},
	{"name": "", "text": "...Но еще кайфовое, что комнату можно обставить как хочешь, просто попросив"},
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
