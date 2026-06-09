extends Button

# Путь к сцене настроек (файл лежит в корне проекта)
@export var settings_scene_path: String = "res://settings.tscn"

func _ready():
	# Подключаем сигнал нажатия на кнопку
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# Отключаем кнопку, чтобы нельзя было нажать дважды
	disabled = true
	
	# Меняем текст (если хочешь)
	text = "Загрузка настроек..."
	
	# Небольшая задержка для красоты (0.3 секунды)
	await get_tree().create_timer(0.3).timeout
	
	# Загружаем сцену настроек
	get_tree().change_scene_to_file(settings_scene_path)
