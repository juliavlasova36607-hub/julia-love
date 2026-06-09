extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "5.tscn"

var dialogues = [
	{"name": "", "text": "В свободное время от учебы, я зависаю в гараже..."},
	{"name": "", "text": "Его можно получить с временной машиной"},
	{"name": "", "text": " Да...я забыла сказать наш колледж связан с техникой"},
	{"name": "", "text": "Для тех, у кого высокая репутация, те могут получить личную машину, во время учебы, даже тюнинговать"},
	{"name": "", "text": "Самый классный парень в колледже: Крис, имеет уже пять тачек, и владеет спорткомандой"},
	{"name": "", "text": "Не знаю сколько он уже учится...но мне он нравится"},
	{"name": "", "text": "Но не больше чем машины..."},
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
