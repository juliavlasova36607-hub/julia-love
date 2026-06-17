extends Control

@onready var dialog_text = $RichTextLabel
@onready var character_name = $TextureRect

# Путь к следующей сцене
@export var next_scene_path: String = "res://scenes/levels/1,2.tscn"

var dialogues = [
	{"name": "", "text": "Черный экран. Вспышка фар. Вибрация от удара…"},
	{"name": "", "text": "Я помню только холод…"},
	{"name": "", "text": "Вода заливалась в салон «Порше» так быстро, будто машина сама хотела утянуть меня на дно"},
	{"name": "", "text": "Ремни безопасности впились в ключицы. Стекло разбилось и поцарапало мне руку"},
	{"name": "", "text": "Зачем я ее угнала? Чтобы доказать бывшему, что я чего-то стою? Глупо"},
	{"name": "", "text": "Сознание уходит рывками…"},
	{"name": "", "text": "Сначала звук — глухой, подводный. Потом свет — белый, больничный"},
	{"name": "", "text": "А Потом..."},
	{"name": "", "text": "Потом запах"},
	{"name": "", "text": "Соляра. Железо. И сигаретный дым, который щиплет глаза"},
]

var current_index = 0

func _ready():
	# ✅ СООБЩАЕМ GAME MANAGER О ТЕКУЩЕЙ СЦЕНЕ
	GameManager.set_current_scene("res://scenes/levels/1,1.tscn")
	
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
	if next_scene_path == "":
		print("ОШИБКА: путь к следующей сцене не задан")
		return
	
	if not ResourceLoader.exists(next_scene_path):
		printerr("ОШИБКА: следующая сцена не найдена - ", next_scene_path)
		return
	
	get_tree().change_scene_to_file(next_scene_path)
