extends Button

@export var scene_path: String = "res://galery7.tscn"
@export var delay: float = 1.0 

func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	disabled = true
	
	text = "Кай..."
	
	await get_tree().create_timer(delay).timeout
	
	get_tree().change_scene_to_file(scene_path)
