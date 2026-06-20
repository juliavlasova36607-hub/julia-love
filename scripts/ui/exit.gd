extends Button

@export var delay: float = 1.0

func _ready():
	pressed.connect(_on_exit_pressed)

func _on_exit_pressed():
	disabled = true
	

	var _original_text = text
	text = "Выход..."

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	await get_tree().create_timer(delay).timeout
	
	get_tree().quit()
