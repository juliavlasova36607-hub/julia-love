extends Control

# === Ссылки на узлы (правильные пути) ===
@onready var text_speed_slider = $VBoxContainer/HBoxContainer/TextSpeedSlider
@onready var save_button = $VBoxContainer/SaveButton
@onready var back_button = $VBoxContainer/BackButton

# === Значения по умолчанию ===
var settings: Dictionary = {
	"text_speed": 30
}

func _ready():
	# Проверяем, что все узлы найдены
	if text_speed_slider == null:
		print("ОШИБКА: не найден TextSpeedSlider")
		return
	
	if save_button == null:
		print("ОШИБКА: не найдена SaveButton")
		return
	
	if back_button == null:
		print("ОШИБКА: не найдена BackButton")
		return
	
	# Загружаем сохранённые настройки
	load_settings()
	
	# Устанавливаем значения ползунка
	text_speed_slider.value = settings["text_speed"]
	
	# Подключаем сигналы
	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	save_button.pressed.connect(_on_save_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	print("Сцена настроек загружена, скорость текста: ", settings["text_speed"])

func _on_text_speed_changed(value: float):
	settings["text_speed"] = value
	print("Скорость текста изменена: ", value)

func _on_save_pressed():
	save_settings()
	
	var original_text = save_button.text
	save_button.text = "Сохранено!"
	save_button.disabled = true
	await get_tree().create_timer(1.0).timeout
	save_button.text = original_text
	save_button.disabled = false

func _on_back_pressed():
	save_settings()
	get_tree().change_scene_to_file("res://main_menu.tscn")

func save_settings():
	var save_file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	if save_file:
		for key in settings:
			save_file.store_line(key + "=" + str(settings[key]))
		save_file.close()
		print("Настройки сохранены: ", settings)

func load_settings():
	if not FileAccess.file_exists("user://settings.cfg"):
		print("Файл настроек не найден, использую значения по умолчанию")
		return
	
	var save_file = FileAccess.open("user://settings.cfg", FileAccess.READ)
	if save_file:
		while not save_file.eof_reached():
			var line = save_file.get_line()
			if line == "":
				continue
			
			var parts = line.split("=")
			if parts.size() == 2:
				var key = parts[0]
				var value = parts[1]
				
				if settings.has(key):
					settings[key] = float(value)
		
		save_file.close()
		print("Настройки загружены: ", settings)
