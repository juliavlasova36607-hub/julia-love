extends Control

@onready var title = $VBoxContainer/Label
@onready var grid_container = $VBoxContainer/GridContainer
@onready var back_button = $VBoxContainer/HBoxContainer/backButton
@onready var mode_button = $VBoxContainer/HBoxContainer/ModeButton

var is_save_mode: bool = false
var from_game: bool = false
var game_manager: Node

func _ready():
	game_manager = get_node("/root/GameManager")
	
	mode_button.pressed.connect(_toggle_mode)
	back_button.pressed.connect(_on_back_pressed)
	
	_create_slots()
	_update_display()

func _create_slots():
	for child in grid_container.get_children():
		child.queue_free()
	
	# ✅ 3 колонки, сетка 3x3
	grid_container.columns = 3
	grid_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_container.add_theme_constant_override("h_separation", 15)
	grid_container.add_theme_constant_override("v_separation", 15)
	
	await get_tree().process_frame
	
	for i in range(9):
		var slot_panel = _create_slot_panel(i)
		grid_container.add_child(slot_panel)

func _create_slot_panel(slot_id: int) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.name = "SlotPanel" + str(slot_id)
	panel.custom_minimum_size = Vector2(280, 160)  # Компактный размер
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Стиль панели
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	style.border_color = Color(0.4, 0.4, 0.5, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	
	# Вертикальная компоновка: превью сверху, текст снизу
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.add_theme_constant_override("separation", 5)
	panel.add_child(vbox)
	
	# Превью сверху
	var preview = ColorRect.new()
	preview.name = "Preview"
	preview.custom_minimum_size = Vector2(0, 70)
	preview.color = Color(0.3, 0.3, 0.35, 1.0)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(preview)
	
	# Название слота
	var slot_label = Label.new()
	slot_label.name = "SlotLabel"
	slot_label.text = "СЛОТ " + str(slot_id + 1)
	slot_label.add_theme_font_size_override("font_size", 14)
	slot_label.add_theme_color_override("font_color", Color(1, 1, 1))
	slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(slot_label)
	
	# Имя сохранения
	var save_name_label = Label.new()
	save_name_label.name = "SaveNameLabel"
	save_name_label.text = "[ПУСТО]"
	save_name_label.add_theme_font_size_override("font_size", 11)
	save_name_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	save_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(save_name_label)
	
	# Дата и время
	var date_label = Label.new()
	date_label.name = "DateLabel"
	date_label.text = ""
	date_label.add_theme_font_size_override("font_size", 10)
	date_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(date_label)
	
	# Кнопка поверх панели
	var button = Button.new()
	button.flat = true
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_on_slot_pressed.bind(slot_id))
	panel.add_child(button)
	
	panel.set_meta("slot_id", slot_id)
	
	return panel

func _update_display():
	if is_save_mode:
		title.text = "СОХРАНЕНИЕ ИГРЫ"
		mode_button.text = "Переключить на загрузку"
	else:
		title.text = "ЗАГРУЗКА ИГРЫ"
		mode_button.text = "Переключить на сохранение"
	
	_update_slots_display()

func _update_slots_display():
	for panel in grid_container.get_children():
		if not panel.has_meta("slot_id"):
			continue
		
		var slot_id: int = panel.get_meta("slot_id")
		var save_info = game_manager.get_save_info(slot_id)
		
		var save_name_label = panel.find_child("SaveNameLabel", true, false)
		var date_label = panel.find_child("DateLabel", true, false)
		var preview = panel.find_child("Preview", true, false)
		
		if save_name_label == null or date_label == null or preview == null:
			continue
		
		if not save_info.is_empty():
			save_name_label.text = save_info.get("save_name", "Сохранение")
			save_name_label.add_theme_color_override("font_color", Color(1, 1, 1))
			
			if save_info.has("timestamp"):
				var ts = save_info["timestamp"]
				var date_text = ts.substr(8, 2) + "." + ts.substr(5, 2) + "." + ts.substr(0, 4)
				date_text += "  " + ts.substr(11, 5)
				date_label.text = date_text
			
			preview.color = Color(0.2, 0.3, 0.4, 1.0)
		else:
			if is_save_mode:
				save_name_label.text = "[ПУСТО]"
				save_name_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			else:
				save_name_label.text = "[НЕТ ДАННЫХ]"
				save_name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			date_label.text = ""
			preview.color = Color(0.2, 0.2, 0.25, 1.0)

func _on_slot_pressed(slot_id: int):
	if is_save_mode:
		var has_save = game_manager.has_save_in_slot(slot_id)
		
		if has_save:
			_show_confirm_dialog("Слот " + str(slot_id + 1) + " уже занят.\nПерезаписать?", slot_id)
		else:
			await _save_to_slot(slot_id)
	else:
		if game_manager.has_save_in_slot(slot_id):
			await _load_from_slot(slot_id)
		else:
			_show_message("В этом слоте нет сохранения!")

func _save_to_slot(slot_id: int):
	var panel = _get_slot_panel(slot_id)
	if panel == null: return
	
	var save_name_label = panel.find_child("SaveNameLabel", true, false)
	if save_name_label == null: return
	
	save_name_label.text = "СОХРАНЕНИЕ..."
	
	await get_tree().create_timer(0.5).timeout
	
	var success = game_manager.save_game(slot_id)
	
	if success:
		save_name_label.text = "✅ СОХРАНЕНО!"
		await get_tree().create_timer(1).timeout
	else:
		save_name_label.text = "❌ ОШИБКА!"
		await get_tree().create_timer(1).timeout
	
	_update_slots_display()

func _load_from_slot(slot_id: int):
	var panel = _get_slot_panel(slot_id)
	if panel == null: return
	
	var save_name_label = panel.find_child("SaveNameLabel", true, false)
	if save_name_label == null: return
	
	save_name_label.text = "ЗАГРУЗКА..."
	
	await get_tree().create_timer(0.5).timeout
	
	var success = game_manager.load_game(slot_id)
	if not success:
		save_name_label.text = "❌ ОШИБКА ЗАГРУЗКИ!"
		await get_tree().create_timer(1.5).timeout
		_update_slots_display()

func _get_slot_panel(slot_id: int) -> PanelContainer:
	for child in grid_container.get_children():
		if child.has_meta("slot_id") and child.get_meta("slot_id") == slot_id:
			return child
	return null

func _toggle_mode():
	is_save_mode = !is_save_mode
	_update_display()

func _on_back_pressed():
	if from_game and game_manager.current_scene_path != "":
		get_tree().change_scene_to_file(game_manager.current_scene_path)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")

func _show_confirm_dialog(message: String, slot_id: int):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.get_ok_button().text = "Да"
	
	var cancel_button = Button.new()
	cancel_button.text = "Нет"
	dialog.add_child(cancel_button)
	
	add_child(dialog)
	dialog.popup_centered()
	
	await dialog.ready
	var result = await dialog.confirmed
	
	if result:
		await _save_to_slot(slot_id)
	
	dialog.queue_free()

func _show_message(msg: String):
	var label = Label.new()
	label.text = msg
	label.position = get_viewport().size / 2
	add_child(label)
	await get_tree().create_timer(1.5).timeout
	label.queue_free()
