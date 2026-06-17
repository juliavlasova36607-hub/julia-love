extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	disabled = true
	text = "Загрузка..."
	
	await get_tree().create_timer(0.3).timeout
	
	# Открываем меню загрузки (не из игры)
	var game_manager = get_node("/root/GameManager")
	game_manager.open_save_load_menu(false, false)
	
	disabled = false
	text = "Загрузить игру"
