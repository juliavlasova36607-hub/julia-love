extends Node

var current_scene_path: String = ""
var return_to_game: bool = false
var settings_open: bool = false
var settings_layer: CanvasLayer = null

const SettingsScene = preload("res://scenes/ui/settings.tscn")
const SaveLoadScene = preload("res://scenes/ui/save_load_menu.tscn")

func set_current_scene(path: String) -> void:
	current_scene_path = path
	return_to_game = true

func clear_return() -> void:
	current_scene_path = ""
	return_to_game = false

func _unhandled_input(event: InputEvent) -> void:
	if settings_open:
		return
	
	if event.is_action_pressed("ui_cancel"):
		var current = get_tree().current_scene
		if current == null:
			return
		
		var scene_name: String = current.scene_file_path
		
		if scene_name.ends_with("menu.tscn") or scene_name.ends_with("settings.tscn") or scene_name.ends_with("save_load_menu.tscn"):
			return
		
		get_viewport().set_input_as_handled()
		open_settings()

func open_settings():
	settings_open = true
	
	if return_to_game and current_scene_path != "":
		# === МЫ В ИГРЕ → открываем оверлей ===
		get_tree().paused = true
		
		settings_layer = CanvasLayer.new()
		settings_layer.name = "SettingsOverlay"
		settings_layer.layer = 100
		
		var settings = SettingsScene.instantiate()
		settings_layer.add_child(settings)
		get_tree().root.add_child(settings_layer)
	else:
		# === МЫ В МЕНЮ → меняем сцену ===
		get_tree().change_scene_to_file("res://scenes/ui/settings.tscn")
		await get_tree().create_timer(0.1).timeout
		settings_open = false

func remove_settings_overlay():
	"""Удаляет оверлей настроек"""
	get_tree().paused = false
	
	if settings_layer != null and is_instance_valid(settings_layer):
		settings_layer.queue_free()
		settings_layer = null
	
	settings_open = false

func open_save_load_menu(is_saving: bool, is_from_game: bool):
	"""Открывает меню сохранения/загрузки как отдельную сцену"""
	# Сохраняем текущую сцену если мы в игре
	if is_from_game and current_scene_path != "":
		return_to_game = true
	
	# Просто меняем сцену
	get_tree().change_scene_to_file("res://scenes/ui/save_load_menu.tscn")
	
	# Передаем параметры после загрузки (через сигнал или глобальную переменную)
	await get_tree().process_frame
	var menu = get_tree().current_scene
	if menu:
		menu.is_save_mode = is_saving
		menu.from_game = is_from_game

# === ФУНКЦИИ ДЛЯ РАБОТЫ С СОХРАНЕНИЯМИ ===

func get_save_info(slot_id: int) -> Dictionary:
	var file_path = "user://save_slot_" + str(slot_id) + ".json"
	if not FileAccess.file_exists(file_path):
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return {}
	
	return json.data

func has_save_in_slot(slot_id: int) -> bool:
	var file_path = "user://save_slot_" + str(slot_id) + ".json"
	return FileAccess.file_exists(file_path)

func save_game(slot_id: int) -> bool:
	var file_path = "user://save_slot_" + str(slot_id) + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("❌ Ошибка: не удалось открыть файл для записи")
		return false
	
	# ⚠️ ВАЖНО: если current_scene_path пустой, берём текущую сцену
	var path_to_save = current_scene_path
	if path_to_save == "":
		var current = get_tree().current_scene
		if current != null:
			path_to_save = current.scene_file_path
			print("⚠️ current_scene_path был пустым, используем: ", path_to_save)
		else:
			print("❌ Ошибка: нет текущей сцены!")
			return false
	
	var scene_name = path_to_save.get_file().replace(".tscn", "")
	
	var save_data = {
		"save_name": "Сохранение " + str(slot_id + 1),
		"timestamp": Time.get_datetime_string_from_system(),
		"scene_path": path_to_save,
		"scene_name": scene_name
	}
	
	print("💾 Сохраняем в слот ", slot_id, ": ", path_to_save)
	
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	return true

func load_game(slot_id: int) -> bool:
	var save_info = get_save_info(slot_id)
	if save_info.is_empty():
		print("❌ Ошибка: нет данных в слоте ", slot_id)
		return false
	
	var scene_path = save_info.get("scene_path", "")
	print("📂 Путь из сохранения: ", scene_path)
	
	if scene_path == "":
		print("❌ Ошибка: путь к сцене пустой!")
		return false
	
	# Проверяем, существует ли файл сцены
	if not ResourceLoader.exists(scene_path):
		print("❌ Ошибка: файл сцены не существует! ", scene_path)
		return false
	
	print("✅ Загружаем сцену: ", scene_path)
	
	# Снимаем паузу если была
	get_tree().paused = false
	
	# Очищаем флаги
	clear_return()
	
	# ✅ Загружаем сцену с затемнением
	await change_scene_with_fade(scene_path, 0.3)
	
	return true
	
func change_scene_with_fade(scene_path: String, fade_duration: float = 0.3) -> void:
	"""
	Переход между сценами с затемнением.
	fade_duration - длительность затемнения в секундах (по умолчанию 0.3)
	"""
	# Создаём чёрный слой поверх всего
	var fade_layer = CanvasLayer.new()
	fade_layer.layer = 1000  # Очень высокий слой
	fade_layer.name = "FadeLayer"
	
	# Создаём чёрный прямоугольник на весь экран
	var color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0)  # Прозрачный чёрный
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Не блокирует клики
	fade_layer.add_child(color_rect)
	get_tree().root.add_child(fade_layer)
	
	# === ЗАТЕМНЕНИЕ ===
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, fade_duration)
	await tween.finished
	
	# === СМЕНА СЦЕНЫ ===
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame  # Ждём, чтобы сцена успела загрузиться
	
	# === ПРОСВЕТЛЕНИЕ ===
	var tween2 = create_tween()
	tween2.tween_property(color_rect, "color:a", 0.0, fade_duration)
	await tween2.finished
	
	# Удаляем слой
	fade_layer.queue_free()
