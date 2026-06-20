extends Control


@onready var save_button = $VBoxContainer/SaveButton
@onready var load_button = $VBoxContainer/LoadButton
@onready var back_button = $VBoxContainer/BackButton
@onready var menu_button = $VBoxContainer/MenuButton
@onready var quit_button = $VBoxContainer/QuitButton

var settings: Dictionary = {"text_speed": 30}
var is_processing: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	add_background()
	load_settings()
	
	back_button.pressed.connect(_on_back_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	save_button.pressed.connect(_on_save_game_pressed)
	load_button.pressed.connect(_on_load_game_pressed)
	
	if GameManager.return_to_game and GameManager.current_scene_path != "":
		back_button.text = "Назад в игру"
		menu_button.visible = true
	else:
		back_button.text = "Назад"
		menu_button.visible = false


func _on_save_pressed():
	save_settings()
	save_button.text = "✅"
	await get_tree().create_timer(1).timeout
	save_button.text = "Сохранить"

func _on_back_pressed():
	if is_processing:
		return
	is_processing = true
	
	save_settings()
	
	if GameManager.return_to_game and GameManager.current_scene_path != "":
		var path = GameManager.current_scene_path
		GameManager.remove_settings_overlay()
		await get_tree().process_frame
		await GameManager.change_scene_with_fade(path)
	else:
		GameManager.remove_settings_overlay()
		await get_tree().process_frame
		await GameManager.change_scene_with_fade("res://scenes/ui/menu.tscn")
	
	is_processing = false

func _on_menu_pressed():
	if is_processing:
		return
	is_processing = true
	
	save_settings()
	GameManager.clear_return()
	GameManager.remove_settings_overlay()
	await get_tree().process_frame
	await GameManager.change_scene_with_fade("res://scenes/ui/menu.tscn")
	
	is_processing = false
	
func _on_quit_pressed():
	save_settings()
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

func save_settings():
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	if file:
		file.store_line("text_speed=" + str(settings["text_speed"]))
		file.close()

func load_settings():
	if FileAccess.file_exists("user://settings.cfg"):
		var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		var line = file.get_line()
		if line.begins_with("text_speed="):
			settings["text_speed"] = float(line.split("=")[1])
		file.close()

func add_background():
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.05, 0.05, 0.1, 0.85)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)
	move_child(bg, 0)

func _on_save_game_pressed():
	if is_processing:
		print("⏳ Уже выполняется операция, пропускаем")
		return
	
	print("🔵 _on_save_game_pressed() вызван")
	is_processing = true
	
	# Блокируем кнопки
	save_button.disabled = true
	load_button.disabled = true
	back_button.disabled = true
	menu_button.disabled = true
	
	save_settings()
	
	print("  🗑️ Удаляем оверлей настроек...")
	GameManager.remove_settings_overlay()
	
	# ✅ ИСПОЛЬЗУЕМ Callable для отложенного вызова
	print("  📂 Планируем открытие меню сохранения...")
	call_deferred("_open_save_menu_deferred")

func _open_save_menu_deferred():
	print("  ✅ _open_save_menu_deferred() выполняется")
	# Проверяем, что сцена все еще существует
	if not is_instance_valid(self):
		print("  ⚠️ Сцена настроек уничтожена, пропускаем")
		return
	
	GameManager.open_save_load_menu(true, true)
	
	# Разблокируем кнопки (если мы еще живы)
	if is_instance_valid(self):
		save_button.disabled = false
		load_button.disabled = false
		back_button.disabled = false
		menu_button.disabled = false
		is_processing = false

func _on_load_game_pressed():
	if is_processing:
		print("⏳ Уже выполняется операция, пропускаем")
		return
	
	print("🔵 _on_load_game_pressed() вызван")
	is_processing = true
	
	# Блокируем кнопки
	save_button.disabled = true
	load_button.disabled = true
	back_button.disabled = true
	menu_button.disabled = true
	
	save_settings()
	
	print("  🗑️ Удаляем оверлей настроек...")
	GameManager.remove_settings_overlay()
	
	# ✅ ИСПОЛЬЗУЕМ Callable для отложенного вызова
	print("  📂 Планируем открытие меню загрузки...")
	call_deferred("_open_load_menu_deferred")

func _open_load_menu_deferred():
	print("  ✅ _open_load_menu_deferred() выполняется")
	# Проверяем, что сцена все еще существует
	if not is_instance_valid(self):
		print("  ⚠️ Сцена настроек уничтожена, пропускаем")
		return
	
	GameManager.open_save_load_menu(false, true)
	
	# Разблокируем кнопки (если мы еще живы)
	if is_instance_valid(self):
		save_button.disabled = false
		load_button.disabled = false
		back_button.disabled = false
		menu_button.disabled = false
		is_processing = false
