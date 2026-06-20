extends Button

@export var scene_path: String = "res://scenes/levels/1.tscn"
@export var delay: float = 1.0 

func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	disabled = true
	
	text = "Загрузка..."
	
	await get_tree().create_timer(delay).timeout
	
	await GameManager.change_scene_with_fade(scene_path)
